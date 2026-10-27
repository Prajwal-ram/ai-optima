//===----------------------------------------------------------------------===//
// DLOpt Dialect Definition (TableGen)
//
// Defines the DLOpt dialect — a high-level representation for deep learning
// operations that can be optimized and lowered to efficient machine code.
//===----------------------------------------------------------------------===//

#ifndef DLOPT_DIALECT_TD
#define DLOPT_DIALECT_TD

include "mlir/IR/OpBase.td"

//===----------------------------------------------------------------------===//
// DLOpt Dialect
//===----------------------------------------------------------------------===//

def DLOpt_Dialect : Dialect {
  let name = "dlopt";

  let summary = "A dialect for deep learning kernel optimization";

  let description = [{
    The DLOpt dialect provides high-level operations for deep learning
    computations such as matrix multiplication, activation functions, and
    bias addition. These operations serve as the entry point for a custom
    optimization pipeline that applies:

    1. **Operator Fusion** — Combining sequences like MatMul+BiasAdd+ReLU
       into single fused operations to eliminate intermediate tensors.
    2. **Loop Tiling** — Restructuring computation for cache locality.
    3. **Vectorization** — Leveraging AVX2/SSE SIMD instructions.

    The dialect is then lowered through Linalg → SCF → LLVM for code
    generation targeting x86_64 CPUs.
  }];

  let cppNamespace = "::mlir::dlopt";

  // No custom types in DLOpt (uses standard RankedTensorType).
  let useDefaultTypePrinterParser = 0;
}

#endif // DLOPT_DIALECT_TD
