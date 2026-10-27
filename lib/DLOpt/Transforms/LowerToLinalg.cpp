//===----------------------------------------------------------------------===//
// DLOpt → Linalg Lowering Pass
//
// Converts DLOpt dialect operations to equivalent Linalg dialect operations.
// This is the first stage of the lowering pipeline:
//
//   dlopt.matmul              →  linalg.matmul
//   dlopt.relu                →  linalg.generic { max(0, x) }
//   dlopt.bias_add            →  linalg.generic { x + bias }
//   dlopt.fused_matmul_bias_relu →  linalg.matmul + linalg.generic { relu(x + bias) }
//
// After this pass, the IR contains only standard MLIR dialects and can be
// further lowered through the standard pipeline.
//===----------------------------------------------------------------------===//

#include "DLOpt/DLOptDialect.h"
#include "DLOpt/DLOptOps.h"
#include "DLOpt/Passes.h"

#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/Tensor/IR/Tensor.h"
#include "mlir/IR/AffineMap.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/Transforms/DialectConversion.h"

using namespace mlir;
using namespace mlir::dlopt;

namespace {

//===----------------------------------------------------------------------===//
// MatMulOp → linalg.matmul
//===----------------------------------------------------------------------===//
struct MatMulOpLowering : public OpConversionPattern<MatMulOp> {
  using OpConversionPattern<MatMulOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(MatMulOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto loc = op.getLoc();
    auto resultType = cast<RankedTensorType>(op.getResult().getType());
    auto elemType = resultType.getElementType();

    // Create an empty output tensor: tensor<MxNxf32>
    Value emptyTensor = rewriter.create<tensor::EmptyOp>(
        loc, resultType.getShape(), elemType);

    // Fill it with zeros (matmul accumulates into this).
    Value zero = rewriter.create<arith::ConstantOp>(
        loc, rewriter.getZeroAttr(elemType));
    Value filled =
        rewriter.create<linalg::FillOp>(loc, zero, emptyTensor).result();

    // Create linalg.matmul: C = A × B + C_init(zeros)
    Value result =
        rewriter
            .create<linalg::MatmulOp>(
                loc, resultType,
                /*inputs=*/ValueRange{adaptor.getLhs(), adaptor.getRhs()},
                /*outputs=*/ValueRange{filled})
            .getResult(0);

    rewriter.replaceOp(op, result);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// ReLUOp → linalg.generic { max(0, x) }
//===----------------------------------------------------------------------===//
struct ReLUOpLowering : public OpConversionPattern<ReLUOp> {
  using OpConversionPattern<ReLUOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(ReLUOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto loc = op.getLoc();
    auto inputType = cast<RankedTensorType>(op.getInput().getType());
    auto elemType = inputType.getElementType();
    int64_t rank = inputType.getRank();

    // Create an empty output tensor with the same shape.
    Value emptyTensor = rewriter.create<tensor::EmptyOp>(
        loc, inputType.getShape(), elemType);

    // Build identity indexing maps for element-wise operation.
    SmallVector<AffineMap> indexingMaps(
        2, rewriter.getMultiDimIdentityMap(rank));

    SmallVector<utils::IteratorType> iteratorTypes(
        rank, utils::IteratorType::parallel);

    // linalg.generic that applies max(0, x) element-wise.
    auto genericOp = rewriter.create<linalg::GenericOp>(
        loc, inputType,
        /*inputs=*/ValueRange{adaptor.getInput()},
        /*outputs=*/ValueRange{emptyTensor},
        indexingMaps, iteratorTypes,
        [&](OpBuilder &b, Location nestedLoc, ValueRange args) {
          Value input = args[0];
          Value zero = b.create<arith::ConstantOp>(
              nestedLoc, b.getZeroAttr(elemType));
          // IEEE 754 maximum: max(input, 0)
          Value relu = b.create<arith::MaximumFOp>(nestedLoc, input, zero);
          b.create<linalg::YieldOp>(nestedLoc, relu);
        });

    rewriter.replaceOp(op, genericOp.getResult(0));
    return success();
  }
};

//===----------------------------------------------------------------------===//
// BiasAddOp → linalg.generic { x + bias[j] }
//===----------------------------------------------------------------------===//
struct BiasAddOpLowering : public OpConversionPattern<BiasAddOp> {
  using OpConversionPattern<BiasAddOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(BiasAddOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto loc = op.getLoc();
    auto inputType = cast<RankedTensorType>(op.getInput().getType());
    auto resultType = cast<RankedTensorType>(op.getResult().getType());
    auto elemType = inputType.getElementType();

    Value emptyTensor = rewriter.create<tensor::EmptyOp>(
        loc, resultType.getShape(), elemType);

    // Indexing maps:
    //   input:  (i, j) → (i, j)   [identity for 2D tensor]
    //   bias:   (i, j) → (j)      [broadcast along rows]
    //   output: (i, j) → (i, j)   [identity for 2D output]
    auto ctx = rewriter.getContext();
    SmallVector<AffineMap> indexingMaps = {
        rewriter.getMultiDimIdentityMap(2),                          // input
        AffineMap::get(2, 0, rewriter.getAffineDimExpr(1), ctx),     // bias
        rewriter.getMultiDimIdentityMap(2)                           // output
    };

    SmallVector<utils::IteratorType> iteratorTypes = {
        utils::IteratorType::parallel,  // i (rows)
        utils::IteratorType::parallel   // j (columns)
    };

    auto genericOp = rewriter.create<linalg::GenericOp>(
        loc, resultType,
        /*inputs=*/ValueRange{adaptor.getInput(), adaptor.getBias()},
        /*outputs=*/ValueRange{emptyTensor},
        indexingMaps, iteratorTypes,
        [&](OpBuilder &b, Location nestedLoc, ValueRange args) {
          Value inputVal = args[0];
          Value biasVal = args[1];
          Value sum = b.create<arith::AddFOp>(nestedLoc, inputVal, biasVal);
          b.create<linalg::YieldOp>(nestedLoc, sum);
        });

    rewriter.replaceOp(op, genericOp.getResult(0));
    return success();
  }
};

//===----------------------------------------------------------------------===//
// FusedMatMulBiasReluOp → linalg.matmul + linalg.generic { relu(x + bias) }
//===----------------------------------------------------------------------===//
/// The fused operation is lowered to two linalg operations:
///   1. linalg.matmul for the matrix multiply
///   2. linalg.generic that combines bias addition and ReLU in a single kernel
///
/// This is still more efficient than 3 separate ops because steps 2 combines
/// the bias add and ReLU, keeping the matmul result in cache.
struct FusedMatMulBiasReluOpLowering
    : public OpConversionPattern<FusedMatMulBiasReluOp> {
  using OpConversionPattern<FusedMatMulBiasReluOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(FusedMatMulBiasReluOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto loc = op.getLoc();
    auto resultType = cast<RankedTensorType>(op.getResult().getType());
    auto elemType = resultType.getElementType();

    // ── Step 1: MatMul ─────────────────────────────────────────────────
    Value emptyMatmul = rewriter.create<tensor::EmptyOp>(
        loc, resultType.getShape(), elemType);
    Value zero = rewriter.create<arith::ConstantOp>(
        loc, rewriter.getZeroAttr(elemType));
    Value filledMatmul =
        rewriter.create<linalg::FillOp>(loc, zero, emptyMatmul).result();

    Value matmulResult =
        rewriter
            .create<linalg::MatmulOp>(
                loc, resultType,
                ValueRange{adaptor.getLhs(), adaptor.getRhs()},
                ValueRange{filledMatmul})
            .getResult(0);

    // ── Step 2: BiasAdd + ReLU (fused in one linalg.generic) ───────────
    Value emptyOutput = rewriter.create<tensor::EmptyOp>(
        loc, resultType.getShape(), elemType);

    auto ctx = rewriter.getContext();
    SmallVector<AffineMap> indexingMaps = {
        rewriter.getMultiDimIdentityMap(2),                      // matmul result
        AffineMap::get(2, 0, rewriter.getAffineDimExpr(1), ctx), // bias (broadcast)
        rewriter.getMultiDimIdentityMap(2)                       // output
    };

    SmallVector<utils::IteratorType> iteratorTypes = {
        utils::IteratorType::parallel,
        utils::IteratorType::parallel
    };

    auto genericOp = rewriter.create<linalg::GenericOp>(
        loc, resultType,
        /*inputs=*/ValueRange{matmulResult, adaptor.getBias()},
        /*outputs=*/ValueRange{emptyOutput},
        indexingMaps, iteratorTypes,
        [&](OpBuilder &b, Location nestedLoc, ValueRange args) {
          Value matmulVal = args[0];
          Value biasVal = args[1];
          // Fused: relu(matmul_result + bias)
          Value added = b.create<arith::AddFOp>(nestedLoc, matmulVal, biasVal);
          Value zeroVal = b.create<arith::ConstantOp>(
              nestedLoc, b.getZeroAttr(elemType));
          Value activated =
              b.create<arith::MaximumFOp>(nestedLoc, added, zeroVal);
          b.create<linalg::YieldOp>(nestedLoc, activated);
        });

    rewriter.replaceOp(op, genericOp.getResult(0));
    return success();
  }
};

//===----------------------------------------------------------------------===//
// Pass definition
//===----------------------------------------------------------------------===//
struct LowerDLOptToLinalgPass
    : public PassWrapper<LowerDLOptToLinalgPass, OperationPass<ModuleOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(LowerDLOptToLinalgPass)

  StringRef getArgument() const override { return "dlopt-lower-to-linalg"; }

  StringRef getDescription() const override {
    return "Lower DLOpt dialect operations to Linalg dialect";
  }

  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<linalg::LinalgDialect, arith::ArithDialect,
                    tensor::TensorDialect, func::FuncDialect>();
  }

  void runOnOperation() override {
    MLIRContext *ctx = &getContext();

    // Define the conversion target: DLOpt ops are illegal, everything else
    // is legal.
    ConversionTarget target(*ctx);
    target.addIllegalDialect<dlopt::DLOptDialect>();
    target.addLegalDialect<linalg::LinalgDialect, arith::ArithDialect,
                           tensor::TensorDialect, func::FuncDialect>();

    // Register all lowering patterns.
    RewritePatternSet patterns(ctx);
    patterns.add<MatMulOpLowering, ReLUOpLowering, BiasAddOpLowering,
                 FusedMatMulBiasReluOpLowering>(ctx);

    if (failed(
            applyPartialConversion(getOperation(), target, std::move(patterns))))
      signalPassFailure();
  }
};

} // namespace

//===----------------------------------------------------------------------===//
// Pass creation entry point
//===----------------------------------------------------------------------===//
std::unique_ptr<Pass> mlir::dlopt::createLowerDLOptToLinalgPass() {
  return std::make_unique<LowerDLOptToLinalgPass>();
}
