# Copyright (C) 2023 Avraham Adler. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   test-wrapper-global
# Author: Avraham Adler
# Date:   6 February 2023
#
# Test wrapper calls to StoGo, ISRES, and CRS algorithms. As many of these
# algorithms have issues, this test suite may not be completed.
#
# Changelog:
#   2023-08-23: Change _output to _stdout. (Avraham Adler)
#   2023-06-24: Reduce tolerance of ISRES tests to pass CRAN. (Aymeric Stamm)
#   2023-06-25: Use analytic gradients and Jacobians for hin/heq. Correct some
#               of the ISRES tests which were pulling on Stogo results.
#               (Avraham Adler)
#

library(nloptr)
tol <- 1e-3 # Stochastic algorithms require a weaker tolerance

depMess <- paste("The old behavior for hin >= 0 has been deprecated. Please",
                 "restate the inequality to be <=0. The ability to use the old",
                 "behavior will be removed in a future release.")

## Functions for the algorithms
rbf <- function(x) {(1 - x[1]) ^ 2 + 100 * (x[2] - x[1] ^ 2) ^ 2}
## Analytic gradient
gr <- function(x) {c(-2 * (1 - x[1]) - 400 * x[1] * (x[2] - x[1] ^ 2),
                     200 * (x[2] - x[1] ^ 2))}
gr.diff <- function(x) nl.grad(x, rbf)

hin <- function(x) 0.25 * x[1L] ^ 2 + x[2L] ^ 2 - 1    # hin <= 0
heq <- function(x) x[1L] + x[2L] - 1                   # heq = 0
hinjac <- function(x) c(0.5 * x[1L], 2 * x[2L])
heqjac <- function(x) c(1, 1)
hin2 <- function(x) -hin(x)                       # Needed to test old behavior
hinjac2 <- function(x) -hinjac(x)

x0 <- c(-1.2, 1)
lb <- c(-3, -3)
ub <- c(3, 3)

## StoGo
# Test printout if nl.info passed. The word "Call:" should be in output if
# passed and not if not passed.
expect_stdout(stogo(x0, rbf, lower = lb, upper = ub, nl.info = TRUE),
              "Call:", fixed = TRUE)

expect_silent(stogo(x0, rbf, lower = lb, upper = ub))

# No passed gradient; Randomized: FALSE
stogoTest <- stogo(x0, rbf, lower = lb, upper = ub)

stogoControl <- nloptr(x0 = x0,
                       eval_f = rbf,
                       eval_grad_f = gr.diff,
                       lb = lb,
                       ub = ub,
                       opts = list(algorithm = "NLOPT_GD_STOGO",
                                   xtol_rel = 1e-6, maxeval = 10000L))

expect_identical(stogoTest$par, stogoControl$solution)
expect_identical(stogoTest$value, stogoControl$objective)
expect_identical(stogoTest$iter, stogoControl$iterations)
expect_identical(stogoTest$convergence, stogoControl$status)
expect_identical(stogoTest$message, stogoControl$message)

# Passed gradient; Randomized: FALSE
stogoTest <- stogo(x0, rbf, gr, lb, ub)

stogoControl <- nloptr(x0 = x0,
                       eval_f = rbf,
                       eval_grad_f = gr,
                       lb = lb,
                       ub = ub,
                       opts = list(algorithm = "NLOPT_GD_STOGO",
                                   xtol_rel = 1e-6, maxeval = 10000L))

expect_identical(stogoTest$par, stogoControl$solution)
expect_identical(stogoTest$value, stogoControl$objective)
expect_identical(stogoTest$iter, stogoControl$iterations)
expect_identical(stogoTest$convergence, stogoControl$status)
expect_identical(stogoTest$message, stogoControl$message)

# Passed gradient; Randomized: TRUE
stogoTest <- stogo(x0, rbf, gr, lb, ub, randomized = TRUE)

stogoControl <- nloptr(x0 = x0,
                       eval_f = rbf,
                       eval_grad_f = gr,
                       lb = lb,
                       ub = ub,
                       opts = list(algorithm = "NLOPT_GD_STOGO_RAND",
                                   xtol_rel = 1e-6, maxeval = 10000L))

expect_identical(stogoTest$par, stogoControl$solution)
expect_identical(stogoTest$value, stogoControl$objective)
expect_identical(stogoTest$iter, stogoControl$iterations)
expect_identical(stogoTest$convergence, stogoControl$status)
expect_identical(stogoTest$message, stogoControl$message)

## ISRES
# Test printout if nl.info passed. The word "Call:" should be in output if
# passed and not if not passed.
expect_stdout(isres(x0, rbf, lb, ub, nl.info = TRUE), "Call:", fixed = TRUE)

expect_silent(isres(x0, rbf, lb, ub))

# As ISRES is stochastic, more iterations and a much looser tolerance is needed.
# Also, iteration count will almost surely not be equal.

# No passed hin or heq
isresTest <- isres(x0, rbf, lb, ub, maxeval = 2e4L)

isresControl <- nloptr(x0 = x0,
                       eval_f = rbf,
                       lb = lb,
                       ub = ub,
                       opts = list(algorithm = "NLOPT_GN_ISRES",
                                   maxeval = 2e4L, xtol_rel = 1e-6,
                                   population = 60))

expect_equal(isresTest$par, isresControl$solution, tolerance = tol)
expect_equal(isresTest$value, isresControl$objective, tolerance = tol)
expect_identical(isresTest$convergence, isresControl$status)
expect_identical(isresTest$message, isresControl$message)

# Passing heq
# Cannot check for value equivalence since the stochastic nature of the problem
# creates different solutions to this "improper" test even using the same seed
# and calls! So dropping maxeval to 1e4 for speed.
# (AA: 2024-06-25)
isresTest <- isres(x0, rbf, lb, ub, heq = heq, maxeval = 1e4L)

isresControl <- nloptr(x0 = x0,
                       eval_f = rbf,
                       eval_g_eq = heq,
                       lb = lb,
                       ub = ub,
                       opts = list(algorithm = "NLOPT_GN_ISRES",
                                   maxeval = 1e4L, xtol_rel = 1e-6,
                                   population = 60))

expect_identical(isresTest$convergence, isresControl$status)
expect_identical(isresTest$message, isresControl$message)

# Passing hin
isresControl <- nloptr(x0 = x0,
                       eval_f = rbf,
                       eval_g_ineq = hin,
                       lb = lb,
                       ub = ub,
                       opts = list(algorithm = "NLOPT_GN_ISRES",
                                   maxeval = 2e4L, xtol_rel = 1e-6,
                                   population = 60))

expect_silent(isres(x0, rbf, lb, ub, hin = hin, maxeval = 2e4L,
                    deprecatedBehavior = FALSE))

isresTest <- isres(x0, rbf, lb, ub, hin = hin, maxeval = 2e4L,
                   deprecatedBehavior = FALSE)

expect_equal(isresTest$par, isresControl$solution, tolerance = tol)
expect_equal(isresTest$value, isresControl$objective, tolerance = tol)
expect_identical(isresTest$convergence, isresControl$status)
expect_identical(isresTest$message, isresControl$message)

# Test deprecated message
expect_warning(isres(x0, rbf, lower = lb, upper = ub, hin = hin2,
                     maxeval = 2e4L), depMess)

# Test deprecated behavior
isresTest <- suppressWarnings(isres(x0, rbf, lb, ub, hin = hin2,
                                    maxeval = 2e4L))

expect_equal(isresTest$par, isresControl$solution, tolerance = tol)
expect_equal(isresTest$value, isresControl$objective, tolerance = tol)
expect_identical(isresTest$convergence, isresControl$status)
expect_identical(isresTest$message, isresControl$message)

## CRS2LM
# Take these outside the function since they are unchanging; just pass them!
a <- c(1.0, 1.2, 3.0, 3.2)
A <- matrix(c(10,  0.05, 3, 17,
              3, 10, 3.5, 8,
              17, 17, 1.7, 0.05,
              3.5, 0.1, 10, 10,
              1.7, 8, 17, 0.1,
              8, 14, 8, 14), nrow = 4)

B  <- matrix(c(0.1312, 0.2329, 0.2348, 0.4047,
               0.1696, 0.4135, 0.1451, 0.8828,
               0.5569, 0.8307, 0.3522, 0.8732,
               0.0124, 0.3736, 0.2883, 0.5743,
               0.8283, 0.1004, 0.3047, 0.1091,
               0.5886, 0.9991, 0.6650, 0.0381), nrow = 4)

hartmann6 <- function(x, a, A, B) {
  fun <- 0
  for (i in 1:4) {
    fun <- fun - a[i] * exp(-sum(A[i, ] * (x - B[i, ]) ^ 2))
  }

  fun
}

# Test printout if nl.info passed. The word "Call:" should be in output if
# passed and not if not passed.
x0 <- lb <- rep(0, 6L)
ub <- rep(1, 6L)

expect_stdout(crs2lm(x0 = x0, hartmann6, lower = lb, upper = ub,
                     nl.info = TRUE, a = a, A = A, B = B),
              "Call:", fixed = TRUE)

expect_silent(crs2lm(x0 = x0, hartmann6, lower = lb, upper = ub,
                     a = a, A = A, B = B))

crs2lmTest <- crs2lm(x0 = x0, hartmann6, lower = lb, upper = ub, ranseed = 43L,
                     xtol_rel = 1e-8, maxeval = 100L, a = a, A = A, B = B)

crs2lmControl <- nloptr(x0 = x0,
                        eval_f = hartmann6,
                        lb = lb,
                        ub = ub,
                        a = a,
                        A = A,
                        B = B,
                        opts = list(algorithm = "NLOPT_GN_CRS2_LM",
                                    xtol_rel = 1e-8,
                                    maxeval = 100L,
                                    ranseed = 43L,
                                    population = 70))

expect_identical(crs2lmTest$par, crs2lmControl$solution)
expect_identical(crs2lmTest$value, crs2lmControl$objective)
expect_identical(crs2lmTest$iter, crs2lmControl$iterations)
expect_identical(crs2lmTest$convergence, crs2lmControl$status)
expect_identical(crs2lmTest$message, crs2lmControl$message)
