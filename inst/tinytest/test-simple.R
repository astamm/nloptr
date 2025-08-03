# Copyright (C) 2010 Jelmer Ypma. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   test-simple.R
# Author: Jelmer Ypma
# Date:   20 June 2010
#
# Maintenance assumed by Avraham Adler (AA) on 2023-02-10
#
# Example showing how to solve a simple constrained problem.
#
# min x^2
# s.t. x >= 5
#
# re-formulate constraint to be of form g(x) <= 0
#      5 - x <= 0
# we could use a bound constraint as well here
#
# CHANGELOG:
#   2014-05-05: Changed example to use unit testing framework testthat.
#   2019-12-12: Corrected warnings and using updated testtthat framework (AA)
#   2023-02-07: Remove wrapping tests in "test_that" to reduce duplication. (AA)
#

library(nloptr)

tol <- sqrt(.Machine$double.eps)

# Test simple constrained optimization problem with gradient information.

# Objective function
eval_f <- function(x) x ^ 2

# Gradient of objective function.
eval_grad_f <- function(x) 2 * x

# Inequality constraint function.
eval_g_ineq <- function(x) 5 - x

# Jacobian of constraint.
eval_jac_g_ineq <- function(x) -1

# Optimal solution.
solution.opt <- 5

# Solve using NLOPT_LD_MMA with gradient information supplied in separate
# function.
res <- nloptr(x0              = 1,
              eval_f          = eval_f,
              eval_grad_f     = eval_grad_f,
              eval_g_ineq     = eval_g_ineq,
              eval_jac_g_ineq = eval_jac_g_ineq,
              opts            = list("algorithm" = "NLOPT_LD_MMA",
                                     "xtol_rel" = 1e-4))

# Run some checks on the optimal solution.
expect_equal(res$solution, solution.opt, tolerance = tol)

# Check whether constraints are violated (up to specified tolerance).
expect_true(eval_g_ineq(res$solution) <= res$options$tol_constraints_ineq)

# Test simple constrained optimization problem without gradient information.

# Solve using NLOPT_LN_COBYLA without gradient information
res <- nloptr(x0              = 1,
              eval_f          = eval_f,
              eval_g_ineq     = eval_g_ineq,
              opts            = list("algorithm"            = "NLOPT_LN_COBYLA",
                                     "xtol_rel"             = 1e-6,
                                     "tol_constraints_ineq" = 1e-6))

# Run some checks on the optimal solution.
expect_equal(res$solution, solution.opt, tolerance = 1e-6)

# Check whether constraints are violated (up to specified tolerance).
expect_true(eval_g_ineq(res$solution) <= res$options$tol_constraints_ineq)
