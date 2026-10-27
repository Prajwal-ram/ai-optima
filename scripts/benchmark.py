#!/usr/bin/env python3
"""
AI-Optima Benchmark Suite
=========================

Compares execution time of:
  1. Naive C++ triple-loop matrix multiplication
  2. Tiled C++ matrix multiplication (hand-optimized)
  3. NumPy (backed by OpenBLAS / MKL)
  4. AI-Optima JIT-compiled MLIR (when available)

Generates publication-quality comparison charts.

Usage:
  python benchmark.py [--sizes 128,256,512,1024] [--output results/]
"""

import argparse
import json
import os
import platform
import subprocess
import sys
import time
from pathlib import Path

import numpy as np

# ─── Configuration ──────────────────────────────────────────────────────────
DEFAULT_SIZES = [64, 128, 256, 512, 1024]
WARMUP_RUNS = 3
BENCHMARK_RUNS = 10

# Paths (relative to project root)
PROJECT_ROOT = Path(__file__).parent.parent
BENCHMARKS_DIR = PROJECT_ROOT / "benchmarks"
BUILD_DIR = PROJECT_ROOT / "build"
RESULTS_DIR = PROJECT_ROOT / "benchmarks" / "results"


def ensure_dir(path: Path):
    path.mkdir(parents=True, exist_ok=True)


# ─── NumPy Benchmark ───────────────────────────────────────────────────────
def benchmark_numpy(N: int) -> dict:
    """Benchmark NumPy's matrix multiplication (uses BLAS under the hood)."""
    A = np.random.randn(N, N).astype(np.float32)
    B = np.random.randn(N, N).astype(np.float32)

    # Warmup
    for _ in range(WARMUP_RUNS):
        _ = A @ B

    # Timed runs
    times = []
    for _ in range(BENCHMARK_RUNS):
        start = time.perf_counter()
        C = A @ B
        end = time.perf_counter()
        times.append((end - start) * 1e6)  # Convert to microseconds

    avg_us = np.mean(times)
    gflops = (2.0 * N ** 3) / (avg_us * 1e-6) / 1e9

    return {
        "method": "NumPy",
        "size": N,
        "time_us": avg_us,
        "gflops": gflops,
        "std_us": np.std(times),
    }


# ─── C++ Benchmark ─────────────────────────────────────────────────────────
def compile_cpp_benchmark():
    """Compile the C++ benchmark if not already built."""
    source = BENCHMARKS_DIR / "naive_matmul.cpp"
    binary = BENCHMARKS_DIR / "naive_matmul.exe"

    if binary.exists():
        print(f"  C++ benchmark already compiled: {binary}")
        return binary

    print("  Compiling C++ benchmark...")

    # Try MSVC first, then GCC/Clang
    compilers = [
        ["cl", "/O2", "/arch:AVX2", "/EHsc", str(source), f"/Fe:{binary}"],
        ["g++", "-O2", "-mavx2", "-o", str(binary), str(source)],
        ["clang++", "-O2", "-mavx2", "-o", str(binary), str(source)],
    ]

    for cmd in compilers:
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
            if result.returncode == 0:
                print(f"  Compiled with {cmd[0]}")
                return binary
        except (FileNotFoundError, subprocess.TimeoutExpired):
            continue

    print("  WARNING: Could not compile C++ benchmark. Skipping.")
    return None


def benchmark_cpp(N: int, binary: Path) -> list:
    """Run the C++ benchmark binary and parse its output."""
    if binary is None:
        return []

    try:
        env = os.environ.copy()
        mingw_bin = r"D:\mega project\tools\llvm-mingw\bin"
        if mingw_bin not in env.get("PATH", ""):
            env["PATH"] = mingw_bin + os.pathsep + env.get("PATH", "")

        result = subprocess.run(
            [str(binary), str(N)],
            capture_output=True,
            text=True,
            timeout=300,
            env=env,
        )
        if result.returncode != 0:
            print(f"  WARNING: C++ benchmark failed for N={N}: {result.stderr}")
            return []

        results = []
        lines = result.stdout.strip().split("\n")
        values = {}
        for line in lines:
            if ":" in line:
                key, val = line.split(":", 1)
                values[key.strip()] = val.strip()

        if "NAIVE_US" in values:
            time_us = float(values["NAIVE_US"])
            results.append({
                "method": "C++ Naive",
                "size": N,
                "time_us": time_us,
                "gflops": (2.0 * N ** 3) / (time_us * 1e-6) / 1e9,
            })

        if "TILED_US" in values:
            time_us = float(values["TILED_US"])
            results.append({
                "method": "C++ Tiled",
                "size": N,
                "time_us": time_us,
                "gflops": (2.0 * N ** 3) / (time_us * 1e-6) / 1e9,
            })

        return results
    except Exception as e:
        print(f"  WARNING: C++ benchmark error: {e}")
        return []


# ─── Plotting ──────────────────────────────────────────────────────────────
def generate_charts(all_results: list, output_dir: Path):
    """Generate publication-quality benchmark charts."""
    try:
        import matplotlib
        matplotlib.use("Agg")  # Non-interactive backend
        import matplotlib.pyplot as plt
        from matplotlib import rcParams
    except ImportError:
        print("  WARNING: matplotlib not available. Skipping chart generation.")
        print("  Install with: pip install matplotlib")
        return

    # ── Style ──────────────────────────────────────────────────────────
    rcParams["font.family"] = "sans-serif"
    rcParams["font.size"] = 12
    rcParams["axes.spines.top"] = False
    rcParams["axes.spines.right"] = False

    colors = {
        "C++ Naive": "#E74C3C",       # Red
        "C++ Tiled": "#F39C12",       # Orange
        "NumPy": "#2ECC71",           # Green
        "AI-Optima (MLIR)": "#3498DB", # Blue
    }

    # Group by method
    methods = {}
    for r in all_results:
        m = r["method"]
        if m not in methods:
            methods[m] = {"sizes": [], "times": [], "gflops": []}
        methods[m]["sizes"].append(r["size"])
        methods[m]["times"].append(r["time_us"])
        methods[m]["gflops"].append(r["gflops"])

    # ── Chart 1: Execution Time vs Matrix Size ─────────────────────────
    fig, ax = plt.subplots(figsize=(10, 6))
    for method, data in methods.items():
        color = colors.get(method, "#7F8C8D")
        ax.plot(data["sizes"], data["times"], "o-", label=method,
                color=color, linewidth=2, markersize=8)

    ax.set_xlabel("Matrix Size (N×N)", fontsize=14)
    ax.set_ylabel("Execution Time (μs)", fontsize=14)
    ax.set_title("Matrix Multiplication: Execution Time Comparison", fontsize=16,
                 fontweight="bold")
    ax.legend(fontsize=12, frameon=True, fancybox=True, shadow=True)
    ax.set_yscale("log")
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(output_dir / "execution_time.png", dpi=150, bbox_inches="tight")
    print(f"  Saved: {output_dir / 'execution_time.png'}")
    plt.close()

    # ── Chart 2: GFLOPS Performance ────────────────────────────────────
    fig, ax = plt.subplots(figsize=(10, 6))
    for method, data in methods.items():
        color = colors.get(method, "#7F8C8D")
        ax.plot(data["sizes"], data["gflops"], "s-", label=method,
                color=color, linewidth=2, markersize=8)

    ax.set_xlabel("Matrix Size (N×N)", fontsize=14)
    ax.set_ylabel("Performance (GFLOPS)", fontsize=14)
    ax.set_title("Matrix Multiplication: Performance (Higher is Better)",
                 fontsize=16, fontweight="bold")
    ax.legend(fontsize=12, frameon=True, fancybox=True, shadow=True)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(output_dir / "gflops.png", dpi=150, bbox_inches="tight")
    print(f"  Saved: {output_dir / 'gflops.png'}")
    plt.close()

    # ── Chart 3: Speedup vs Naive C++ ──────────────────────────────────
    if "C++ Naive" in methods:
        naive_times = dict(zip(methods["C++ Naive"]["sizes"],
                               methods["C++ Naive"]["times"]))

        fig, ax = plt.subplots(figsize=(10, 6))
        for method, data in methods.items():
            if method == "C++ Naive":
                continue
            color = colors.get(method, "#7F8C8D")
            speedups = [naive_times.get(s, 1) / t
                        for s, t in zip(data["sizes"], data["times"])
                        if s in naive_times]
            sizes = [s for s in data["sizes"] if s in naive_times]
            ax.bar([f"{s}" for s in sizes], speedups, label=method,
                   color=color, alpha=0.85, width=0.25)

        ax.set_xlabel("Matrix Size (N×N)", fontsize=14)
        ax.set_ylabel("Speedup vs. Naive C++", fontsize=14)
        ax.set_title("Speedup Over Naive C++ Implementation", fontsize=16,
                     fontweight="bold")
        ax.axhline(y=1.0, color="gray", linestyle="--", alpha=0.5)
        ax.legend(fontsize=12)
        ax.grid(True, alpha=0.3, axis="y")
        fig.tight_layout()
        fig.savefig(output_dir / "speedup.png", dpi=150, bbox_inches="tight")
        print(f"  Saved: {output_dir / 'speedup.png'}")
        plt.close()


# ─── Main ──────────────────────────────────────────────────────────────────
def main():
    parser = argparse.ArgumentParser(description="AI-Optima Benchmark Suite")
    parser.add_argument("--sizes", type=str, default=",".join(map(str, DEFAULT_SIZES)),
                        help="Comma-separated matrix sizes to benchmark")
    parser.add_argument("--output", type=str, default=str(RESULTS_DIR),
                        help="Output directory for results")
    parser.add_argument("--skip-cpp", action="store_true",
                        help="Skip C++ benchmarks")
    parser.add_argument("--skip-numpy", action="store_true",
                        help="Skip NumPy benchmarks")
    args = parser.parse_args()

    sizes = [int(s) for s in args.sizes.split(",")]
    output_dir = Path(args.output)
    ensure_dir(output_dir)

    print("=" * 60)
    print("  AI-Optima Benchmark Suite")
    print("=" * 60)
    print(f"  Platform: {platform.platform()}")
    print(f"  CPU: {platform.processor()}")
    print(f"  Matrix sizes: {sizes}")
    print(f"  Output: {output_dir}")
    print()

    all_results = []

    # ── C++ Benchmarks ───────────────────────────────────────────────────
    if not args.skip_cpp:
        print("[1/3] C++ Benchmarks")
        binary = compile_cpp_benchmark()
        for N in sizes:
            print(f"  Running N={N}...")
            results = benchmark_cpp(N, binary)
            all_results.extend(results)
            for r in results:
                print(f"    {r['method']}: {r['time_us']:.1f} us "
                      f"({r['gflops']:.2f} GFLOPS)")
        print()

    # ── NumPy Benchmarks ─────────────────────────────────────────────────
    if not args.skip_numpy:
        print("[2/3] NumPy Benchmarks")
        for N in sizes:
            print(f"  Running N={N}...")
            result = benchmark_numpy(N)
            all_results.append(result)
            print(f"    NumPy: {result['time_us']:.1f} us "
                  f"({result['gflops']:.2f} GFLOPS)")
        print()

    # ── AI-Optima Benchmarks (placeholder for JIT results) ──────────────
    print("[3/3] AI-Optima MLIR Benchmarks")
    dl_opt_tool = BUILD_DIR / "bin" / "dl-opt-tool.exe"
    if dl_opt_tool.exists():
        print("  dl-opt-tool found! Running JIT benchmarks...")
        # TODO: Add MLIR JIT benchmarks once the tool is built
        print("  (JIT benchmark integration pending)")
    else:
        print(f"  dl-opt-tool not found at {dl_opt_tool}")
        print("  Build the project first, then re-run benchmarks.")
    print()

    # ── Save Results ─────────────────────────────────────────────────────
    results_file = output_dir / "benchmark_results.json"
    with open(results_file, "w") as f:
        json.dump(all_results, f, indent=2)
    print(f"Results saved to: {results_file}")

    # ── Generate Charts ──────────────────────────────────────────────────
    print("\nGenerating charts...")
    generate_charts(all_results, output_dir)

    # ── Summary Table ────────────────────────────────────────────────────
    print("\n" + "=" * 60)
    print("  Summary")
    print("=" * 60)
    print(f"  {'Method':<20} {'Size':>6} {'Time (us)':>12} {'GFLOPS':>10}")
    print("  " + "-" * 50)
    for r in sorted(all_results, key=lambda x: (x["size"], x["method"])):
        print(f"  {r['method']:<20} {r['size']:>6} "
              f"{r['time_us']:>12.1f} {r['gflops']:>10.2f}")
    print()


if __name__ == "__main__":
    main()
