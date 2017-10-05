# Copyright (C) 2010-17 Jelmer Ypma. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   test-C-api.R
# Author: Jelmer Ypma
# Date:   5 October 2017
#
# Test API to expose NLopt C functions.
#
# CHANGELOG:
#   05/10/2017: Initial version with test of exposed nlopt_version.

context("NLopt-C-API")

# Load inline package to compile C code.
library('inline')

# Define arguments for compiler and linker.
cxxargs = paste0('-I"', system.file("include", package = "nloptr"), '"')
libargs = nloptr:::LdFlags(print = FALSE)

test_that( "Test NLopt tutorial example with NLOPT_LD_MMA with gradient information.", {
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
    #   (major, minor, bugifx)
    res <- get_nlopt_version()
    
    # Check return value.
    expect_type(res, "integer")
    expect_that(length(res), equals(3))
} )
