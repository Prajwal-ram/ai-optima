# AI-Optima: one-day team crash course

This guide is designed for a team that has one day to understand, run, and
present the project. Work through it in order. Each person should run the demo
at least once and explain one part without reading the page.

## The project in plain language

AI-Optima is a small compiler prototype for a few neural-network-style math
operations. It takes a program written in a custom MLIR vocabulary, applies
compiler transformations, and can JIT-execute a limited set of static-shape
`f32` matrix functions.

The main example is:

```text
Y = ReLU(A × B + bias)
```

The compiler can combine the multiply, bias addition, and ReLU into one
operation, then translate that operation into lower-level representations. Its
runtime demonstration compares every output element with a straightforward
C++ reference implementation.

It is a compiler project. It does not have a web frontend, REST backend, model
training system, or general-purpose model-serving API.

## A one-day learning schedule

| Time | Session | Finish with |
|---|---|---|
| 09:00–09:30 | Read “The project in plain language” and the glossary below | Everyone can explain compiler, MLIR, dialect, and lowering simply |
| 09:30–10:15 | Set up the terminal and run the demo | Each teammate has seen every check pass |
| 10:15–11:15 | Inspect the input MLIR and fusion result | A teammate can point out what fused and why |
| 11:15–12:00 | Trace the lowering stages | A teammate can explain what LLVM dialect output means |
| 12:00–13:00 | Break and review questions | Each person can answer two jury questions |
| 13:00–14:00 | Run numeric examples and inspect correctness checks | Team understands generated inputs and C++ reference |
| 14:00–15:00 | Run benchmark and plot, if time permits | Team can discuss measurements without claiming a speedup |
| 15:00–16:00 | Rehearse exhibition demo and divide speaking roles | Complete timed run-through |
| 16:00–16:30 | Rehearse failure recovery and final Q&A | Team knows fallback and limitations |

Adjust the clock to your exhibition schedule. If you have already built the
project locally, use `build/bin/dl-opt-tool.exe`; otherwise, follow the setup
instructions in `README.md` and prioritize understanding the demo while it
builds.

## First run: PowerShell in VS Code

Open the project folder `D:\mega project\ai-optima` in VS Code. Open **Terminal
> New Terminal**, choose PowerShell, then run:

```powershell
cd "D:\mega project\ai-optima"
.\scripts\run_demo.ps1
```

The demo should end with:

```text
All AI-Optima demo checks passed.
```

It checks fusion, tiling, full lowering, a scalar result of 24, invalid tile
size handling, runtime matrix multiplication, a dense layer, and non-square
partial tiles. JIT progress may appear in the terminal; the script handles
that output and checks each program's exit status.

If the compiler executable is missing, build it using the project's configured
scripts:

```powershell
.\scripts\build_project.ps1
```

The project depends on the LLVM/MLIR installation configured for this machine.
Do not start by rebuilding LLVM during the exhibition; build and rehearse on
the exact laptop that will be used.

## Hands-on walkthrough

### 1. See the input program

Open `test/fusion_test.mlir`. It includes an eligible operation chain and a
case where an intermediate result has multiple users. The second case matters:
the compiler must preserve a value that is still needed elsewhere.

Run just the fusion pass:

```powershell
.\build\bin\dl-opt-tool.exe .\test\fusion_test.mlir --dlopt-fusion
```

Find `dlopt.fused_matmul_bias_relu` in the output. That is the eligible chain
represented as one fused operation. Also find `no_fusion_multi_use`: the
multi-use chain remains separate because replacing it could change observable
program behavior.

### 2. See lower-level compiler output

```powershell
.\build\bin\dl-opt-tool.exe .\test\full_pipeline.mlir --dlopt-pipeline
```

The full pipeline translates custom operations through standard MLIR
representations and down to LLVM dialect. Search the output for `llvm.func`
and `llvm.return`. LLVM dialect is still compiler representation; it is not a
standalone application or proof that the code is faster.

### 3. See a runtime result checked against a reference

The demo runs three runtime cases. The command below can be used to inspect the
dense-layer case on its own:

```powershell
.\build\bin\dl-opt-tool.exe .\test\runtime_dense.mlir --dlopt-pipeline --run --entry-point=runtime_dense --tile-size=4 --iterations=5
```

The runner creates deterministic matrix and bias values, runs the generated
function, computes a plain C++ reference, and compares every output element.
Look for `RESULT: PASS` and `MAX_ABS_ERROR: 0`. The deterministic values make
the demo reproducible; they are not loaded from an external dataset.

### 4. Optional benchmark

```powershell
.\scripts\benchmark_mlir.ps1
.\scripts\benchmark_mlir.ps1 -Dense
python .\scripts\plot_mlir_benchmark.py
```

This records timing measurements for generated code and a same-input C++
reference. Timings vary with laptop, power mode, temperature, and background
load. The checked-in project guide reports that current local measurements do
not establish a speedup. Present this as a correctness and measurement
baseline, and describe performance optimization as future work.

## Glossary for the jury

- **Compiler:** software that translates a program into another form.
- **MLIR:** a compiler framework that lets a program be represented at several
  levels, from domain-specific operations down to low-level operations.
- **Dialect:** a named vocabulary of operations in MLIR. This project defines
  `dlopt` for its small set of deep-learning-style operations.
- **IR (intermediate representation):** the structured form the compiler
  transforms. It is neither the original source text nor necessarily machine
  code.
- **Fusion:** combining a sequence of operations into one operation so the
  compiler can avoid materializing intermediate results. This implementation
  fuses only the supported pattern when its intermediate uses make that safe.
- **Lowering:** translating operations into a more general or lower-level
  representation.
- **Tiling:** splitting loop iteration ranges into blocks. It is intended to
  improve data reuse, but its benefit depends on generated code and hardware.
- **JIT:** just-in-time compilation; compiling code during the running process
  so it can then be executed.
- **Reference implementation:** a simple independent calculation used to
  check whether the generated result is correct.
- **ReLU:** `max(0, x)`, applied element by element.

## Suggested speaking roles

For a team of three, rotate these roles in rehearsal:

1. **Problem and architecture:** explain why compiler optimization matters,
   what MLIR and the `dlopt` dialect are, and show the input program.
2. **Optimization and correctness:** explain fusion's single-use safety rule,
   tiling, runtime execution, and comparison with the C++ reference.
3. **Results and limitations:** show the benchmark, describe what was
   measured, state current limitations, and answer future-work questions.

For a smaller team, combine roles. Every member should be prepared to run the
demo and explain the project's scope.

## A short exhibition demo

1. Start with `test/fusion_test.mlir` and identify the matmul, bias addition,
   and ReLU chain.
2. Run the fusion command and point to `dlopt.fused_matmul_bias_relu`.
3. Point out the multi-use example that is deliberately not fused.
4. Run `test/full_pipeline.mlir --dlopt-pipeline` and show `llvm.func`.
5. Run `scripts/run_demo.ps1`; show the runtime comparison passing.
6. If there is time, show the benchmark graph and explain its limits.

Say what each step demonstrates. Avoid reading long IR dumps aloud; search for
the named operations and explain the transformation.

## Likely jury questions and defensible answers

**What problem does your project address?**

It demonstrates how a compiler can represent and optimize a common sequence
of neural-network operations, then lower the result through MLIR toward LLVM.
It is a research/learning prototype, not a production inference platform.

**What is your contribution?**

The project defines a small `dlopt` operation set, implements a safe pattern
rewrite for matmul + bias + ReLU, demonstrates tiling and lowering, and provides
a JIT harness that checks runtime outputs against a C++ reference.

**How do you know fusion is correct?**

The rewrite only fuses the expected chain when intermediate results are not
used elsewhere. The demo includes a multi-use case that stays unfused. Runtime
examples also compare every output element with the reference calculation.

**Did you achieve a speedup?**

Do not claim that. The measured local results are exploratory and currently
do not show a consistent speedup over the C++ reference. They establish a
baseline and motivate future work on code generation and benchmarking.

**Does it support arbitrary models or tensors?**

No. The JIT runner currently supports a narrow set of statically shaped `f32`
functions: two matrix inputs, optionally bias and ReLU. Inputs are generated
deterministically by the harness. It is not a general model loader or serving
API.

**Why use MLIR?**

MLIR allows a compiler to express operations at multiple abstraction levels
and apply transformations between them. This project uses that structure to
show a domain-specific operation becoming standard and then lower-level IR.

**What would you do next?**

Add broader shape/type and external-input support, improve generated kernels,
expand systematic correctness/performance evaluation, and compare results on
more than one machine.

**What are the limitations?**

The supported operation set and runtime signatures are narrow; the harness
uses generated deterministic inputs; timing is machine-dependent; the
prototype does not yet establish performance gains or serve a real model.

## Demo safety and recovery

- Run `run_demo.ps1` before the exhibition and keep a copy of its successful
  output or a screenshot as a fallback.
- Keep the project and the configured LLVM installation on the same laptop;
  the current demo script expects the local LLVM installation path used during
  setup.
- Close other heavy programs, connect the laptop to power, and avoid changing
  tile sizes or source files immediately before presenting.
- If the live JIT demonstration fails, show the fusion and lowering outputs,
  then the saved successful run. Be explicit that the saved output is from a
  prior run.
- If asked something you cannot substantiate, say so and point to a planned
  experiment. Never invent a speedup, supported feature, or measurement.

## Team self-check

Before presenting, each teammate should be able to answer these without help:

- What goes into and comes out of the compiler pipeline?
- What does the fused operation represent?
- Why does the multi-use case stay unfused?
- What does `llvm.func` tell us, and what does it not prove?
- How is runtime correctness checked?
- What do the benchmark results actually show?
- What are the project's three most important limitations?
