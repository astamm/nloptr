# Copyright (C) 2010 Jelmer Ypma. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   test-banana.R
# Author: Jelmer Ypma
# Date:   10 June 2010
#
# Maintenance assumed by Avraham Adler (AA) on 2023-02-10
#
#
# Example showing how to solve the Rosenbrock Banana function.
#
# Changelog:
#   2013-10-27: Changed example to use unit testing framework testthat.
#   2019-12-12: Corrected warnings and using updated testtthat framework (AA)
#   2023-02-07: Remove wrapping tests in "test_that" to reduce duplication. (AA)

library(nloptr)

tol <- sqrt(.Machine$double.eps)
# Test Rosenbrock Banana optimization with objective and gradient in separate
# functions.

# initial values
x0 <- c(-1.2, 1)

opts <- list("algorithm"   = "NLOPT_LD_LBFGS",
             "xtol_rel"    = 1.0e-8,
             "print_level" = 0)

## Rosenbrock Banana function and gradient in separate functions
eval_f <- function(x) {
  100 * (x[2] - x[1] * x[1]) ^ 2 + (1 - x[1]) ^ 2
}

eval_grad_f <- function(x) {
  c(-400 * x[1] * (x[2] - x[1] * x[1]) - 2 * (1 - x[1]),
    200 * (x[2] - x[1] * x[1]))
}

# Solve Rosenbrock Banana function.
res <- nloptr(x0          = x0,
              eval_f      = eval_f,
              eval_grad_f = eval_grad_f,
              opts        = opts)

# Check results.
expect_equal(res$objective, 0, tolerance = tol)
expect_equal(res$solution, c(1, 1), tolerance = tol)

# Test Rosenbrock Banana optimization with objective and gradient in the same
# function.

# Rosenbrock Banana function and gradient in one function. This can be used to
# economize on calculations

eval_f_list <- function(x) {
  list("objective" = 100 * (x[2] - x[1] * x[1]) ^ 2 + (1 - x[1]) ^ 2,
       "gradient" = c(-400 * x[1] * (x[2] - x[1] * x[1]) - 2 * (1 - x[1]),
                      200 * (x[2] - x[1] * x[1])))
}

# Solve Rosenbrock Banana function. using an objective function that returns a
# list with the objective value and its gradient
res <- nloptr(x0     = x0,
              eval_f = eval_f_list,
              opts   = opts)

# Check results.
expect_equal(res$objective, 0, tolerance = tol)
expect_equal(res$solution, c(1, 1), tolerance = tol)
