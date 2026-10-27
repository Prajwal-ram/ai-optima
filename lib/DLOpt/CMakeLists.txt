# ─── DLOpt Dialect Library ───────────────────────────────────────────────────
# Builds the dialect registration and op implementation as a static library.

add_mlir_dialect_library(MLIRDLOpt
  DLOptDialect.cpp
  DLOptOps.cpp

  ADDITIONAL_HEADER_DIRS
  ${PROJECT_SOURCE_DIR}/include/DLOpt

  DEPENDS
  DLOptOpsIncGen

  LINK_LIBS PUBLIC
  MLIRIR
  MLIRInferTypeOpInterface
  MLIRSideEffectInterfaces
)

add_subdirectory(Transforms)
