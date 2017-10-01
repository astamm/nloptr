#include "nloptr.h"
#include <R_ext/Rdynload.h>

void R_init_mypackage(DllInfo *info) {
    R_RegisterCCallable(info, "NLoptR_Optimize",  (DL_FUNC) &NLoptR_Optimize);
    R_useDynamicSymbols(info, FALSE);
}
