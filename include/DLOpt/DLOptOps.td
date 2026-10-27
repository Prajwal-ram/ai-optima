//===----------------------------------------------------------------------===//
// DLOpt Operations Definition (TableGen)
//
// Defines all operations in the DLOpt dialect:
//   - MatMulOp:              2D matrix multiplication
//   - ReLUOp:                Element-wise ReLU activation
//   - BiasAddOp:             Add 1D bias to 2D tensor
//   - FusedMatMulBiasReluOp: Fused MatMul + BiasAdd + ReLU
//===----------------------------------------------------------------------===//

#ifndef DLOPT_OPS_TD
#define DLOPT_OPS_TD

include "DLOptDialect.td"
include "mlir/Interfaces/InferTypeOpInterface.td"
include "mlir/Interfaces/SideEffectInterfaces.td"
include "mlir/IR/OpBase.td"

//===----------------------------------------------------------------------===//
// Base class for all DLOpt operations
//===----------------------------------------------------------------------===//

class DLOpt_Op<string mnemonic, list<Trait> traits = []>
    : Op<DLOpt_Dialect, mnemonic, traits>;

//===----------------------------------------------------------------------===//
// dlopt.matmul — Matrix Multiplication
//===----------------------------------------------------------------------===//

def DLOpt_MatMulOp : DLOpt_Op<"matmul", [Pure]> {
  let summary = "Matrix multiplication of two 2D tensors";
  let description = [{
    Computes the matrix product of two 2D tensors:
      Result[i][j] = Σ_k LHS[i][k] * RHS[k][j]

    Both inputs must be 2D ranked tensors with matching inner dimensions.
    The result is a 2D tensor of shape [M, N] where LHS is [M, K] and
    RHS is [K, N].

    Example:
    ```mlir
    %result = dlopt.matmul %A, %B : tensor<128x64xf32>, tensor<64x256xf32>
                                    -> tensor<128x256xf32>
    ```
  }];

  let arguments = (ins
    AnyRankedTensor:$lhs,
    AnyRankedTensor:$rhs
  );
  let results = (outs AnyRankedTensor:$result);

  let assemblyFormat = [{
    $lhs `,` $rhs attr-dict `:`
    type($lhs) `,` type($rhs) `->` type($result)
  }];

  let hasVerifier = 1;
}

//===----------------------------------------------------------------------===//
// dlopt.relu — Rectified Linear Unit
//===----------------------------------------------------------------------===//

def DLOpt_ReLUOp : DLOpt_Op<"relu", [Pure, SameOperandsAndResultType]> {
  let summary = "Element-wise ReLU activation function";
  let description = [{
    Applies the Rectified Linear Unit (ReLU) function element-wise:
      Result[i][j] = max(0, Input[i][j])

    Example:
    ```mlir
    %activated = dlopt.relu %input : tensor<128x256xf32>
    ```
  }];

  let arguments = (ins AnyRankedTensor:$input);
  let results = (outs AnyRankedTensor:$result);

  let assemblyFormat = [{
    $input attr-dict `:` type($input)
  }];
}

//===----------------------------------------------------------------------===//
// dlopt.bias_add — Bias Addition
//===----------------------------------------------------------------------===//

def DLOpt_BiasAddOp : DLOpt_Op<"bias_add", [Pure]> {
  let summary = "Broadcast-add a 1D bias vector to a 2D tensor";
  let description = [{
    Adds a 1D bias vector to each row of a 2D input tensor:
      Result[i][j] = Input[i][j] + Bias[j]

    The bias vector length must match the last dimension of the input tensor.

    Example:
    ```mlir
    %biased = dlopt.bias_add %input, %bias : tensor<128x256xf32>,
                                              tensor<256xf32>
                                              -> tensor<128x256xf32>
    ```
  }];

  let arguments = (ins
    AnyRankedTensor:$input,
    AnyRankedTensor:$bias
  );
  let results = (outs AnyRankedTensor:$result);

  let assemblyFormat = [{
    $input `,` $bias attr-dict `:`
    type($input) `,` type($bias) `->` type($result)
  }];

  let hasVerifier = 1;
}

//===----------------------------------------------------------------------===//
// dlopt.fused_matmul_bias_relu — Fused Operation (post-optimization)
//===----------------------------------------------------------------------===//

def DLOpt_FusedMatMulBiasReluOp
    : DLOpt_Op<"fused_matmul_bias_relu", [Pure]> {
  let summary = "Fused MatMul + BiasAdd + ReLU in a single operation";
  let description = [{
    Performs matrix multiplication, bias addition, and ReLU activation as a
    single fused operation, eliminating intermediate tensor materializations:
      Result = ReLU(MatMul(LHS, RHS) + Bias)

    This operation is produced by the operator fusion pass and is not
    intended to be written by hand. It exists as an optimization target
    that is then lowered to efficient Linalg code.

    Example:
    ```mlir
    %result = dlopt.fused_matmul_bias_relu %A, %B, %bias
        : tensor<128x64xf32>, tensor<64x256xf32>, tensor<256xf32>
          -> tensor<128x256xf32>
    ```
  }];

  let arguments = (ins
    AnyRankedTensor:$lhs,
    AnyRankedTensor:$rhs,
    AnyRankedTensor:$bias
  );
  let results = (outs AnyRankedTensor:$result);

  let assemblyFormat = [{
    $lhs `,` $rhs `,` $bias attr-dict `:`
    type($lhs) `,` type($rhs) `,` type($bias) `->` type($result)
  }];

  let hasVerifier = 1;
}

#endif // DLOPT_OPS_TD
