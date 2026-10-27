//===----------------------------------------------------------------------===//
// DLOpt Dialect Registration
//===----------------------------------------------------------------------===//

#include "DLOpt/DLOptDialect.h"
#include "DLOpt/DLOptOps.h"

using namespace mlir;
using namespace mlir::dlopt;

//===----------------------------------------------------------------------===//
// Include the auto-generated dialect definition.
//===----------------------------------------------------------------------===//
#include "DLOpt/DLOptDialect.cpp.inc"

//===----------------------------------------------------------------------===//
// DLOpt Dialect initialization
//===----------------------------------------------------------------------===//
void DLOptDialect::initialize() {
  addOperations<
#define GET_OP_LIST
#include "DLOpt/DLOptOps.cpp.inc"
      >();
}
