// JIT entry point for runtime matmul + bias + ReLU validation.
func.func @runtime_dense(%lhs: tensor<2x3xf32>,
                         %rhs: tensor<3x2xf32>,
                         %bias: tensor<2xf32>) -> tensor<2x2xf32> {
  %product = dlopt.matmul %lhs, %rhs
      : tensor<2x3xf32>, tensor<3x2xf32> -> tensor<2x2xf32>
  %biased = dlopt.bias_add %product, %bias
      : tensor<2x2xf32>, tensor<2xf32> -> tensor<2x2xf32>
  %result = dlopt.relu %biased : tensor<2x2xf32>
  return %result : tensor<2x2xf32>
}
