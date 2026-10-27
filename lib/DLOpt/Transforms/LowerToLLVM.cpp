//===----------------------------------------------------------------------===//
// DLOpt Full Lowering Pipeline to LLVM
//
// Builds the complete pass pipeline that takes DLOpt IR all the way down
// to the LLVM dialect, ready for conversion to LLVM IR and machine code.
//
// Pipeline stages:
//   1. DLOpt Fusion      — Fuse matmul+bias_add+relu chains
//   2. DLOpt → Linalg    — Lower DLOpt ops to linalg
//   3. Tiling            — Tile linalg.matmul for cache locality
//   4. Bufferization     — Convert tensors to memrefs (heap allocations)
//   5. Linalg → Loops    — Lower linalg ops to SCF for loops
//   6. SCF → CF          — Lower structured control flow to branches
//   7. → LLVM Dialect    — Lower arith, memref, func to LLVM dialect
//   8. Cleanup           — Reconcile unrealized casts
//===----------------------------------------------------------------------===//

#include "DLOpt/Passes.h"

#include "mlir/Conversion/AffineToStandard/AffineToStandard.h"
#include "mlir/Conversion/ArithToLLVM/ArithToLLVM.h"
#include "mlir/Conversion/ControlFlowToLLVM/ControlFlowToLLVM.h"
#include "mlir/Conversion/FuncToLLVM/ConvertFuncToLLVM.h"
#include "mlir/Conversion/FuncToLLVM/ConvertFuncToLLVMPass.h"
#include "mlir/Conversion/IndexToLLVM/IndexToLLVM.h"
#include "mlir/Conversion/LinalgToStandard/LinalgToStandard.h"
#include "mlir/Conversion/MemRefToLLVM/MemRefToLLVM.h"
#include "mlir/Conversion/ReconcileUnrealizedCasts/ReconcileUnrealizedCasts.h"
#include "mlir/Conversion/SCFToControlFlow/SCFToControlFlow.h"
#include "mlir/Dialect/Bufferization/Transforms/OneShotAnalysis.h"
#include "mlir/Dialect/Bufferization/Transforms/Passes.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Linalg/Passes.h"
#include "mlir/Dialect/MemRef/Transforms/Passes.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Transforms/Passes.h"

using namespace mlir;

namespace mlir {
namespace dlopt {

//===----------------------------------------------------------------------===//
// Pipeline builder
//===----------------------------------------------------------------------===//
void buildDLOptPipeline(OpPassManager &pm, int64_t tileSize,
                        bool enableFusion) {
  // ── Phase 1: DLOpt-level optimizations ─────────────────────────────────
  if (enableFusion) {
    pm.addNestedPass<func::FuncOp>(createDLOptFusionPass());
  }

  // Clean up after fusion.
  pm.addPass(createCSEPass());
  pm.addPass(createCanonicalizerPass());

  // ── Phase 2: Lower DLOpt → Linalg ─────────────────────────────────────
  pm.addPass(createLowerDLOptToLinalgPass());

  // ── Phase 3: Linalg-level optimizations ────────────────────────────────
  // Tile matmul operations for cache locality.
  pm.addNestedPass<func::FuncOp>(createDLOptTilingPass(tileSize));

  // Clean up after tiling.
  pm.addPass(createCanonicalizerPass());
  pm.addPass(createCSEPass());

  // ── Phase 4: Bufferization (tensor → memref) ──────────────────────────
  // Convert tensor.empty ops to alloc_tensor so they can be bufferized.
  pm.addPass(bufferization::createEmptyTensorToAllocTensorPass());

  // One-shot bufferize converts the entire module from tensor semantics
  // to buffer (memref) semantics in one pass.
  bufferization::OneShotBufferizationOptions bufOptions;
  bufOptions.bufferizeFunctionBoundaries = true;
  bufOptions.setFunctionBoundaryTypeConversion(
      bufferization::LayoutMapOption::IdentityLayoutMap);
  pm.addPass(bufferization::createOneShotBufferizePass(bufOptions));

  // Clean up bufferization artifacts.
  pm.addPass(createCanonicalizerPass());
  pm.addPass(createCSEPass());

  // ── Phase 5: Lower Linalg → Loops ──────────────────────────────────────
  pm.addNestedPass<func::FuncOp>(createConvertLinalgToLoopsPass());
  pm.addPass(createLowerAffinePass());

  // ── Phase 6: Lower SCF → CF (structured control flow → branches) ──────
  pm.addPass(createConvertSCFToCFPass());

  // ── Phase 7: Lower everything → LLVM Dialect ──────────────────────────
  pm.addPass(createConvertControlFlowToLLVMPass());
  pm.addNestedPass<func::FuncOp>(createArithToLLVMConversionPass());
  pm.addPass(memref::createExpandStridedMetadataPass());
  pm.addPass(createLowerAffinePass());
  pm.addPass(createFinalizeMemRefToLLVMConversionPass());
  pm.addPass(createConvertFuncToLLVMPass());
  pm.addPass(createConvertIndexToLLVMPass());

  // ── Phase 8: Final cleanup ─────────────────────────────────────────────
  // Remove any remaining unrealized_conversion_cast operations.
  pm.addPass(createReconcileUnrealizedCastsPass());
}

} // namespace dlopt
} // namespace mlir
