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
#   2019-12-12: Corrected warnings and using updated testtthat framework (Avraham Adler)
#   2023-02-07: Remove wrapping tests in "test_that" to reduce duplication. (Avraham Adler)

# Test that solver stops when maxtime is reached.
# Objective function with sleep added such that maxtime will be reached when
# solving the optimization problem.
eval_f <- function(x) {
    Sys.sleep(0.1)
    x ^ 2
}

eval_grad_f <- function(x) 2 * x

# Initial values.
x0 <- 5

# Define optimizer options.
opts <- list("algorithm" = "NLOPT_LD_LBFGS",
             "maxtime"   = 0.05,
             "xtol_rel"  = 1e-4)
# Solve problem.
res <- nloptr(
    x0          = x0,
    eval_f      = eval_f,
    eval_grad_f = eval_grad_f,
    opts        = opts)

# Check results.
expect_identical(res$status, 6L)
