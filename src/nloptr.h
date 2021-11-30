#ifndef __NLOPTR_H__
#define __NLOPTR_H__

#include <R.h>
#include <Rdefines.h>

extern SEXP run_testthat_tests(SEXP);
SEXP NLoptR_Optimize(SEXP args);

#endif /*__NLOPTR_H__*/
