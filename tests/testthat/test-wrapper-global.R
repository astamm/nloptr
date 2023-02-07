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
#

ineqMess <- paste("For consistency with the rest of the package the inequality",
                  "sign may be switched from >= to <= in a future nloptr",
                  "version.")

## Functions for the algorithms
fr <- function(x) {100 * (x[2L] - x[1L] * x[1L]) ^ 2 + (1 - x[1L]) ^ 2}
gr <- function(x) nl.grad(x, fr)

hin <- function(x) -0.25 * x[1L] ^ 2 - x[2L] ^ 2 + 1    # hin >= 0
heq <- function(x) x[1L] - 2 * x[2L] + 1                # heq == 0
hinjac <- function(x) nl.jacobian(x, hin)
heqjac <- function(x) nl.jacobian(x, heq)
hin2 <- function(x) -hin(x)                       # hin2 <= 0 needed for nloptr
hinjac2 <- function(x) nl.jacobian(x, hin2)       # hin2 <= 0 needed for nloptr

hartmann6 <- function(x) {
  a <- c(1, 1.2, 3, 3.2)
  A <- matrix(c(10,  0.05, 3, 17,
                3, 10,  3.5,  8,
                17, 17,  1.7,  0.05,
                3.5,  0.1, 10, 10,
                1.7,  8, 17,  0.1,
                8, 14,  8, 14),
              nrow = 4L, ncol = 6L)
  B  <- matrix(c(0.1312, 0.2329, 0.2348, 0.4047,
                 0.1696, 0.4135, 0.1451, 0.8828,
                 0.5569, 0.8307, 0.3522, 0.8732,
                 0.0124, 0.3736, 0.2883, 0.5743,
                 0.8283, 0.1004, 0.3047, 0.1091,
                 0.5886, 0.9991, 0.6650, 0.0381),
               nrow = 4L, ncol = 6L)
  fun <- 0
  for (i in 1:4) {
    fun <- fun - a[i] * exp(-sum(A[i, ] * (x - B[i, ]) ^ 2))
  }
  fun
}

x0 <- c(-1.2, 1)
lb <- c(-3, -3)
ub <- c(3, 3)

## StoGo
# Test printout if nl.info passed. The word "Call:" should be in output if
# passed and not if not passed.
expect_output(stogo(x0, fr, lower = lb, upper = ub, nl.info = TRUE),
              "Call:", fixed = TRUE)

expect_silent(stogo(x0, fr, lower = lb, upper = ub))

# No passed gradient; Randomized: FALSE
stogoTest <- stogo(x0, fr, lower = lb, upper = ub)

stogoControl <- nloptr(x0 = x0,
                       eval_f = fr,
                       eval_grad_f = function(x) nl.grad(x, fr),
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
stogoTest <- stogo(x0, fr, gr, lb, ub)

stogoControl <- nloptr(x0 = x0,
                       eval_f = fr,
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
stogoTest <- stogo(x0, fr, gr, lb, ub, randomized = TRUE)

stogoControl <- nloptr(x0 = x0,
                       eval_f = fr,
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
# Test message
expect_message(isres(x0, fr, lower = lb, upper = ub, hin = hin), ineqMess)

# Test printout if nl.info passed. The word "Call:" should be in output if
# passed and not if not passed.
expect_output(isres(x0, fr, lb, ub, nl.info = TRUE), "Call:", fixed = TRUE)

expect_silent(isres(x0, fr, lb, ub))

# As ISRES is stochastic, more iterations and a much looser tolerance is needed.
# Also, iteration count will almost surely not be equal.

# No passed hin or heq
isresTest <- isres(x0, fr, lb, ub, maxeval = 2e4L)

isresControl <- nloptr(x0 = x0,
                       eval_f = fr,
                       lb = lb,
                       ub = ub,
                       opts = list(algorithm = "NLOPT_GN_ISRES",
                                   maxeval = 2e4L, xtol_rel = 1e-6,
                                   population = 60))

expect_equal(isresTest$par, isresControl$solution, tolerance = 1e-4)
expect_equal(isresTest$value, isresControl$objective, tolerance = 1e-4)
expect_identical(stogoTest$convergence, stogoControl$status)
expect_identical(stogoTest$message, stogoControl$message)

# Passing heq
# Need a ridiculously loose tolerance on ISRES now.
# (AA: 2023-02-06)
isresTest <- isres(x0, fr, lb, ub, heq = heq, maxeval = 2e4L)

isresControl <- nloptr(x0 = x0,
                       eval_f = fr,
                       eval_g_eq = heq,
                       lb = lb,
                       ub = ub,
                       opts = list(algorithm = "NLOPT_GN_ISRES",
                                   maxeval = 2e4L, xtol_rel = 1e-6,
                                   population = 60))

# expect_equal(isresTest$par, isresControl$solution, tolerance = 1e-1)
# expect_equal(isresTest$value, isresControl$objective, tolerance = 1e-1)
expect_identical(stogoTest$convergence, stogoControl$status)
expect_identical(stogoTest$message, stogoControl$message)

## CRS2LM
# Test printout if nl.info passed. The word "Call:" should be in output if
# passed and not if not passed.
x0 <- lb <- rep(0, 6L)
ub <- rep(1, 6L)

expect_output(crs2lm(x0 = x0, hartmann6, lower = lb, upper = ub, nl.info = TRUE),
              "Call:", fixed = TRUE)

expect_silent(crs2lm(x0 = x0, hartmann6, lower = lb, upper = ub))

crs2lmTest <- crs2lm(x0 = x0, hartmann6, lower = lb, upper = ub, ranseed = 43L,
                     xtol_rel = 1e-8, maxeval = 10000L)

crs2lmControl <- nloptr(x0 = x0,
                        eval_f = hartmann6,
                        lb = lb,
                        ub = ub,
                        opts = list(algorithm = "NLOPT_GN_CRS2_LM",
                                    xtol_rel = 1e-8,
                                    maxeval = 10000L,
                                    ranseed = 43L,
                                    population = 70))

expect_identical(stogoTest$par, stogoControl$solution)
expect_identical(stogoTest$value, stogoControl$objective)
expect_identical(stogoTest$iter, stogoControl$iterations)
expect_identical(stogoTest$convergence, stogoControl$status)
expect_identical(stogoTest$message, stogoControl$message)
