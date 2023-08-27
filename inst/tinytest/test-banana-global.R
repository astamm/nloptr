# Copyright (C) 2011 Jelmer Ypma. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   test-banana-global.R
# Author: Jelmer Ypma
# Date:   8 August 2011
#
# Maintenance assumed by Avraham Adler (AA) on 2023-02-10
#
# Example showing how to solve the Rosenbrock Banana function
# using a global optimization algorithm.
#
# Changelog:
#   2013-10-27: Changed example to use unit testing framework testthat.
#   2019-12-12: Corrected warnings and using updated testtthat framework (AA)
#   2023-02-07: Remove wrapping tests in "test_that" to reduce duplication. (AA)

library(nloptr)

tol <- sqrt(.Machine$double.eps)
# Test Rosenbrock Banana optimization with global optimizer NLOPT_GD_MLSL.

## Rosenbrock Banana objective function
eval_f <- function(x) 100 * (x[2] - x[1] * x[1]) ^ 2 + (1 - x[1]) ^ 2

eval_grad_f <- function(x) {
  c(-400 * x[1] * (x[2] - x[1] * x[1]) - 2 * (1 - x[1]),
    200 * (x[2] - x[1] * x[1]))
}

# initial values
x0 <- c(-1.2, 1)

# lower and upper bounds
lb <- c(-3, -3)
ub <- c(3,  3)

# Define optimizer options.
local_opts <- list("algorithm" = "NLOPT_LD_LBFGS", "xtol_rel"  = 1e-4)

opts <- list("algorithm"  = "NLOPT_GD_MLSL", "maxeval"    = 10000,
             "population" = 4, "local_opts" = local_opts)

# Solve Rosenbrock Banana function.
res <- nloptr(x0          = x0,
              lb          = lb,
              ub          = ub,
              eval_f      = eval_f,
              eval_grad_f = eval_grad_f,
              opts        = opts)

# Check results.
expect_equal(res$objective, 0, tolerance = tol)
expect_equal(res$solution, c(1, 1), tolerance = tol)

# Test Rosenbrock Banana optimization with global optimizer NLOPT_GN_ISRES.
# Define optimizer options.
# For unit testing we want to set the random seed for repeatability.

opts <- list("algorithm"   = "NLOPT_GN_ISRES",
             "maxeval"     = 10000,
             "population"  = 100,
             "ranseed"     = 2718)

# Solve Rosenbrock Banana function.
res <- nloptr(x0     = x0,
              lb     = lb,
              ub     = ub,
              eval_f = eval_f,
              opts   = opts)

# Check results.
expect_equal(res$objective, 0, tolerance = 1e-4)
expect_equal(res$solution, c(1, 1), tolerance = 1e-2)

# Test Rosenbrock Banana optimization with global optimizer NLOPT_GN_CRS2_LM
# with random seed defined

# Define optimizer options.
# For unit testing we want to set the random seed for replicability.
opts <- list("algorithm"   = "NLOPT_GN_CRS2_LM",
             "maxeval"     = 10000,
             "population"  = 100,
             "ranseed"     = 2718)

# Solve Rosenbrock Banana function.
res1 <- nloptr(x0     = x0,
               lb     = lb,
               ub     = ub,
               eval_f = eval_f,
               opts   = opts)

# Define optimizer options.
# This optimization uses a different seed for the random number generator and
# gives a different result
opts <- list("algorithm"   = "NLOPT_GN_CRS2_LM",
             "maxeval"     = 10000,
             "population"  = 100,
             "ranseed"     = 3141)

# Solve Rosenbrock Banana function.
res2 <- nloptr(x0     = x0,
               lb     = lb,
               ub     = ub,
               eval_f = eval_f,
               opts   = opts)

# Define optimizer options.
# This optimization uses the same seed for the random number generator and gives
# the same results as res2
opts <- list("algorithm"   = "NLOPT_GN_CRS2_LM",
             "maxeval"     = 10000,
             "population"  = 100,
             "ranseed"     = 3141)

# Solve Rosenbrock Banana function.
res3 <- nloptr(x0     = x0,
               lb     = lb,
               ub     = ub,
               eval_f = eval_f,
               opts   = opts)

# Check results.
expect_equal(res1$objective, 0, tolerance = 1e-4)
expect_equal(res1$solution, c(1, 1), tolerance = 1e-2)

expect_equal(res2$objective, 0, tolerance = 1e-4)
expect_equal(res2$solution, c(1, 1), tolerance = 1e-2)

expect_equal(res3$objective, 0, tolerance = 1e-4)
expect_equal(res3$solution, c(1, 1), tolerance = 1e-2)

# Expect that the results are different for res1 and res2.
expect_false(res1$objective == res2$objective)
expect_false(all(res1$solution  == res2$solution))

# Expect that the results are identical for res2 and res3.
expect_identical(res2$objective, res3$objective)
expect_identical(res2$solution, res3$solution)
