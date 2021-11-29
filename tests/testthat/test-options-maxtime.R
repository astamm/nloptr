# Copyright (C) 2015 Jelmer Ypma. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   test-options-maxtime.R
# Author: Jelmer Ypma
# Date:   22 March 2015
#
# Check whether the solver stop when maxtime
# (set in the options) is reached.

# CHANGELOG:
#   12/12/2019: Corrected warnings and using updated testtthat framework (Avraham Adler)

test_that("Test that solver stops when maxtime is reached.", {
    # Objective function with sleep added
    # such that maxtime will be reached
    # when solving the optimization problem.
    eval_f <- function(x) {
        Sys.sleep( 1 )
        return( x^2 )
    }

    eval_grad_f <- function(x) {
        return( 2*x )
    }

    # Initial values.
    x0 <- c( 5 )

    # Define optimizer options.
    opts <- list( "algorithm" = "NLOPT_LD_LBFGS",
                  "maxtime"   = 1,
                  "xtol_rel"  = 1e-4 )

    # Solve problem.
    res <- nloptr(
        x0          = x0,
        eval_f      = eval_f,
        eval_grad_f = eval_grad_f,
        opts        = opts )

    # Check results.
    expect_equal(res$status, 6L)
} )
