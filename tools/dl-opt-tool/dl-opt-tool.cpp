//===----------------------------------------------------------------------===//
// dl-opt-tool — AI-Optima Command-Line Compiler Tool
//
// A comprehensive MLIR-based tool for deep learning kernel optimization.
// Supports three modes of operation:
//
//   1. Pass Pipeline Mode (default):
//      Apply optimization and lowering passes to .mlir input, like mlir-opt.
//      $ dl-opt-tool input.mlir --dlopt-pipeline
//
//   2. JIT Execution Mode:
//      Lower to LLVM, JIT-compile, and execute a function.
//      $ dl-opt-tool test/numeric_smoke.mlir --dlopt-pipeline --run \
//          --entry-point=aioptima_check
//
//   3. LLVM IR Emission Mode:
//      Output the final LLVM IR after lowering.
//      $ dl-opt-tool input.mlir --dlopt-pipeline --emit-llvm
//
//===----------------------------------------------------------------------===//

#include "DLOpt/DLOptDialect.h"
#include "DLOpt/DLOptOps.h"
#include "DLOpt/Passes.h"

#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/ControlFlow/IR/ControlFlow.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/Arith/Transforms/BufferizableOpInterfaceImpl.h"
#include "mlir/Dialect/Bufferization/Transforms/FuncBufferizableOpInterfaceImpl.h"
#include "mlir/Dialect/ControlFlow/Transforms/BufferizableOpInterfaceImpl.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/Linalg/Transforms/BufferizableOpInterfaceImpl.h"
#include "mlir/Dialect/Linalg/Transforms/TilingInterfaceImpl.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/SCF/Transforms/BufferizableOpInterfaceImpl.h"
#include "mlir/Dialect/Tensor/IR/Tensor.h"
#include "mlir/Dialect/Tensor/IR/TensorTilingInterfaceImpl.h"
#include "mlir/Dialect/Tensor/Transforms/BufferizableOpInterfaceImpl.h"

#include "mlir/ExecutionEngine/ExecutionEngine.h"
#include "mlir/ExecutionEngine/OptUtils.h"
#include "mlir/IR/AsmState.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/MLIRContext.h"
#include "mlir/IR/OwningOpRef.h"
#include "mlir/Parser/Parser.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Target/LLVMIR/Dialect/Builtin/BuiltinToLLVMIRTranslation.h"
#include "mlir/Target/LLVMIR/Dialect/LLVMIR/LLVMToLLVMIRTranslation.h"
#include "mlir/Target/LLVMIR/Export.h"
#include "mlir/Support/FileUtilities.h"
#include "mlir/Tools/mlir-opt/MlirOptMain.h"

#include "llvm/IR/Module.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/InitLLVM.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/ToolOutputFile.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/TargetSelect.h"

#include <chrono>
#include <array>
#include <algorithm>
#include <cmath>
#include <cstdlib>
#include <vector>

using namespace mlir;


//===----------------------------------------------------------------------===//
// Command-line options
//===----------------------------------------------------------------------===//

static llvm::cl::opt<bool> runJIT(
    "run", llvm::cl::desc("JIT compile and execute the lowered code"),
    llvm::cl::init(false));

static llvm::cl::opt<bool> emitLLVM(
    "emit-llvm", llvm::cl::desc("Emit LLVM IR after lowering"),
    llvm::cl::init(false));

static llvm::cl::opt<std::string> entryPoint(
    "entry-point",
    llvm::cl::desc("Entry point function name for JIT execution"),
    llvm::cl::init("main"));

static llvm::cl::opt<bool> runPipeline(
    "dlopt-run-pipeline",
    llvm::cl::desc("Run the full DLOpt optimization pipeline before "
                   "JIT/emit-llvm"),
    llvm::cl::init(true));

static llvm::cl::opt<int64_t> tileSize(
    "tile-size",
    llvm::cl::desc("Tile size for loop tiling (default: 64)"),
    llvm::cl::init(64));

static llvm::cl::opt<int> iterations(
    "iterations", llvm::cl::desc("Timed JIT repetitions (default: 7)"),
    llvm::cl::init(7));

static llvm::cl::opt<bool> enableFusion(
    "enable-fusion",
    llvm::cl::desc("Enable operator fusion pass (default: true)"),
    llvm::cl::init(true));

//===----------------------------------------------------------------------===//
// JIT Execution
//===----------------------------------------------------------------------===//
struct MemRef2DF32 {
  float *allocated;
  float *aligned;
  int64_t offset;
  int64_t sizes[2];
  int64_t strides[2];
};

struct MemRef1DF32 {
  float *allocated;
  float *aligned;
  int64_t offset;
  int64_t size;
  int64_t stride;
};

static int runJITExecution(ModuleOp module, FunctionType sourceEntryType,
                           bool sourceHasRelu) {
  if (!sourceEntryType) {
    llvm::errs() << "JIT entry point must be a func.func in the input module.\n";
    return 1;
  }
  if (iterations < 1 || iterations > 1000) {
    llvm::errs() << "JIT iterations must be between 1 and 1000.\n";
    return 1;
  }
#if defined(_WIN32) && defined(AI_OPTIMA_LLVM_BIN_PATH)
  const char *currentPath = std::getenv("PATH");
  std::string runtimePath = AI_OPTIMA_LLVM_BIN_PATH;
  if (currentPath && *currentPath)
    runtimePath += ";" + std::string(currentPath);
  _putenv_s("PATH", runtimePath.c_str());
#endif
  // The execution engine needs a registered machine-code target even when
  // the LLVM libraries were built statically (as in the project setup).
  if (llvm::InitializeNativeTarget()) {
    llvm::errs() << "Failed to initialize the native LLVM target\n";
    return 1;
  }
  if (llvm::InitializeNativeTargetAsmPrinter()) {
    llvm::errs() << "Failed to initialize the native LLVM assembly printer\n";
    return 1;
  }

  // Register LLVM IR translations.
  registerBuiltinDialectTranslation(*module->getContext());
  registerLLVMDialectTranslation(*module->getContext());

  // Create the execution engine.
  auto optPipeline = makeOptimizingTransformer(
      /*optLevel=*/3, /*sizeLevel=*/0, /*targetMachine=*/nullptr);

  ExecutionEngineOptions engineOptions;
  engineOptions.transformer = optPipeline;
#if defined(AI_OPTIMA_C_RUNNER_UTILS_PATH)
  StringRef runnerUtilsPath(AI_OPTIMA_C_RUNNER_UTILS_PATH);
#if defined(AI_OPTIMA_STACK_PROBE_PATH)
  StringRef stackProbePath(AI_OPTIMA_STACK_PROBE_PATH);
  std::array<StringRef, 2> runnerUtilsPaths = {runnerUtilsPath, stackProbePath};
#else
  std::array<StringRef, 1> runnerUtilsPaths = {runnerUtilsPath};
#endif
  engineOptions.sharedLibPaths = runnerUtilsPaths;
#endif

  auto maybeEngine = ExecutionEngine::create(module, engineOptions);
  if (!maybeEngine) {
    llvm::errs() << "Failed to create ExecutionEngine: "
                 << llvm::toString(maybeEngine.takeError()) << "\n";
    return 1;
  }
  auto &engine = *maybeEngine;

  unsigned entryArgumentCount = 0;
  bool entryReturnsF32 = false;
  bool entryReturnsVoid = false;
  if (auto entry = module.lookupSymbol<LLVM::LLVMFuncOp>(entryPoint)) {
    auto functionType = entry.getFunctionType();
    entryArgumentCount = functionType.getNumParams();
    entryReturnsF32 = functionType.getReturnType().isF32();
    entryReturnsVoid = isa<LLVM::LLVMVoidType>(functionType.getReturnType());
  } else if (auto entry = module.lookupSymbol<func::FuncOp>(entryPoint)) {
    entryArgumentCount = entry.getNumArguments();
    entryReturnsF32 = entry.getNumResults() == 1 &&
                      entry.getResultTypes().front().isF32();
    entryReturnsVoid = entry.getNumResults() == 0;
  } else {
    llvm::errs() << "JIT entry point '" << entryPoint
                 << "' was not found in the input module\n";
    return 1;
  }
  bool tensorMode = sourceEntryType.getNumResults() == 1 &&
                    isa<RankedTensorType>(sourceEntryType.getResult(0)) &&
                    cast<RankedTensorType>(sourceEntryType.getResult(0)).getRank() == 2;
  if (tensorMode) {
    if (entryReturnsVoid || entryReturnsF32 ||
        (sourceEntryType.getNumInputs() != 2 && sourceEntryType.getNumInputs() != 3)) {
      llvm::errs() << "Tensor JIT supports two matrix inputs and an optional "
                      "one-dimensional bias, returning one 2D tensor.\n";
      return 1;
    }
  } else if (entryArgumentCount != 0 || (!entryReturnsVoid && !entryReturnsF32)) {
    llvm::errs() << "JIT supports zero-argument entry points returning void "
                    "or one f32, plus tensor functions with two matrices and "
                    "an optional bias.\n";
    return 1;
  }

  // Invoke the entry point function.
  llvm::errs() << "=== JIT Executing '" << entryPoint << "' ===\n";

  if (tensorMode) {
    auto lhsType = dyn_cast<RankedTensorType>(sourceEntryType.getInput(0));
    auto rhsType = dyn_cast<RankedTensorType>(sourceEntryType.getInput(1));
    if (!lhsType || !rhsType || lhsType.getRank() != 2 || rhsType.getRank() != 2 ||
        lhsType.getElementType().isF32() == false ||
        rhsType.getElementType().isF32() == false) {
      llvm::errs() << "Tensor JIT currently requires f32 matrix inputs.\n";
      return 1;
    }
    const int64_t m = lhsType.getDimSize(0);
    const int64_t k = lhsType.getDimSize(1);
    const int64_t n = rhsType.getDimSize(1);
    if (ShapedType::isDynamic(m) || ShapedType::isDynamic(k) ||
        ShapedType::isDynamic(n) || rhsType.getDimSize(0) != k || m <= 0 ||
        k <= 0 || n <= 0) {
      llvm::errs() << "Tensor JIT currently requires positive static matrix "
                      "dimensions with matching inner dimensions.\n";
      return 1;
    }
    constexpr int64_t maxTensorElements = 16 * 1024 * 1024;
    if (m > maxTensorElements / k || k > maxTensorElements / n ||
        m > maxTensorElements / n ||
        m * n > maxTensorElements / (std::max(1, static_cast<int>(iterations)) + 3)) {
      llvm::errs() << "Tensor JIT dimensions or repetition count exceed the "
                      "safe memory limit for this command-line runner.\n";
      return 1;
    }
    bool hasBias = sourceEntryType.getNumInputs() == 3;
    if (hasBias && !sourceHasRelu) {
      llvm::errs() << "Three-input tensor JIT expects matmul + bias + ReLU.\n";
      return 1;
    }
    if (hasBias) {
      auto biasType = dyn_cast<RankedTensorType>(sourceEntryType.getInput(2));
      if (!biasType || biasType.getRank() != 1 ||
          !biasType.getElementType().isF32() ||
          ShapedType::isDynamic(biasType.getDimSize(0)) ||
          biasType.getDimSize(0) != n) {
        llvm::errs() << "Tensor JIT bias must be a static f32 vector matching "
                        "the output width.\n";
        return 1;
      }
    }
    auto outputType = dyn_cast<RankedTensorType>(sourceEntryType.getResult(0));
    if (!outputType) {
      llvm::errs() << "Tensor JIT result must be a ranked tensor.\n";
      return 1;
    }
    if (outputType.getDimSize(0) != m || outputType.getDimSize(1) != n ||
        !outputType.getElementType().isF32()) {
      llvm::errs() << "Tensor JIT result must be an f32 tensor with shape MxN.\n";
      return 1;
    }

    std::vector<float> lhs(m * k), rhs(k * n), bias(hasBias ? n : 0);
    std::vector<float> expected(m * n, 0.0f);
    for (int64_t i = 0; i < m * k; ++i)
      lhs[i] = static_cast<float>((i % 13) - 6) * 0.125f;
    for (int64_t i = 0; i < k * n; ++i)
      rhs[i] = static_cast<float>((i % 11) - 5) * 0.125f;
    for (int64_t i = 0; i < n; ++i)
      if (hasBias)
        bias[i] = static_cast<float>((i % 5) - 2) * 0.25f;
    for (int64_t i = 0; i < m; ++i)
      for (int64_t j = 0; j < n; ++j) {
        float sum = 0.0f;
        for (int64_t p = 0; p < k; ++p)
          sum += lhs[i * k + p] * rhs[p * n + j];
        if (sourceHasRelu)
          sum = std::max(0.0f, sum + (hasBias ? bias[j] : 0.0f));
        expected[i * n + j] = sum;
      }

    // A plain C++ triple-loop baseline uses exactly the same generated inputs.
    std::vector<double> referenceTimings;
    referenceTimings.reserve(std::max(1, static_cast<int>(iterations)));
    std::vector<float> referenceOutput(m * n);
    volatile float referenceSink = 0.0f;
    const int runs = std::max(1, static_cast<int>(iterations));
    auto runReference = [&]() {
      std::fill(referenceOutput.begin(), referenceOutput.end(), 0.0f);
      for (int64_t i = 0; i < m; ++i)
        for (int64_t j = 0; j < n; ++j) {
          float sum = 0.0f;
          for (int64_t p = 0; p < k; ++p)
            sum += lhs[i * k + p] * rhs[p * n + j];
          if (sourceHasRelu)
            sum = std::max(0.0f, sum + (hasBias ? bias[j] : 0.0f));
          referenceOutput[i * n + j] = sum;
        }
    };
    for (int i = 0; i < 3; ++i) {
      runReference();
      referenceSink += referenceOutput[i % referenceOutput.size()];
    }
    constexpr int referenceBatch = 16;
    for (int run = 0; run < runs; ++run) {
      auto start = std::chrono::high_resolution_clock::now();
      for (int repetition = 0; repetition < referenceBatch; ++repetition) {
        runReference();
        referenceSink += referenceOutput[(run + repetition) % referenceOutput.size()];
      }
      auto end = std::chrono::high_resolution_clock::now();
      referenceTimings.push_back(
          std::chrono::duration<double, std::micro>(end - start).count() /
          referenceBatch);
    }

    MemRef2DF32 lhsDesc{lhs.data(), lhs.data(), 0, {m, k}, {k, 1}};
    MemRef2DF32 rhsDesc{rhs.data(), rhs.data(), 0, {k, n}, {n, 1}};
    MemRef1DF32 biasDesc{bias.data(), bias.data(), 0, n, 1};
    std::vector<void *> packedArgs;
    auto append2D = [&](MemRef2DF32 &d) {
      packedArgs.insert(packedArgs.end(), {&d.allocated, &d.aligned, &d.offset,
          &d.sizes[0], &d.sizes[1], &d.strides[0], &d.strides[1]});
    };
    append2D(lhsDesc);
    append2D(rhsDesc);
    if (hasBias)
      packedArgs.insert(packedArgs.end(), {&biasDesc.allocated, &biasDesc.aligned,
          &biasDesc.offset, &biasDesc.size, &biasDesc.stride});

    MemRef2DF32 outputDesc{};
    packedArgs.push_back(&outputDesc);
    for (int i = 0; i < 3; ++i) {
      if (auto error = engine->invokePacked(entryPoint, packedArgs)) {
        llvm::errs() << "JIT invocation failed: "
                     << llvm::toString(std::move(error)) << "\n";
        return 1;
      }
      // The JIT allocation comes from a different Windows runtime heap than
      // this executable. Let process teardown reclaim it instead of freeing
      // it through the wrong CRT.
      outputDesc = {};
    }
    std::vector<double> timings;
    timings.reserve(runs);
    double maxObservedError = 0.0;
    for (int i = 0; i < runs; ++i) {
      auto start = std::chrono::high_resolution_clock::now();
      auto error = engine->invokePacked(entryPoint, packedArgs);
      auto end = std::chrono::high_resolution_clock::now();
      if (error) {
        llvm::errs() << "JIT invocation failed: "
                     << llvm::toString(std::move(error)) << "\n";
        return 1;
      }
      timings.push_back(std::chrono::duration<double, std::micro>(end - start).count());
      if (!outputDesc.aligned || outputDesc.sizes[0] != m || outputDesc.sizes[1] != n) {
        llvm::errs() << "JIT returned an invalid output memref descriptor.\n";
        return 1;
      }
      double maxError = 0.0;
      for (int64_t i = 0; i < m; ++i)
        for (int64_t j = 0; j < n; ++j) {
          float actual = outputDesc.aligned[outputDesc.offset +
              i * outputDesc.strides[0] + j * outputDesc.strides[1]];
          const double error = std::abs(actual - expected[i * n + j]);
          maxError = std::max(maxError, error);
        }
      maxObservedError = std::max(maxObservedError, maxError);
      bool outsideTolerance = false;
      for (int64_t i = 0; i < m * n; ++i) {
        float actual = outputDesc.aligned[outputDesc.offset +
            (i / n) * outputDesc.strides[0] +
            (i % n) * outputDesc.strides[1]];
        if (std::abs(actual - expected[i]) >
            1.0e-4f * std::max(1.0f, std::abs(expected[i])))
          outsideTolerance = true;
      }
      if (outsideTolerance) {
        llvm::errs() << "Numerical check failed; max absolute error was "
                     << maxError << "\n";
        return 1;
      }
      outputDesc = {};
    }
    std::sort(timings.begin(), timings.end());
    std::sort(referenceTimings.begin(), referenceTimings.end());
    const double jitMedian = timings[timings.size() / 2];
    const double referenceMedian =
        referenceTimings[referenceTimings.size() / 2];
    const double gflops =
        (2.0 * m * n * k) / (jitMedian * 1000.0);
    llvm::outs() << "RESULT: PASS\nMATRIX_SHAPE: " << m << "x" << k << " * "
                 << k << "x" << n << "\nMAX_ABS_ERROR: "
                 << maxObservedError << "\n"
                 << "MEDIAN_JIT_US: " << jitMedian << "\n"
                 << "MEDIAN_CPP_REFERENCE_US: " << referenceMedian << "\n"
                 << "SPEEDUP_VS_CPP_REFERENCE: "
                 << referenceMedian / jitMedian << "x\n"
                 << "JIT_GFLOPS: " << gflops << "\n";
  } else {
    float scalarResult = 0.0f;
    std::array<void *, 1> packedResult = {&scalarResult};
    MutableArrayRef<void *> packedArgs = entryReturnsF32
                                             ? MutableArrayRef<void *>(packedResult)
                                             : MutableArrayRef<void *>();
    auto start = std::chrono::high_resolution_clock::now();
    auto invocationResult = engine->invokePacked(entryPoint, packedArgs);
    auto end = std::chrono::high_resolution_clock::now();
    if (invocationResult) {
      llvm::errs() << "JIT invocation failed: "
                   << llvm::toString(std::move(invocationResult)) << "\n";
      return 1;
    }
    auto elapsed = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
    llvm::errs() << "=== Execution completed in " << elapsed.count() << " μs ===\n";
    if (entryReturnsF32)
      llvm::outs() << "RESULT_F32: " << scalarResult << "\n";
  }

  return 0;
}

//===----------------------------------------------------------------------===//
// LLVM IR Emission
//===----------------------------------------------------------------------===//
static int emitLLVMIR(ModuleOp module) {
  // Register translations.
  registerBuiltinDialectTranslation(*module->getContext());
  registerLLVMDialectTranslation(*module->getContext());

  // Translate to LLVM IR.
  llvm::LLVMContext llvmContext;
  auto llvmModule = translateModuleToLLVMIR(module, llvmContext);
  if (!llvmModule) {
    llvm::errs() << "Failed to translate to LLVM IR\n";
    return 1;
  }

  // Print LLVM IR to stdout.
  llvmModule->print(llvm::outs(), nullptr);
  return 0;
}

//===----------------------------------------------------------------------===//
// Main
//===----------------------------------------------------------------------===//
int main(int argc, char **argv) {
  // Register all dialects.
  DialectRegistry registry;
  registry.insert<
      dlopt::DLOptDialect,
      func::FuncDialect,
      linalg::LinalgDialect,
      arith::ArithDialect,
      scf::SCFDialect,
      tensor::TensorDialect,
      memref::MemRefDialect,
      bufferization::BufferizationDialect,
      cf::ControlFlowDialect,
      LLVM::LLVMDialect
  >();

  // Register tiling interface external models.
  linalg::registerTilingInterfaceExternalModels(registry);
  tensor::registerTilingInterfaceExternalModels(registry);

  // Register bufferizable op interface external models.
  arith::registerBufferizableOpInterfaceExternalModels(registry);
  bufferization::func_ext::registerBufferizableOpInterfaceExternalModels(registry);
  cf::registerBufferizableOpInterfaceExternalModels(registry);
  linalg::registerBufferizableOpInterfaceExternalModels(registry);
  scf::registerBufferizableOpInterfaceExternalModels(registry);
  tensor::registerBufferizableOpInterfaceExternalModels(registry);

  // Register our custom passes.
  dlopt::registerDLOptPasses();

  // Register and parse command line options using MLIR's driver.
  std::string inputFile, outputFile;
  std::tie(inputFile, outputFile) =
      registerAndParseCLIOptions(argc, argv, "AI-Optima DL Optimization Tool\n", registry);

  if (!runJIT && !emitLLVM) {
    // Standard mlir-opt mode with all our dialects and passes.
    return asMainReturnCode(
        MlirOptMain(argc, argv, inputFile, outputFile, registry));
  }

  // ── JIT / Emit-LLVM mode ──────────────────────────────────────────────
  llvm::InitLLVM initLLVM(argc, argv);

  // Load the MLIR input file.
  MLIRContext context;
  context.appendDialectRegistry(registry);
  context.loadAllAvailableDialects();

  std::string errorMessage;
  auto file = openInputFile(inputFile, &errorMessage);
  if (!file) {
    llvm::errs() << "Could not open input file: " << errorMessage << "\n";
    return 1;
  }

  llvm::SourceMgr sourceMgr;
  sourceMgr.AddNewSourceBuffer(std::move(file), llvm::SMLoc());

  OwningOpRef<ModuleOp> module =
      parseSourceFile<ModuleOp>(sourceMgr, &context);
  if (!module) {
    llvm::errs() << "Error: could not parse input file\n";
    return 1;
  }

  FunctionType sourceEntryType;
  bool sourceHasRelu = false;
  if (auto sourceEntry = module->lookupSymbol<func::FuncOp>(entryPoint)) {
    sourceEntryType = sourceEntry.getFunctionType();
    sourceEntry.walk([&](dlopt::ReLUOp) { sourceHasRelu = true; });
    sourceEntry.walk([&](dlopt::FusedMatMulBiasReluOp) { sourceHasRelu = true; });
  }

  // Run the optimization pipeline if requested.
  if (runPipeline) {
    if (tileSize <= 0) {
      llvm::errs() << "Tile size must be a positive integer.\n";
      return 1;
    }
    PassManager pm(&context);
    dlopt::buildDLOptPipeline(pm, tileSize, enableFusion);

    if (failed(pm.run(*module))) {
      llvm::errs() << "Error: pass pipeline failed\n";
      return 1;
    }
  }

  // Execute the requested action.
  if (emitLLVM)
    return emitLLVMIR(*module);

  if (runJIT)
    return runJITExecution(*module, sourceEntryType, sourceHasRelu);

  // If we got here, just print the result.
  module->print(llvm::outs());
  return 0;
}
