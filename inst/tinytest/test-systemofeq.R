# Copyright (C) 2010 Jelmer Ypma. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   test-systemofeq.R
# Author: Jelmer Ypma
# Date:   20 June 2010
#
# Maintenance assumed by Avraham Adler (AA) on 2023-02-10
#
# Example showing how to solve a system of equations.
#
# min 1
# s.t. x^2 + x - 1 = 0
#
# Optimal solution for x: -1.61803398875
#
# CHANGELOG:
#   2011-06-16: added NLOPT_LD_SLSQP
#   2014-05-05: Changed example to use unit testing framework testthat.
#   2019-12-12: Corrected warnings and using updated testtthat framework (AA)
#   2023-02-07: Remove wrapping tests in "test_that" to reduce duplication. (AA)

library(nloptr)

tol <- sqrt(.Machine$double.eps)

# Test Solve system of equations using NLOPT_LD_MMA with local optimizer
# NLOPT_LD_MMA.

# Objective function.
eval_f0 <- function(x, params) 1

# Gradient of objective function.
eval_grad_f0 <- function(x, params) 0

# Equality constraint function.
eval_g0_eq <- function(x, params) params[1] * x ^ 2 + params[2] * x + params[3]

# Jacobian of constraint.
eval_jac_g0_eq <- function(x, params) 2 * params[1] * x + params[2]

# Define vector with addiitonal data.
params <- c(1, 1, -1)

# Define optimal solution.
solution.opt <- -1.61803398875

local_opts <- list("algorithm" = "NLOPT_LD_MMA", "xtol_rel"  = 1.0e-6)

opts <- list("algorithm"  = "NLOPT_LD_AUGLAG",
             "xtol_rel"   = 1.0e-6,
             "local_opts" = local_opts)

res <- nloptr(x0            = -5,
              eval_f        = eval_f0,
              eval_grad_f   = eval_grad_f0,
              eval_g_eq     = eval_g0_eq,
              eval_jac_g_eq = eval_jac_g0_eq,
              opts          = opts,
              params        = params)

# Run some checks on the optimal solution.
expect_equal(res$solution, solution.opt, tolerance = tol)

# Check whether constraints are violated (up to specified tolerance).
expect_equal(eval_g0_eq(res$solution, params = params), 0,
             tolerance = res$options$tol_constraints_eq)

# Test Solve system of equations using NLOPT_LD_SLSQP.
# Solve using NLOPT_LD_SLSQP.

opts <- list("algorithm" = "NLOPT_LD_SLSQP", "xtol_rel"  = 1.0e-6)

res <- nloptr(x0            = -5,
              eval_f        = eval_f0,
              eval_grad_f   = eval_grad_f0,
              eval_g_eq     = eval_g0_eq,
              eval_jac_g_eq = eval_jac_g0_eq,
              opts          = opts,
              params        = params)

# Run some checks on the optimal solution.
expect_equal(res$solution, solution.opt, tolerance = tol)

# Check whether constraints are violated (up to specified tolerance).
expect_equal(eval_g0_eq(res$solution, params = params), 0,
             tolerance = res$options$tol_constraints_eq)
