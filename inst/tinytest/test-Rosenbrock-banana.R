# Copyright (C) 2024 Avraham Adler. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   test-Rosebbrock-banana
# Author: Avraham Adler
# Date:   25 June 2024
#
# Complete rewrite of the current Rosenbrock banana tests. This also helps test
# the accuracy of various algorithms.
#
# Changelog:
#   2024-06-25: Complete rewrite of existing (inefficient) tests. Also tests
#               most of the exposed algorithms. See the comments here and
#               https://nlopt.readthedocs.io/en/latest/NLopt_Algorithms/ for
#               more details.
#

library(nloptr)
tol <- sqrt(.Machine$double.eps)

# Rosenbrock banana function (rbf)
rbf <- function(x) {(1 - x[1]) ^ 2 + 100 * (x[2] - x[1] ^ 2) ^ 2}

# Analytic gradient for rbf
rbfgr <- function(x) {c(-2 * (1 - x[1]) - 400 * x[1] * (x[2] - x[1] ^ 2),
                     200 * (x[2] - x[1] ^ 2))}

# Used options
opts <- list(ftol_rel = 1e-12, xtol_rel = 1e-12, print_level = 0, maxeval = 5e4)

# Known optimium of 0 occurs at (1, 1)
rbfOptVal <- 0
rbfOptLoc <- c(1, 1)

# Initial values
x0 <- c(-1.2, 1.3)

# Local Gradient-Based Algorithms
## LBFGS (also tests seperate and combined function/gradient calls).

opts$algorithm <- "NLOPT_LD_LBFGS"

# Test passing function and gradient separately.
testRes <- nloptr(x0 = x0, eval_f = rbf, eval_grad_f = rbfgr, opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
expect_equal(testRes$solution, rbfOptLoc, tolerance = tol)

# Test passing function and gradient in same function call.
rbfComplete <- function(x) {
  list(objective = rbf(x), gradient = rbfgr(x))
}

testRes <- nloptr(x0 = x0, eval_f = rbfComplete, opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
expect_equal(testRes$solution, rbfOptLoc, tolerance = tol)

## MMA
opts$algorithm <- "NLOPT_LD_MMA"
testRes <- nloptr(x0 = x0, eval_f = rbf, eval_grad_f = rbfgr, opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
expect_equal(testRes$solution, rbfOptLoc, tolerance = tol)

## CCSAQ
opts$algorithm <- "NLOPT_LD_CCSAQ"
testRes <- nloptr(x0 = x0, eval_f = rbf, eval_grad_f = rbfgr, opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
expect_equal(testRes$solution, rbfOptLoc, tolerance = tol)

## SLSQP
opts$algorithm <- "NLOPT_LD_SLSQP"
testRes <- nloptr(x0 = x0, eval_f = rbf, eval_grad_f = rbfgr, opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
expect_equal(testRes$solution, rbfOptLoc, tolerance = tol)

## Preconditioned truncated Newton
opts$algorithm <- "NLOPT_LD_TNEWTON"
testRes <- nloptr(x0 = x0, eval_f = rbf, eval_grad_f = rbfgr, opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
expect_equal(testRes$solution, rbfOptLoc, tolerance = tol)

opts$algorithm <- "NLOPT_LD_TNEWTON_RESTART"
testRes <- nloptr(x0 = x0, eval_f = rbf, eval_grad_f = rbfgr, opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
expect_equal(testRes$solution, rbfOptLoc, tolerance = tol)

opts$algorithm <- "NLOPT_LD_TNEWTON_PRECOND"
testRes <- nloptr(x0 = x0, eval_f = rbf, eval_grad_f = rbfgr, opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
expect_equal(testRes$solution, rbfOptLoc, tolerance = tol)

opts$algorithm <- "NLOPT_LD_TNEWTON_PRECOND_RESTART"
testRes <- nloptr(x0 = x0, eval_f = rbf, eval_grad_f = rbfgr, opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
expect_equal(testRes$solution, rbfOptLoc, tolerance = tol)

## Shifted limited-memory variable-metric
opts$algorithm <- "NLOPT_LD_VAR2"
testRes <- nloptr(x0 = x0, eval_f = rbf, eval_grad_f = rbfgr, opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
expect_equal(testRes$solution, rbfOptLoc, tolerance = 1e-7)

opts$algorithm <- "NLOPT_LD_VAR1"
testRes <- nloptr(x0 = x0, eval_f = rbf, eval_grad_f = rbfgr, opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
expect_equal(testRes$solution, rbfOptLoc, tolerance = tol)

# Local Derivative-Free Algorithms
## COBYLA
opts$algorithm <- "NLOPT_LN_COBYLA"
testRes <- nloptr(x0 = x0, eval_f = rbf, opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
expect_equal(testRes$solution, rbfOptLoc, tolerance = tol)

## BOBYQA
opts$algorithm <- "NLOPT_LN_BOBYQA"
testRes <- nloptr(x0 = x0, eval_f = rbf, opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
expect_equal(testRes$solution, rbfOptLoc, tolerance = tol)

## NEWUOA
opts$algorithm <- "NLOPT_LN_NEWUOA"
testRes <- nloptr(x0 = x0, eval_f = rbf, opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
expect_equal(testRes$solution, rbfOptLoc, tolerance = tol)

## PRAXIS
opts$algorithm <- "NLOPT_LN_PRAXIS"
testRes <- nloptr(x0 = x0, eval_f = rbf, opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
expect_equal(testRes$solution, rbfOptLoc, tolerance = tol)

## Nelder-Mead Simplex
opts$algorithm <- "NLOPT_LN_NELDERMEAD"
testRes <- nloptr(x0 = x0, eval_f = rbf, opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
expect_equal(testRes$solution, rbfOptLoc, tolerance = tol)

## Sbplx
opts$algorithm <- "NLOPT_LN_SBPLX"
testRes <- nloptr(x0 = x0, eval_f = rbf, opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
expect_equal(testRes$solution, rbfOptLoc, tolerance = tol)

# Global Algorithms
lb <- c(-3, -3)
ub <- c(3,  3)

## StoGo
## StoGo passes on many platforms but fails MISERABLE (Inf???) on others. Note
## that here and disable the tests for now.
# opts$algorithm <- "NLOPT_GD_STOGO"
# testRes <- nloptr(x0 = x0, eval_f = rbf, eval_grad_f = rbfgr, lb = lb, ub = ub,
#                   opts = opts)
#
# expect_equal(testRes$objective, rbfOptVal, tolerance = 1e-4)
# expect_equal(testRes$solution, rbfOptLoc, tolerance = 1e-4)
#
# opts$algorithm <- "NLOPT_GD_STOGO_RAND"
# testRes <- nloptr(x0 = x0, eval_f = rbf, eval_grad_f = rbfgr, lb = lb, ub = ub,
#                   opts = opts)
#
# expect_equal(testRes$objective, rbfOptVal, tolerance = 1e-4)
# expect_equal(testRes$solution, rbfOptLoc, tolerance = 1e-4)

## ISRES
opts$population <- 100
opts$ranseed <- 2718L
opts$algorithm <- "NLOPT_GN_ISRES"

testRes <- nloptr(x0 = x0, eval_f = rbf, lb = lb, ub = ub, opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
expect_equal(testRes$solution, rbfOptLoc, tolerance = tol)

## Controlled Random Search (with ranseed testing)
opts$algorithm <- "NLOPT_GN_CRS2_LM"
testRes <- nloptr(x0 = x0, eval_f = rbf, lb = lb, ub = ub, opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
expect_equal(testRes$solution, rbfOptLoc, tolerance = tol)

# Different random seed
opts$ranseed <- 3141L
testRes2 <- nloptr(x0 = x0, eval_f = rbf, lb = lb, ub = ub, opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
expect_equal(testRes$solution, rbfOptLoc, tolerance = tol)

# Same random seed
opts$ranseed <- 2718L
testRes3 <- nloptr(x0 = x0, eval_f = rbf, lb = lb, ub = ub, opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
expect_equal(testRes$solution, rbfOptLoc, tolerance = tol)

# Results of different random seeds should differ.
expect_false(identical(testRes$objective, testRes2$objective))
expect_false(identical(testRes$solution, testRes2$solution))

# Results of same random seeds should be the same.
expect_identical(testRes$objective, testRes3$objective)
expect_identical(testRes$solution, testRes3$solution)

## DIRECT
opts$algorithm <- "NLOPT_GN_DIRECT_L"
testRes <- nloptr(x0 = x0, eval_f = rbf, lb = lb, ub = ub, opts = opts)

# expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
# expect_equal(testRes$solution, rbfOptLoc, tolerance = tol)

opts$algorithm <- "NLOPT_GN_DIRECT_NOSCAL"
testRes <- nloptr(x0 = x0, eval_f = rbf, lb = lb, ub = ub, opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
expect_equal(testRes$solution, rbfOptLoc, tolerance = tol)

opts$algorithm <- "NLOPT_GN_DIRECT_L_NOSCAL"
testRes <- nloptr(x0 = x0, eval_f = rbf, lb = lb, ub = ub, opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
expect_equal(testRes$solution, rbfOptLoc, tolerance = tol)

opts$algorithm <- "NLOPT_GN_DIRECT_L_RAND_NOSCAL"
testRes <- nloptr(x0 = x0, eval_f = rbf, lb = lb, ub = ub, opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
expect_equal(testRes$solution, rbfOptLoc, tolerance = tol)

opts$algorithm <- "NLOPT_GN_ORIG_DIRECT_L"
testRes <- nloptr(x0 = x0, eval_f = rbf, lb = lb, ub = ub, opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
expect_equal(testRes$solution, rbfOptLoc, tolerance = tol)

# The follwing versions converge to the wrong answer; see
# https://nlopt.readthedocs.io/en/latest/NLopt_Algorithms/#direct-and-direct-l
# in that the rescaling may be faulty for this particular problem.
opts$algorithm <- "NLOPT_GN_DIRECT"
expect_stdout(nloptr(x0 = x0, eval_f = rbf, lb = lb, ub = ub, opts = opts))

opts$algorithm <- "NLOPT_GN_ORIG_DIRECT"
expect_stdout(nloptr(x0 = x0, eval_f = rbf, lb = lb, ub = ub, opts = opts))

## ESCH - does not converge in 1M iterations so just test for output. Probably
## needs MUCH tighter bounds.
opts$algorithm <- "NLOPT_GN_ESCH"
expect_stdout(nloptr(x0 = x0, eval_f = rbf, lb = lb, ub = ub, opts = opts))

## MLSL (Multi-Level Single-Linkage)
# Use LBGFS as local search algorithm
opts$local_opts <- list(algorithm = "NLOPT_LD_LBFGS", xtol_rel = 1e-9)
# Need to set lower evaluation cap since this is nested global/local
oldmaxeval <- opts$maxeval
opts$maxeval <- 1000

# Gradient-based
opts$algorithm <- "NLOPT_GD_MLSL"
testRes <- nloptr(x0 = x0, eval_f = rbf, eval_grad_f = rbfgr, lb = lb, ub = ub,
                  opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
expect_equal(testRes$solution, rbfOptLoc, tolerance = tol)

opts$algorithm <- "NLOPT_GD_MLSL_LDS"
testRes <- nloptr(x0 = x0, eval_f = rbf, eval_grad_f = rbfgr, lb = lb, ub = ub,
                  opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = tol)
expect_equal(testRes$solution, rbfOptLoc, tolerance = tol)

# Derivative-free
opts$local_opts <- list(algorithm = "NLOPT_LN_NELDERMEAD", xtol_rel = 1e-12)
opts$maxeval <- 10000

# Need lower tolerance (or MANY more evaluations) without gradient information.
opts$algorithm <- "NLOPT_GN_MLSL"
testRes <- nloptr(x0 = x0, eval_f = rbf, lb = lb, ub = ub, opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = 1e-5)
expect_equal(testRes$solution, rbfOptLoc, tolerance = 1e-5)

opts$algorithm <- "NLOPT_GN_MLSL_LDS"
testRes <- nloptr(x0 = x0, eval_f = rbf, lb = lb, ub = ub, opts = opts)

expect_equal(testRes$objective, rbfOptVal, tolerance = 1e-5)
expect_equal(testRes$solution, rbfOptLoc, tolerance = 1e-5)
