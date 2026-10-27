// ===----------------------------------------------------------------------===//
// Naive C++ Matrix Multiplication Baseline
//
// This provides three implementations for benchmarking comparison:
//   1. Naive triple-loop (baseline)
//   2. Tiled triple-loop (hand-optimized for cache)
//   3. Output timing to stdout for consumption by benchmark.py
//
// Compile:
//   cl /O2 /arch:AVX2 naive_matmul.cpp /Fe:naive_matmul.exe
//   (or: g++ -O2 -mavx2 -o naive_matmul naive_matmul.cpp)
// ===----------------------------------------------------------------------===//

#include <chrono>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <random>
#include <vector>

//===----------------------------------------------------------------------===//
// Naive MatMul: C[M][N] = A[M][K] × B[K][N]
//===----------------------------------------------------------------------===//
void matmul_naive(const float *A, const float *B, float *C, int M, int N,
                  int K) {
  for (int i = 0; i < M; ++i) {
    for (int j = 0; j < N; ++j) {
      float sum = 0.0f;
      for (int k = 0; k < K; ++k) {
        sum += A[i * K + k] * B[k * N + j];
      }
      C[i * N + j] = sum;
    }
  }
}

//===----------------------------------------------------------------------===//
// Tiled MatMul: Same result, but with cache-friendly tiling.
//===----------------------------------------------------------------------===//
void matmul_tiled(const float *A, const float *B, float *C, int M, int N,
                  int K, int tile_size = 64) {
  std::memset(C, 0, sizeof(float) * M * N);

  for (int ii = 0; ii < M; ii += tile_size) {
    for (int jj = 0; jj < N; jj += tile_size) {
      for (int kk = 0; kk < K; kk += tile_size) {
        int i_end = std::min(ii + tile_size, M);
        int j_end = std::min(jj + tile_size, N);
        int k_end = std::min(kk + tile_size, K);

        for (int i = ii; i < i_end; ++i) {
          for (int k = kk; k < k_end; ++k) {
            float a_val = A[i * K + k];
            for (int j = jj; j < j_end; ++j) {
              C[i * N + j] += a_val * B[k * N + j];
            }
          }
        }
      }
    }
  }
}

//===----------------------------------------------------------------------===//
// Benchmark helper
//===----------------------------------------------------------------------===//
template <typename Func>
double benchmark(Func &&func, int warmup = 3, int iterations = 10) {
  // Warmup runs
  for (int i = 0; i < warmup; ++i)
    func();

  // Timed runs
  auto start = std::chrono::high_resolution_clock::now();
  for (int i = 0; i < iterations; ++i)
    func();
  auto end = std::chrono::high_resolution_clock::now();

  auto elapsed =
      std::chrono::duration_cast<std::chrono::microseconds>(end - start);
  return static_cast<double>(elapsed.count()) / iterations;
}

//===----------------------------------------------------------------------===//
// Main
//===----------------------------------------------------------------------===//
int main(int argc, char *argv[]) {
  // Parse matrix size from command line (default: 256)
  int N = (argc > 1) ? std::atoi(argv[1]) : 256;
  int tile_size = (argc > 2) ? std::atoi(argv[2]) : 64;

  std::cout << "Matrix size: " << N << "x" << N << std::endl;
  std::cout << "Tile size: " << tile_size << std::endl;

  // Allocate matrices
  std::vector<float> A(N * N), B(N * N), C(N * N);

  // Initialize with random values
  std::mt19937 rng(42);
  std::uniform_real_distribution<float> dist(-1.0f, 1.0f);
  for (int i = 0; i < N * N; ++i) {
    A[i] = dist(rng);
    B[i] = dist(rng);
  }

  // Benchmark naive matmul
  double naive_time = benchmark([&]() {
    matmul_naive(A.data(), B.data(), C.data(), N, N, N);
  });
  std::cout << "NAIVE_US: " << naive_time << std::endl;

  // Benchmark tiled matmul
  double tiled_time = benchmark([&]() {
    matmul_tiled(A.data(), B.data(), C.data(), N, N, N, tile_size);
  });
  std::cout << "TILED_US: " << tiled_time << std::endl;

  // Compute and display speedup
  std::cout << "SPEEDUP: " << (naive_time / tiled_time) << "x" << std::endl;

  // Compute GFLOPS (2*N^3 FLOPs for matmul)
  double gflops_naive =
      (2.0 * N * N * N) / (naive_time * 1e-6) / 1e9;
  double gflops_tiled =
      (2.0 * N * N * N) / (tiled_time * 1e-6) / 1e9;
  std::cout << "GFLOPS_NAIVE: " << gflops_naive << std::endl;
  std::cout << "GFLOPS_TILED: " << gflops_tiled << std::endl;

  return 0;
}
