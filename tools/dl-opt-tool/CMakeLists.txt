# ─── dl-opt-tool: The AI-Optima Command-Line Compiler ────────────────────────

set(LIBS
  MLIRDLOpt
  MLIRDLOptTransforms

  # MLIR Core
  MLIROptLib
  MLIRIR
  MLIRPass
  MLIRParser
  MLIRTransforms
  MLIRSupport

  # Dialects used in the pipeline
  MLIRFuncDialect
  MLIRLinalgDialect
  MLIRLinalgTransforms
  MLIRArithDialect
  MLIRArithTransforms
  MLIRSCFDialect
  MLIRSCFTransforms
  MLIRTensorDialect
  MLIRTensorTransforms
  MLIRTilingInterface
  MLIRTensorTilingInterfaceImpl
  MLIRMemRefDialect
  MLIRBufferizationDialect
  MLIRBufferizationTransforms
  MLIRLLVMDialect
  MLIRControlFlowDialect
  MLIRControlFlowTransforms
  MLIRAffineToStandard
  MLIRIndexToLLVM

  # JIT Execution Engine & LLVM IR Translation
  MLIRExecutionEngine
  MLIRTargetLLVMIRExport
  MLIRBuiltinToLLVMIRTranslation
  MLIRLLVMToLLVMIRTranslation
  MLIRToLLVMIRTranslationRegistration

  # LLVM Core
  LLVMCore
  LLVMSupport
)

add_llvm_executable(dl-opt-tool
  dl-opt-tool.cpp
)
llvm_update_compile_flags(dl-opt-tool)
target_link_libraries(dl-opt-tool PRIVATE ${LIBS})

# Provides memrefCopy for JIT-executed bufferized tensor functions.
target_compile_definitions(dl-opt-tool PRIVATE
  AI_OPTIMA_C_RUNNER_UTILS_PATH="${LLVM_TOOLS_BINARY_DIR}/libmlir_c_runner_utils.dll"
  AI_OPTIMA_LLVM_BIN_PATH="${LLVM_TOOLS_BINARY_DIR}"
)

# Build a tiny DLL exposing MinGW compiler-rt's real Windows stack probe so
# LLVM ORC can resolve it when generated functions have stack frames > 4 KB.
if(WIN32 AND CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  find_program(AI_OPTIMA_LLVM_AR NAMES llvm-ar HINTS "${LLVM_TOOLS_BINARY_DIR}" REQUIRED)
  execute_process(
    COMMAND "${CMAKE_CXX_COMPILER}" --print-runtime-dir
    OUTPUT_VARIABLE AI_OPTIMA_CLANG_RUNTIME_DIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE AI_OPTIMA_RUNTIME_QUERY_RESULT
  )
  set(AI_OPTIMA_BUILTINS_ARCHIVE
      "${AI_OPTIMA_CLANG_RUNTIME_DIR}/libclang_rt.builtins-x86_64.a")
  if(AI_OPTIMA_RUNTIME_QUERY_RESULT EQUAL 0 AND EXISTS "${AI_OPTIMA_BUILTINS_ARCHIVE}")
    set(AI_OPTIMA_STACK_PROBE_DIR "${CMAKE_BINARY_DIR}/jit-runtime")
    set(AI_OPTIMA_STACK_PROBE_DLL
        "${AI_OPTIMA_STACK_PROBE_DIR}/libaioptima_stack_probe.dll")
    add_custom_command(
      OUTPUT "${AI_OPTIMA_STACK_PROBE_DLL}"
      COMMAND "${CMAKE_COMMAND}" -E make_directory "${AI_OPTIMA_STACK_PROBE_DIR}"
      COMMAND "${CMAKE_COMMAND}" -E chdir "${AI_OPTIMA_STACK_PROBE_DIR}"
              "${AI_OPTIMA_LLVM_AR}" x "${AI_OPTIMA_BUILTINS_ARCHIVE}" chkstk.S.obj
      COMMAND "${CMAKE_COMMAND}" -E chdir "${AI_OPTIMA_STACK_PROBE_DIR}"
              "${CMAKE_CXX_COMPILER}" -shared -o "${AI_OPTIMA_STACK_PROBE_DLL}"
              chkstk.S.obj -Wl,--export-all-symbols
      DEPENDS "${AI_OPTIMA_BUILTINS_ARCHIVE}"
      VERBATIM
    )
    add_custom_target(aioptima_stack_probe ALL DEPENDS "${AI_OPTIMA_STACK_PROBE_DLL}")
    add_dependencies(dl-opt-tool aioptima_stack_probe)
    target_compile_definitions(dl-opt-tool PRIVATE
      AI_OPTIMA_STACK_PROBE_PATH="${AI_OPTIMA_STACK_PROBE_DLL}"
    )
  endif()
endif()

mlir_check_all_link_libraries(dl-opt-tool)
