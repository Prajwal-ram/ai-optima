//===----------------------------------------------------------------------===//
// DLOpt Loop Tiling Pass
//
// Applies loop tiling to linalg.matmul operations to improve cache locality.
// The default tile size is 64×64×64 as an educational starting point. It has
// not been tuned for a specific CPU or validated with compiler-output benchmarks.
//
// Tiling transforms:
//   for i in [0, M):
//     for j in [0, N):
//       for k in [0, K):
//         C[i,j] += A[i,k] * B[k,j]
//
// Into:
//   for ii in [0, M, tile):
//     for jj in [0, N, tile):
//       for kk in [0, K, tile):
//         for i in [ii, min(ii+tile, M)):
//           for j in [jj, min(jj+tile, N)):
//             for k in [kk, min(kk+tile, K)):
//               C[i,j] += A[i,k] * B[k,j]
//===----------------------------------------------------------------------===//

#include "DLOpt/Passes.h"

#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/Linalg/Transforms/TilingInterfaceImpl.h"
#include "mlir/Dialect/Linalg/Transforms/Transforms.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/SCF/Transforms/TileUsingInterface.h"
#include "mlir/Dialect/Tensor/IR/Tensor.h"
#include "mlir/Dialect/Tensor/IR/TensorTilingInterfaceImpl.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

using namespace mlir;

namespace {

//===----------------------------------------------------------------------===//
// Pass definition
//===----------------------------------------------------------------------===//
struct DLOptTilingPass
    : public PassWrapper<DLOptTilingPass, OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(DLOptTilingPass)

  DLOptTilingPass() = default;
  DLOptTilingPass(int64_t tileSize) : tileSizeParam(tileSize) {}

  StringRef getArgument() const override { return "dlopt-tiling"; }

  StringRef getDescription() const override {
    return "Apply loop tiling to linalg.matmul for L2 cache optimization";
  }

  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<linalg::LinalgDialect, scf::SCFDialect,
                    tensor::TensorDialect>();
    linalg::registerTilingInterfaceExternalModels(registry);
    tensor::registerTilingInterfaceExternalModels(registry);
  }

  void runOnOperation() override {
    func::FuncOp funcOp = getOperation();
    MLIRContext *ctx = &getContext();
    IRRewriter rewriter(ctx);

    int64_t ts = tileSizeParam;
    if (ts <= 0) {
      funcOp.emitError("tile size must be a positive integer");
      signalPassFailure();
      return;
    }

    // Collect all matmul operations to tile.
    // We collect first, then tile, to avoid iterator invalidation.
    SmallVector<linalg::MatmulOp> matmulOps;
    funcOp.walk([&](linalg::MatmulOp op) { matmulOps.push_back(op); });

    for (auto matmulOp : matmulOps) {
      // ── Build tile sizes ─────────────────────────────────────────────
      // MatMul has 3 loops: M (rows of A), N (cols of B), K (reduction).
      // We tile all three dimensions for optimal cache reuse.
      SmallVector<OpFoldResult> tileSizes = {
          rewriter.getIndexAttr(ts), // M tile
          rewriter.getIndexAttr(ts), // N tile
          rewriter.getIndexAttr(ts)  // K tile (reduction dimension)
      };

      scf::SCFTilingOptions options;
      options.setTileSizes(tileSizes);

      // ── Apply tiling ─────────────────────────────────────────────────
      auto tilingInterfaceOp =
          dyn_cast<TilingInterface>(matmulOp.getOperation());
      if (!tilingInterfaceOp)
        continue;

      rewriter.setInsertionPoint(matmulOp);
      FailureOr<scf::SCFTilingResult> tilingResult =
          scf::tileUsingSCFForOp(
              rewriter,
              tilingInterfaceOp,
              options);

      if (succeeded(tilingResult)) {
        // Replace the original matmul with the tiled version.
        rewriter.replaceOp(matmulOp, tilingResult->replacements);
      }
      // If tiling fails (e.g., dynamic shapes we can't handle),
      // we leave the original op unchanged and continue.
    }
  }

private:
  int64_t tileSizeParam = 64;
};

} // namespace

//===----------------------------------------------------------------------===//
// Pass creation entry point
//===----------------------------------------------------------------------===//
std::unique_ptr<Pass> mlir::dlopt::createDLOptTilingPass(int64_t tileSize) {
  return std::make_unique<DLOptTilingPass>(tileSize);
}
