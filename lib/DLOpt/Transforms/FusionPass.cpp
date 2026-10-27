//===----------------------------------------------------------------------===//
// DLOpt Operator Fusion Pass
//
// Implements the MLIR RewritePattern framework to fuse chains of DLOpt
// operations into single fused operations, eliminating intermediate tensor
// materializations and enabling more efficient lowering.
//
// Pattern:  dlopt.matmul → dlopt.bias_add → dlopt.relu
//           ═══════════════════════════════════════════
//                    dlopt.fused_matmul_bias_relu
//===----------------------------------------------------------------------===//

#include "DLOpt/DLOptDialect.h"
#include "DLOpt/DLOptOps.h"
#include "DLOpt/Passes.h"

#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

using namespace mlir;
using namespace mlir::dlopt;

namespace {

//===----------------------------------------------------------------------===//
// Pattern: MatMul + BiasAdd + ReLU → FusedMatMulBiasRelu
//===----------------------------------------------------------------------===//
/// Matches a chain of: dlopt.matmul → dlopt.bias_add → dlopt.relu
/// and replaces it with a single dlopt.fused_matmul_bias_relu operation.
///
/// Conditions for fusion:
///   1. ReLU's input must come from a BiasAdd op.
///   2. BiasAdd's input must come from a MatMul op.
///   3. All intermediate results must have exactly one use (to avoid
///      introducing redundant computation).
struct FuseMatMulBiasReluPattern : public OpRewritePattern<ReLUOp> {
  using OpRewritePattern<ReLUOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ReLUOp reluOp,
                                PatternRewriter &rewriter) const override {
    // ── Step 1: Walk up the use-def chain ──────────────────────────────
    // Check that ReLU's input is produced by a BiasAdd.
    auto biasAddOp = reluOp.getInput().getDefiningOp<BiasAddOp>();
    if (!biasAddOp)
      return failure();

    // Check that BiasAdd's input is produced by a MatMul.
    auto matmulOp = biasAddOp.getInput().getDefiningOp<MatMulOp>();
    if (!matmulOp)
      return failure();

    // ── Step 2: Verify single-use constraint ───────────────────────────
    // Intermediate results must have exactly one use. If BiasAdd or MatMul
    // results are used elsewhere, fusing would either duplicate computation
    // or break those other uses.
    if (!matmulOp.getResult().hasOneUse())
      return failure();

    if (!biasAddOp.getResult().hasOneUse())
      return failure();

    // ── Step 3: Create the fused operation ─────────────────────────────
    rewriter.replaceOpWithNewOp<FusedMatMulBiasReluOp>(
        reluOp,
        reluOp.getResult().getType(), // Result type (same as ReLU output)
        matmulOp.getLhs(),            // Matrix A
        matmulOp.getRhs(),            // Matrix B
        biasAddOp.getBias()           // Bias vector
    );

    // The BiasAdd and MatMul ops are now dead (no remaining uses) and will
    // be cleaned up automatically by the greedy rewrite driver.
    return success();
  }
};

//===----------------------------------------------------------------------===//
// Pattern: MatMul + BiasAdd → partial fusion (without ReLU)
//===----------------------------------------------------------------------===//
/// For cases where BiasAdd follows MatMul but there is no ReLU, we keep
/// them separate. This is a future extension point.

//===----------------------------------------------------------------------===//
// Pass definition
//===----------------------------------------------------------------------===//
struct DLOptFusionPass
    : public PassWrapper<DLOptFusionPass, OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(DLOptFusionPass)

  StringRef getArgument() const override { return "dlopt-fusion"; }

  StringRef getDescription() const override {
    return "Fuse DLOpt operator chains (MatMul+BiasAdd+ReLU → "
           "FusedMatMulBiasRelu)";
  }

  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<dlopt::DLOptDialect>();
  }

  void runOnOperation() override {
    RewritePatternSet patterns(&getContext());
    patterns.add<FuseMatMulBiasReluPattern>(&getContext());

    // The greedy driver applies patterns until convergence (fixpoint).
    // It also removes trivially dead operations.
    if (failed(applyPatternsAndFoldGreedily(getOperation(),
                                            std::move(patterns)))) {
      signalPassFailure();
    }
  }
};

} // namespace

//===----------------------------------------------------------------------===//
// Pass creation entry point
//===----------------------------------------------------------------------===//
std::unique_ptr<Pass> mlir::dlopt::createDLOptFusionPass() {
  return std::make_unique<DLOptFusionPass>();
}
