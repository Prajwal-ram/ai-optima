# ─── TableGen: Generate C++ from .td dialect/op definitions ──────────────────
# The DLOptOps.td includes DLOptDialect.td, so we use DLOptOps.td as the root.

set(LLVM_TARGET_DEFINITIONS DLOptOps.td)

mlir_tablegen(DLOptOps.h.inc    -gen-op-decls)
mlir_tablegen(DLOptOps.cpp.inc  -gen-op-defs)
mlir_tablegen(DLOptDialect.h.inc -gen-dialect-decls)
mlir_tablegen(DLOptDialect.cpp.inc -gen-dialect-defs)

add_public_tablegen_target(DLOptOpsIncGen)
