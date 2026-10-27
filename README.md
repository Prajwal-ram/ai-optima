# AI-Optima — MLIR Optimization Compiler Prototype

AI-Optima is an educational compiler prototype built on MLIR. It defines a small
`dlopt` dialect for matrix multiplication, bias addition and ReLU, demonstrates
operator fusion, and lowers operations through Linalg and LLVM dialects.

**Project status:** the command-line compiler builds, the fusion example runs,
and the full sample pipeline lowers to LLVM dialect. This repository has no web
frontend or application backend. It is a compiler tool, not a deployed inference
service. The `--run` JIT option supports zero-argument scalar-check entry points
and statically shaped `f32` functions with two matrix inputs, optionally with a
bias vector and ReLU. The runner creates deterministic inputs and checks every
output element against a C++ reference; it is a demonstration harness, not a
general model-serving API.

The older benchmark files measure separate handwritten C++ and NumPy/BLAS
examples. The new `scripts/benchmark_mlir.ps1` measures JIT-generated
AI-Optima kernels against a same-input C++ reference. Current exploratory
results are slower than the reference; they are correctness/performance
baselines, not evidence of a speedup.

## Architecture

```
DLOpt Dialect  ──►  Operator Fusion  ──►  Linalg Dialect  ──►  Tiling
     │                                                            │
     │                                                            ▼
     │                                                    SCF loops
     │                                                            │
     ▼                                                            ▼
 Input .mlir                                              LLVM Dialect
                                                                  │
                                                                  ▼
                                                          LLVM IR (optional export)
```

## Custom Dialect: `dlopt`

| Operation | Description |
|-----------|-------------|
| `dlopt.matmul` | Matrix multiplication of two 2D tensors |
| `dlopt.relu` | Element-wise ReLU activation |
| `dlopt.bias_add` | Add bias vector to a 2D tensor |
| `dlopt.fused_matmul_bias_relu` | Fused matmul + bias + relu (post-optimization) |

## Optimization Passes

1. **Operator Fusion** (`--dlopt-fusion`): Fuses `matmul → bias_add → relu` into
   a single `fused_matmul_bias_relu` operation, eliminating intermediate tensors.
2. **Loop Tiling** (`--dlopt-tiling`): Tiles matrix operations for L2 cache
   locality (64×64×64 default tile size).
3. **Full Pipeline** (`--dlopt-pipeline`): Runs fusion, lowering, tiling,
   bufferization and conversion to LLVM dialect. This emits compiler IR; it
   does not currently produce or run a standalone executable.

## Prerequisites

- CMake ≥ 3.20
- Ninja build system
- Visual Studio 2022 Build Tools (or MSVC compiler)
- LLVM 18.1.8 built with MLIR enabled
- Python 3.10+ (for benchmarks)

## Build Instructions

### Step 1: Build LLVM/MLIR (one-time)

```powershell
.\scripts\build_llvm.ps1
```

### Step 2: Build AI-Optima

```powershell
.\scripts\build_project.ps1
```

### Step 3: Try the compiler

```powershell
# Apply optimization passes
.\build\bin\dl-opt-tool.exe test\fusion_test.mlir --dlopt-pipeline

# Run the reproducible exhibition demo
.\scripts\run_demo.ps1

# Benchmark generated matmul and matmul+bias+ReLU code against the C++ reference
.\scripts\benchmark_mlir.ps1
.\scripts\benchmark_mlir.ps1 -Dense

# Run the fixed-input numerical smoke example (expected result: 24)
.\build\bin\dl-opt-tool.exe test\numeric_smoke.mlir --dlopt-pipeline --run --entry-point=aioptima_check

# Run a runtime-input matmul+bias+ReLU example and compare every output value
.\build\bin\dl-opt-tool.exe test\runtime_dense.mlir --dlopt-pipeline --run --entry-point=runtime_dense --tile-size=16 --iterations=15

# Plot the latest matmul and dense benchmark CSV files
python .\scripts\plot_mlir_benchmark.py

# Emit LLVM IR
.\build\bin\dl-opt-tool.exe test\matmul_simple.mlir --dlopt-pipeline --emit-llvm

# Inspect CLI options
.\build\bin\dl-opt-tool.exe --help
```

## Project Structure

```
ai-optima/
├── include/DLOpt/          # Dialect definition (TableGen + headers)
├── lib/DLOpt/              # Dialect implementation
│   └── Transforms/         # Optimization and lowering passes
├── tools/dl-opt-tool/      # CLI entry point
├── test/                   # MLIR test files
├── benchmarks/             # Benchmark harnesses
└── scripts/                # Build and setup scripts
```

## Exhibition readiness

This is a **compiler construction / MLIR optimization** project with a runtime
tensor demo and exploratory measurements of JIT-generated code. Results depend
on hardware and build; on the checked machine, the JIT path was slower for most
measured sizes. The project has no frontend/backend application. See
[`PROJECT_GUIDE.md`](PROJECT_GUIDE.md) for a plain-language walkthrough, demo
script, honest limitations, and a prioritized path to an exhibition-ready
project.

## License

Educational / Research project.
