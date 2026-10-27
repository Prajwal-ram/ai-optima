//===----------------------------------------------------------------------===//
// DLOpt Operations C++ Header
//===----------------------------------------------------------------------===//

#ifndef DLOPT_DLOPTOPS_H
#define DLOPT_DLOPTOPS_H

#include "DLOpt/DLOptDialect.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/OpDefinition.h"
#include "mlir/Interfaces/InferTypeOpInterface.h"
#include "mlir/Interfaces/SideEffectInterfaces.h"

// Include the auto-generated op declarations.
#define GET_OP_CLASSES
#include "DLOpt/DLOptOps.h.inc"

#endif // DLOPT_DLOPTOPS_H
