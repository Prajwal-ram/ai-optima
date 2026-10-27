// ===----------------------------------------------------------------------===//
// Test: Simple MatMul
// Tests the basic dlopt.matmul operation and its lowering.
//
// RUN: dl-opt-tool %s --dlopt-lower-to-linalg | FileCheck %s
// ===----------------------------------------------------------------------===//

func.func @simple_matmul(%A: tensor<128x64xf32>,
                          %B: tensor<64x256xf32>) -> tensor<128x256xf32> {
  %C = dlopt.matmul %A, %B : tensor<128x64xf32>, tensor<64x256xf32>
                               -> tensor<128x256xf32>
  return %C : tensor<128x256xf32>
}

// Verify that dlopt.matmul is lowered to linalg.matmul
// CHECK-LABEL: func @simple_matmul
// CHECK: linalg.fill
// CHECK: linalg.matmul
// CHECK-NOT: dlopt.matmul
