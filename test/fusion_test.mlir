
// ===----------------------------------------------------------------------===//
// Test: Operator Fusion
// Tests that matmul → bias_add → relu is fused into fused_matmul_bias_relu.
//
// RUN: dl-opt-tool %s --dlopt-fusion | FileCheck %s
// ===----------------------------------------------------------------------===//

func.func @matmul_bias_relu(%A: tensor<128x64xf32>,
                             %B: tensor<64x256xf32>,
                             %bias: tensor<256xf32>) -> tensor<128x256xf32> {
  // This chain should be fused into a single operation.
  %0 = dlopt.matmul %A, %B : tensor<128x64xf32>, tensor<64x256xf32>
                               -> tensor<128x256xf32>
  %1 = dlopt.bias_add %0, %bias : tensor<128x256xf32>, tensor<256xf32>
                                   -> tensor<128x256xf32>
  %2 = dlopt.relu %1 : tensor<128x256xf32>
  return %2 : tensor<128x256xf32>
}

// Verify fusion occurs:
// CHECK-LABEL: func @matmul_bias_relu
// CHECK: dlopt.fused_matmul_bias_relu
// CHECK-NOT: dlopt.matmul
// CHECK-NOT: dlopt.bias_add
// CHECK-NOT: dlopt.relu

// ===----------------------------------------------------------------------===//
// Test: Fusion should NOT occur when intermediate values have multiple uses.
// ===----------------------------------------------------------------------===//

func.func @no_fusion_multi_use(%A: tensor<128x64xf32>,
                                %B: tensor<64x256xf32>,
                                %bias: tensor<256xf32>)
    -> (tensor<128x256xf32>, tensor<128x256xf32>) {
  %0 = dlopt.matmul %A, %B : tensor<128x64xf32>, tensor<64x256xf32>
                               -> tensor<128x256xf32>
  %1 = dlopt.bias_add %0, %bias : tensor<128x256xf32>, tensor<256xf32>
                                   -> tensor<128x256xf32>
  %2 = dlopt.relu %1 : tensor<128x256xf32>
  // %0 (matmul result) is used twice — fusion should NOT happen.
  return %2, %0 : tensor<128x256xf32>, tensor<128x256xf32>
}

// CHECK-LABEL: func @no_fusion_multi_use
// CHECK: dlopt.matmul
// CHECK: dlopt.bias_add
// CHECK: dlopt.relu
// CHECK-NOT: dlopt.fused_matmul_bias_relu
