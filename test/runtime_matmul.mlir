// Runtime tensor entry point used by --run. Inputs are supplied by the JIT
// harness, which compares every output element with a reference matmul.
func.func @runtime_matmul(%lhs: tensor<2x3xf32>,
                          %rhs: tensor<3x2xf32>) -> tensor<2x2xf32> {
  %result = dlopt.matmul %lhs, %rhs
      : tensor<2x3xf32>, tensor<3x2xf32> -> tensor<2x2xf32>
  return %result : tensor<2x2xf32>
}
