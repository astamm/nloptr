# Copyright (C) 2010-17 Jelmer Ypma. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   test-C-api.R
# Author: Jelmer Ypma
# Date:   6 October 2017
#
# Test API to expose NLopt C functions.
#
# CHANGELOG:
#   05/10/2017: Initial version with test of exposed nlopt_version.
#   06/10/2017: Define empty R_TESTS environment variable to fix error on Travis.
#   06/10/2017: Add test for exposed NLopt C functions based on NLopt tutorial.

context("NLopt-C-API")

# Load inline package to compile C code.
library('inline')

# Define empty R_TESTS environment variable to fix error on Travis
# See https://github.com/hadley/testthat/issues/144 for more information.
Sys.setenv("R_TESTS" = "")

# Define arguments for compiler and linker.
cxxargs = nloptr:::CFlags(print = FALSE)
libargs = nloptr:::LdFlags(print = FALSE)

test_that( "Test exposing NLopt C function nlopt_version.", {
    # Define C function to return version number.
    code <- '
      // get version of NLopt
      int major, minor, bugfix;
      nlopt_version(&major, &minor, &bugfix);
  
      SEXP retvec = PROTECT(allocVector(INTSXP, 3));
      INTEGER(retvec)[0] = major;
      INTEGER(retvec)[1] = minor;
      INTEGER(retvec)[2] = bugfix;
      
      UNPROTECT(1);
      return retvec;'
    
    get_nlopt_version <- cfunction(sig = signature(), 
                                   body = code, 
                                   includes = '#include "nloptrAPI.h"',
                                   cxxargs = cxxargs,
                                   libargs = libargs)
    
    # Get nlopt version, which consists of an integer vector:
    #   (major, minor, bugfix)
    res <- get_nlopt_version()
    
    # Check return value.
    expect_type(res, "integer")
    expect_length(res, 3)
} )

test_that( "Test exposed NLopt C code using example from NLopt tutorial.", {
    # Example taken from: 
    #   http://ab-initio.mit.edu/wiki/index.php?title=NLopt_Tutorial

    include_code <- '
#include <math.h>
#include "nloptrAPI.h"

double myfunc(unsigned n, const double *x, double *grad, void *my_func_data)
{
    if (grad) {
        grad[0] = 0.0;
        grad[1] = 0.5 / sqrt(x[1]);
    }
    return sqrt(x[1]);
}

typedef struct {
    double a, b;
} my_constraint_data;

double myconstraint(unsigned n, const double *x, double *grad, void *data)
{
    my_constraint_data *d = (my_constraint_data *) data;
    double a = d->a, b = d->b;
    if (grad) {
        grad[0] = 3 * a * (a*x[0] + b) * (a*x[0] + b);
        grad[1] = -1.0;
    }
    return ((a*x[0] + b) * (a*x[0] + b) * (a*x[0] + b) - x[1]);
}
'

    # Define C function to solve optimization problem.
    code <- '
double lb[2] = { -HUGE_VAL, 0 }; /* lower bounds */
nlopt_opt opt;

opt = nlopt_create(NLOPT_LD_MMA, 2); /* algorithm and dimensionality */
nlopt_set_lower_bounds(opt, lb);
nlopt_set_min_objective(opt, myfunc, NULL);

my_constraint_data data[2] = { {2,0}, {-1,1} };

nlopt_add_inequality_constraint(opt, myconstraint, &data[0], 1e-8);
nlopt_add_inequality_constraint(opt, myconstraint, &data[1], 1e-8);

nlopt_set_xtol_rel(opt, 1e-4);

double x[2] = { 1.234, 5.678 };  /* some initial guess */
double minf; /* the minimum objective value, upon return */
if (nlopt_optimize(opt, x, &minf) < 0) {
    //Rprintf("nlopt failed!\\n");
}
else {
    //Rprintf("found minimum at f(%g,%g) = %0.10g\\n", x[0], x[1], minf);
}

nlopt_destroy(opt);

// Convert result to SEXP.
SEXP result = PROTECT(allocVector(REALSXP, 2));
REAL(result)[0] = x[0];
REAL(result)[1] = x[1];
UNPROTECT(1);

return result;'

    solve_example <- cfunction(sig = signature(), 
                                   body = code,
                                   includes = include_code,
                                   cxxargs = cxxargs,
                                   libargs = libargs)
    
    # Get optimal x values.
    res <- solve_example()

    # Optimal solution as provided in the NLopt tutorial.
    solution.opt <- c( 1/3, 8/27 )
    
    # Check return value.
    expect_equal(res, solution.opt)
} )
