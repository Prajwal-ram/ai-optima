//===----------------------------------------------------------------------===//
// DLOpt Pass Registration
//
// Registers all custom passes with the MLIR pass infrastructure so they
// can be invoked via command-line flags (e.g., --dlopt-fusion).
//===----------------------------------------------------------------------===//

#include "DLOpt/Passes.h"

#include "mlir/Pass/PassManager.h"
#include "mlir/Pass/PassRegistry.h"

using namespace mlir;
using namespace mlir::dlopt;

void mlir::dlopt::registerDLOptPasses() {
  // Register individual passes.
  registerPass([] { return createDLOptFusionPass(); });
  registerPass([] { return createDLOptTilingPass(); });
  registerPass([] { return createLowerDLOptToLinalgPass(); });

  // Register the full pipeline as a named pipeline.
  PassPipelineRegistration<>(
      "dlopt-pipeline",
      "Run the full DLOpt optimization and lowering pipeline "
      "(DLOpt -> Linalg -> Bufferize -> Loops -> LLVM)",
      [](OpPassManager &pm) { buildDLOptPipeline(pm); });
}
