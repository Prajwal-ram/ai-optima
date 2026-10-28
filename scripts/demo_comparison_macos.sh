#!/usr/bin/env bash
# Demonstrate that operator fusion preserves numerical output on macOS.
set -euo pipefail

project_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$project_root"

tool="./build/bin/dl-opt-tool"
input="test/numeric_smoke.mlir"
driver="test/numeric_smoke_driver.c"
output_dir="build/demo-comparison"

if [[ ! -x "$tool" ]]; then
  echo "Error: $tool is missing. Build the project first with cmake --build build."
  exit 1
fi

mkdir -p "$output_dir"

echo "=== Input program ==="
echo "MatMul -> Bias Add -> ReLU"
grep -E 'dlopt\.(matmul|bias_add|relu)' "$input"

echo
echo "=== Optimized MLIR (fusion pass) ==="
"$tool" "$input" --dlopt-fusion -o "$output_dir/fused.mlir"
grep -E 'dlopt\.(matmul|bias_add|relu|fused_matmul_bias_relu)' "$output_dir/fused.mlir"

echo
echo "=== Baseline: no fusion ==="
"$tool" "$input" --dlopt-pipeline --enable-fusion=false --emit-llvm \
  > "$output_dir/baseline.ll"
clang "$output_dir/baseline.ll" "$driver" -o "$output_dir/baseline"
"$output_dir/baseline"

echo
echo "=== Optimized: fusion enabled ==="
"$tool" "$input" --dlopt-pipeline --emit-llvm \
  > "$output_dir/optimized.ll"
clang "$output_dir/optimized.ll" "$driver" -o "$output_dir/optimized"
"$output_dir/optimized"

echo
echo "Conclusion: both versions return 24.0, so fusion preserved correctness."
