# ─── DLOpt Transformation and Lowering Passes ───────────────────────────────

add_mlir_library(MLIRDLOptTransforms
  FusionPass.cpp
  TilingPass.cpp
  LowerToLinalg.cpp
  LowerToLLVM.cpp
  PassRegistration.cpp

  ADDITIONAL_HEADER_DIRS
  ${PROJECT_SOURCE_DIR}/include/DLOpt

  DEPENDS
  DLOptOpsIncGen

  LINK_LIBS PUBLIC
  MLIRDLOpt
  MLIRIR
  MLIRPass
  MLIRTransforms
  MLIRTilingInterface
  MLIRTensorTilingInterfaceImpl
  MLIRLinalgDialect
  MLIRLinalgTransforms
  MLIRTensorDialect
  MLIRArithDialect
  MLIRFuncDialect
  MLIRSCFDialect
  MLIRSCFTransforms
  MLIRMemRefDialect
  MLIRMemRefTransforms
  MLIRBufferizationDialect
  MLIRBufferizationTransforms
  MLIRLLVMDialect
  MLIRLLVMCommonConversion
  MLIRArithToLLVM
  MLIRMemRefToLLVM
  MLIRFuncToLLVM
  MLIRSCFToControlFlow
  MLIRControlFlowToLLVM
  MLIRAffineToStandard
  MLIRIndexToLLVM
  MLIRReconcileUnrealizedCasts
)
