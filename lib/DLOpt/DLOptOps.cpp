//===----------------------------------------------------------------------===//
// DLOpt Operations Implementation
//
// Contains verifiers for operations that need semantic validation beyond
// what TableGen can express.
//===----------------------------------------------------------------------===//

#include "DLOpt/DLOptOps.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/OpImplementation.h"

using namespace mlir;
using namespace mlir::dlopt;

//===----------------------------------------------------------------------===//
// Include the auto-generated op definitions.
//===----------------------------------------------------------------------===//
#define GET_OP_CLASSES
#include "DLOpt/DLOptOps.cpp.inc"

//===----------------------------------------------------------------------===//
// MatMulOp Verifier
//===----------------------------------------------------------------------===//
LogicalResult MatMulOp::verify() {
  auto lhsType = cast<RankedTensorType>(getLhs().getType());
  auto rhsType = cast<RankedTensorType>(getRhs().getType());
  auto resultType = cast<RankedTensorType>(getResult().getType());

  // Both inputs must be 2D.
  if (lhsType.getRank() != 2 || rhsType.getRank() != 2)
    return emitOpError("operands must be 2D tensors, got rank ")
           << lhsType.getRank() << " and " << rhsType.getRank();

  // Result must be 2D.
  if (resultType.getRank() != 2)
    return emitOpError("result must be a 2D tensor, got rank ")
           << resultType.getRank();

  // Inner dimensions must match: LHS[M,K] x RHS[K,N] = Result[M,N].
  int64_t lhsK = lhsType.getDimSize(1);
  int64_t rhsK = rhsType.getDimSize(0);
  if (!ShapedType::isDynamic(lhsK) && !ShapedType::isDynamic(rhsK) &&
      lhsK != rhsK)
    return emitOpError("inner dimensions must match: LHS has ")
           << lhsK << " but RHS has " << rhsK;

  // Result dimensions must match outer dimensions.
  int64_t expectedM = lhsType.getDimSize(0);
  int64_t expectedN = rhsType.getDimSize(1);
  int64_t resultM = resultType.getDimSize(0);
  int64_t resultN = resultType.getDimSize(1);

  if (!ShapedType::isDynamic(expectedM) && !ShapedType::isDynamic(resultM) &&
      expectedM != resultM)
    return emitOpError("result M dimension mismatch: expected ")
           << expectedM << " but got " << resultM;

  if (!ShapedType::isDynamic(expectedN) && !ShapedType::isDynamic(resultN) &&
      expectedN != resultN)
    return emitOpError("result N dimension mismatch: expected ")
           << expectedN << " but got " << resultN;

  // Element types must match.
  if (lhsType.getElementType() != rhsType.getElementType() ||
      lhsType.getElementType() != resultType.getElementType())
    return emitOpError("all operands and result must have the same element type");

  return success();
}

//===----------------------------------------------------------------------===//
// BiasAddOp Verifier
//===----------------------------------------------------------------------===//
LogicalResult BiasAddOp::verify() {
  auto inputType = cast<RankedTensorType>(getInput().getType());
  auto biasType = cast<RankedTensorType>(getBias().getType());
  auto resultType = cast<RankedTensorType>(getResult().getType());

  // Input must be 2D, bias must be 1D.
  if (inputType.getRank() != 2)
    return emitOpError("input must be a 2D tensor, got rank ")
           << inputType.getRank();

  if (biasType.getRank() != 1)
    return emitOpError("bias must be a 1D tensor, got rank ")
           << biasType.getRank();

  // Bias length must match input's last dimension.
  int64_t inputN = inputType.getDimSize(1);
  int64_t biasLen = biasType.getDimSize(0);
  if (!ShapedType::isDynamic(inputN) && !ShapedType::isDynamic(biasLen) &&
      inputN != biasLen)
    return emitOpError("bias length (")
           << biasLen << ") must match input's last dimension (" << inputN
           << ")";

  // Result shape must match input shape.
  if (resultType.getShape() != inputType.getShape())
    return emitOpError("result shape must match input shape");

  if (inputType.getElementType() != biasType.getElementType() ||
      inputType.getElementType() != resultType.getElementType())
    return emitOpError("input, bias, and result must have the same element type");

  return success();
}

//===----------------------------------------------------------------------===//
// FusedMatMulBiasReluOp Verifier
//===----------------------------------------------------------------------===//
LogicalResult FusedMatMulBiasReluOp::verify() {
  auto lhsType = cast<RankedTensorType>(getLhs().getType());
  auto rhsType = cast<RankedTensorType>(getRhs().getType());
  auto biasType = cast<RankedTensorType>(getBias().getType());
  auto resultType = cast<RankedTensorType>(getResult().getType());

  // LHS and RHS must be 2D, bias must be 1D.
  if (lhsType.getRank() != 2 || rhsType.getRank() != 2)
    return emitOpError("LHS and RHS must be 2D tensors");

  if (biasType.getRank() != 1)
    return emitOpError("bias must be a 1D tensor");

  // Inner dimensions of matmul must match.
  int64_t lhsK = lhsType.getDimSize(1);
  int64_t rhsK = rhsType.getDimSize(0);
  if (!ShapedType::isDynamic(lhsK) && !ShapedType::isDynamic(rhsK) &&
      lhsK != rhsK)
    return emitOpError("matmul inner dimensions must match");

  // Bias length must match RHS columns (output N dimension).
  int64_t rhsN = rhsType.getDimSize(1);
  int64_t biasLen = biasType.getDimSize(0);
  if (!ShapedType::isDynamic(rhsN) && !ShapedType::isDynamic(biasLen) &&
      rhsN != biasLen)
    return emitOpError("bias length must match output N dimension");

  // Result must be 2D with shape [M, N].
  if (resultType.getRank() != 2)
    return emitOpError("result must be a 2D tensor");

  int64_t lhsM = lhsType.getDimSize(0);
  int64_t resultM = resultType.getDimSize(0);
  int64_t resultN = resultType.getDimSize(1);
  if ((!ShapedType::isDynamic(lhsM) && !ShapedType::isDynamic(resultM) &&
       lhsM != resultM) ||
      (!ShapedType::isDynamic(rhsN) && !ShapedType::isDynamic(resultN) &&
       rhsN != resultN))
    return emitOpError("result shape must match matrix output [M, N]");

  if (lhsType.getElementType() != rhsType.getElementType() ||
      lhsType.getElementType() != biasType.getElementType() ||
      lhsType.getElementType() != resultType.getElementType())
    return emitOpError("all operands and result must have the same element type");

  return success();
}
