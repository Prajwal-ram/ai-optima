// Exercises multiple tiles and partial M/N/K edge tiles with runtime inputs.
func.func @runtime_non_square(%lhs: tensor<17x19xf32>,
                              %rhs: tensor<19x13xf32>) -> tensor<17x13xf32> {
  %result = dlopt.matmul %lhs, %rhs
      : tensor<17x19xf32>, tensor<19x13xf32> -> tensor<17x13xf32>
  return %result : tensor<17x13xf32>
}
