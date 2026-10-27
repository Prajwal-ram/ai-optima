"""Plot the latest AI-Optima JIT and C++ reference benchmark CSV files."""

import csv
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt


ROOT = Path(__file__).resolve().parents[1]
RESULTS = ROOT / "benchmarks" / "results"
MODES = ("matmul", "dense")
COLORS = {"JIT": "#1769aa", "C++ reference": "#e07a27"}


def read_rows(mode: str) -> list[dict]:
    path = RESULTS / f"aioptima_{mode}_benchmark.csv"
    if not path.exists():
        raise SystemExit(f"Missing {path}; run benchmark_mlir.ps1 for {mode} first.")
    with path.open(newline="", encoding="utf-8-sig") as stream:
        rows = list(csv.DictReader(stream))
    if not rows:
        raise SystemExit(f"No benchmark results in {path}.")
    return rows


fig, axes = plt.subplots(1, 2, figsize=(11, 4.8), constrained_layout=True)
for ax, mode in zip(axes, MODES):
    rows = read_rows(mode)
    sizes = [int(row["Size"]) for row in rows]
    jit = [float(row["MedianJitUs"]) for row in rows]
    reference = [float(row["MedianCppReferenceUs"]) for row in rows]
    ax.plot(sizes, jit, "o-", color=COLORS["JIT"], linewidth=2,
            markersize=6, label="AI-Optima JIT")
    ax.plot(sizes, reference, "s--", color=COLORS["C++ reference"],
            linewidth=2, markersize=5, label="C++ reference")
    ax.set_title("MatMul + Bias + ReLU" if mode == "dense" else "MatMul")
    ax.set_xlabel("Square matrix dimension N")
    ax.set_ylabel("Median execution time (µs)")
    ax.set_yscale("log")
    ax.set_xticks(sizes, [str(size) for size in sizes])
    ax.grid(True, which="both", alpha=0.25)
    ax.legend(frameon=False)

fig.suptitle("AI-Optima runtime benchmark", fontsize=14, weight="bold")
fig.text(0.5, -0.015,
         "Compilation excluded; JIT call and output allocation included. "
         "Exploratory local results; not a universal performance claim.",
         ha="center", fontsize=9, color="#555555")
output = RESULTS / "aioptima_mlir_benchmark.png"
fig.savefig(output, dpi=180, bbox_inches="tight")
print(f"Chart saved to {output}")
