// End-to-end numerical smoke case for the custom operation pipeline.
// The matrix product is [[22, 28], [49, 64]], bias is [1, -40],
// and ReLU produces [[23, 0], [50, 24]]. The returned element is 24.
func.func @aioptima_check() -> f32 {
  %lhs = arith.constant dense<[[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]]>
      : tensor<2x3xf32>
  %rhs = arith.constant dense<[[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]]>
      : tensor<3x2xf32>
  %bias = arith.constant dense<[1.0, -40.0]> : tensor<2xf32>
  %product = dlopt.matmul %lhs, %rhs
      : tensor<2x3xf32>, tensor<3x2xf32> -> tensor<2x2xf32>
  %biased = dlopt.bias_add %product, %bias
      : tensor<2x2xf32>, tensor<2xf32> -> tensor<2x2xf32>
  %activated = dlopt.relu %biased : tensor<2x2xf32>
  %one = arith.constant 1 : index
  %check = tensor.extract %activated[%one, %one] : tensor<2x2xf32>
  return %check : f32
}
