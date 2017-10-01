#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

#include "nloptr.h"

static const R_CallMethodDef CallEntries[] = {
    {"NLoptR_Optimize", (DL_FUNC) &NLoptR_Optimize, 1},
    {NULL, NULL, 0}
};

void R_init_nloptr(DllInfo *info) {
    R_registerRoutines(info, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(info, FALSE);
}
