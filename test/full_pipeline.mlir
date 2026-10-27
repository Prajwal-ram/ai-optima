// ===----------------------------------------------------------------------===//
// Test: Full Pipeline
// Tests the complete DLOpt → LLVM lowering pipeline on a realistic example:
// a single fully-connected layer (MatMul + BiasAdd + ReLU).
//
// RUN: dl-opt-tool %s --dlopt-pipeline | FileCheck %s
// ===----------------------------------------------------------------------===//

// A single dense layer: output = ReLU(input × weights + bias)
func.func @dense_layer(%input: tensor<32x128xf32>,
                        %weights: tensor<128x64xf32>,
                        %bias: tensor<64xf32>) -> tensor<32x64xf32> {
  %0 = dlopt.matmul %input, %weights
      : tensor<32x128xf32>, tensor<128x64xf32> -> tensor<32x64xf32>
  %1 = dlopt.bias_add %0, %bias
      : tensor<32x64xf32>, tensor<64xf32> -> tensor<32x64xf32>
  %2 = dlopt.relu %1 : tensor<32x64xf32>
  return %2 : tensor<32x64xf32>
}

// After the full pipeline, everything should be in the LLVM dialect:
// CHECK-LABEL: llvm.func @dense_layer
// CHECK-NOT: dlopt.
// CHECK-NOT: linalg.
// CHECK-NOT: tensor.
// CHECK: llvm.return

// ===----------------------------------------------------------------------===//
// Two-layer MLP for more comprehensive testing.
// ===----------------------------------------------------------------------===//

func.func @two_layer_mlp(%input: tensor<32x784xf32>,
                          %w1: tensor<784x256xf32>,
                          %b1: tensor<256xf32>,
                          %w2: tensor<256x10xf32>,
                          %b2: tensor<10xf32>) -> tensor<32x10xf32> {
  // Layer 1: 784 → 256
  %h1_mm = dlopt.matmul %input, %w1
      : tensor<32x784xf32>, tensor<784x256xf32> -> tensor<32x256xf32>
  %h1_bias = dlopt.bias_add %h1_mm, %b1
      : tensor<32x256xf32>, tensor<256xf32> -> tensor<32x256xf32>
  %h1 = dlopt.relu %h1_bias : tensor<32x256xf32>

  // Layer 2: 256 → 10
  %h2_mm = dlopt.matmul %h1, %w2
      : tensor<32x256xf32>, tensor<256x10xf32> -> tensor<32x10xf32>
  %h2_bias = dlopt.bias_add %h2_mm, %b2
      : tensor<32x10xf32>, tensor<10xf32> -> tensor<32x10xf32>
  %output = dlopt.relu %h2_bias : tensor<32x10xf32>

  return %output : tensor<32x10xf32>
}
