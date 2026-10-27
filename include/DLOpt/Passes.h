//===----------------------------------------------------------------------===//
// DLOpt Pass Declarations
//
// Declares all custom transformation and lowering passes for the DLOpt
// dialect, plus a helper to build the full optimization pipeline.
//===----------------------------------------------------------------------===//

#ifndef DLOPT_PASSES_H
#define DLOPT_PASSES_H

#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"
#include <memory>

namespace mlir {
class ModuleOp;
namespace func {
class FuncOp;
} // namespace func

namespace dlopt {

//===----------------------------------------------------------------------===//
// Optimization Passes
//===----------------------------------------------------------------------===//

/// Creates the operator fusion pass.
/// Fuses MatMul + BiasAdd + ReLU into FusedMatMulBiasRelu.
std::unique_ptr<Pass> createDLOptFusionPass();

/// Creates the loop tiling pass for matrix operations.
/// @param tileSize The tile dimension (default: 64 for L2 cache optimization).
std::unique_ptr<Pass> createDLOptTilingPass(int64_t tileSize = 64);

//===----------------------------------------------------------------------===//
// Lowering Passes
//===----------------------------------------------------------------------===//

/// Creates the pass to lower DLOpt operations to Linalg dialect.
std::unique_ptr<Pass> createLowerDLOptToLinalgPass();

//===----------------------------------------------------------------------===//
// Pipeline Construction
//===----------------------------------------------------------------------===//

/// Builds the full DLOpt optimization and lowering pipeline:
///   DLOpt → (Fusion) → Linalg → (Tiling) → Bufferize →
///   Loops → SCF → CF → LLVM
///
/// @param pm The pass manager to add passes to.
/// @param tileSize Tile size for the tiling pass (default: 64).
/// @param enableFusion Whether to enable operator fusion (default: true).
void buildDLOptPipeline(OpPassManager &pm, int64_t tileSize = 64,
                        bool enableFusion = true);

/// Registers all DLOpt passes with the MLIR pass infrastructure.
void registerDLOptPasses();

} // namespace dlopt
} // namespace mlir

#endif // DLOPT_PASSES_H
