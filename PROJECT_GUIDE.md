# AI-Optima: project and exhibition guide

## In one sentence

AI-Optima is a small MLIR compiler that recognizes a neural-network-style
`matrix multiply → bias addition → ReLU` sequence, fuses the operations, and
lowers the result into lower-level compiler representations.

## What the parts mean

- **MLIR** is a framework for representing programs at several abstraction
  levels while compiler passes transform them.
- **`dlopt` dialect** is this project's small vocabulary: `matmul`, `bias_add`,
  `relu`, and the combined `fused_matmul_bias_relu` operation.
- **Fusion** checks that the operations form the expected chain and that the
  intermediate results have no other users. It replaces the chain with the
  fused operation while preserving shared intermediate results.
- **Lowering** translates custom operations to standard MLIR Linalg/tensor
  operations, then to loops and LLVM dialect operations.
- **Tiling** divides supported Linalg matrix multiplication loops into blocks.
  The full pipeline applies tiling after custom operations have been lowered.

This is a compiler transformation demonstration. There is no browser UI, REST
API, model loader, training code, or deployed inference server in this repo.

## What has been verified here

- The local build of `dl-opt-tool.exe` ran `test/fusion_test.mlir --dlopt-fusion`:
  the single-use chain fused, and the multi-use chain remained unchanged.
- The local build of `dl-opt-tool.exe` ran `test/full_pipeline.mlir
  --dlopt-pipeline` and emitted LLVM dialect operations.
- The CLI JIT runner executes statically shaped `f32` functions with two
  runtime matrix inputs, optionally with bias and ReLU. It compares every
  output element with a plain C++ reference. The added `runtime_matmul.mlir`
  and `runtime_dense.mlir` examples both pass.
- `numeric_smoke.mlir` also runs fixed inputs through the full pipeline and
  returns the expected value 24. Runtime values are deterministic harness
  inputs; arbitrary external tensor-file input is not implemented.
- `scripts/benchmark_mlir.ps1` generates MLIR workloads for multiple sizes,
  checks every result, and records repeated-run medians for generated code and
  the same-input C++ reference. These are exploratory local measurements.
- The older `benchmarks/naive_matmul.cpp` and NumPy scripts remain separate
  baselines and are not measures of AI-Optima output.

## Exhibition recommendation

**Worth displaying as a compiler construction project**, presented as an MLIR
optimization prototype. It now executes runtime matrices and compares results
with a C++ reference. Current local measurements show the JIT pipeline slower
than that reference, so present these as correctness and measurement baselines;
do not claim a performance gain.

The strongest current live demo is: show the original custom MLIR chain, run
the fusion pass, point out the fused operation, then run the full pipeline and
show that the custom operations have become LLVM dialect operations. Explain
that this is compiler IR; the repository does not execute a deployed inference
application. The JIT demo executes static-shape tensor functions with generated
inputs.

## Suggested live demo

Run these from the `ai-optima` directory in PowerShell:

```powershell
.\build\bin\dl-opt-tool.exe .\test\fusion_test.mlir --dlopt-fusion
.\build\bin\dl-opt-tool.exe .\test\full_pipeline.mlir --dlopt-pipeline -o .\pipeline-output.mlir
.\scripts\run_demo.ps1
.\scripts\benchmark_mlir.ps1
.\scripts\benchmark_mlir.ps1 -Dense
python .\scripts\plot_mlir_benchmark.py
```

In the first output, find `dlopt.fused_matmul_bias_relu`. In the second, find
`llvm.func` and `llvm.return`; the long output is expected because the sample
is lowered into explicit low-level operations. To make the demo easier to
follow, use the small `dense_layer` function first and describe the two-layer
MLP as a larger parsing/lowering example.

The benchmark commands create `benchmarks/results/aioptima_matmul_benchmark.csv`
and `aioptima_dense_benchmark.csv`. The plotting command saves
`benchmarks/results/aioptima_mlir_benchmark.png`. Timing excludes JIT
compilation but includes the generated function call and output allocation.

## Remaining work to make it final-year-project ready

1. **General numerical execution:** add external tensor-file inputs and wider
   tests for negative values, varied shapes, and more data types. The current
   runner creates deterministic f32 inputs.
2. **Performance optimization:** use the new results to investigate why the
   generated kernels are slower, add vectorized/parallel lowering, and remeasure
   against the same reference and correctness checks.
3. **Pass evidence:** add reproducible checks for fusion, tiling, and full
   lowering, including cases where fusion must not happen and tile boundaries
   are partial.
4. **Usability:** provide one clean setup path, clear diagnostics, sample input,
   expected outputs, and a one-command demo script.
5. **Research framing:** state the problem, the method, what is novel in this
   implementation, constraints, measured results, and future work. Avoid
   claiming AVX2/vectorization or speedups unless the generated code and
   measurements demonstrate them.

## Short presentation script

> “AI-Optima explores how compiler optimizations can improve the representation
> of common neural-network operations. I defined a small MLIR dialect for matrix
> multiplication, bias addition, and ReLU. A rewrite pass fuses the chain when
> its intermediate values are used only by the next operation, so observable
> shared values are preserved. The compiler then lowers these custom operations
> through standard MLIR into LLVM dialect. Runtime matrix inputs are checked
> against a C++ reference. Current measurements establish a baseline and do
> not show a speedup; improving the generated kernel is future work.”
