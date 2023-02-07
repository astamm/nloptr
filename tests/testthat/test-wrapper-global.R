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
  B  <- matrix(c(.1312, .2329, .2348, .4047,
                 .1696, .4135, .1451, .8828,
                 .5569, .8307, .3522, .8732,
                 .0124, .3736, .2883, .5743,
                 .8283, .1004, .3047, .1091,
                 .5886, .9991, .6650, .0381),
               nrow = 4L, ncol = 6L)
  fun <- 0
  for (i in 1:4) {
    fun <- fun - a[i] * exp(-sum(A[i, ] * (x - B[i, ]) ^ 2))
  }
  fun
}

## StoGo
# Test printout if nl.info passed. The word "Call:" should be in output if
# passed and not if not passed.
expect_output(suppressMessages(stogo(c(-1.2, 1), fr, lower = c(-3, -3),
                                     upper = c(3, 3), nl.info = TRUE)),
              "Call:", fixed = TRUE)

expect_silent(suppressMessages(stogo(c(-1.2, 1), fr, lower = c(-3, -3),
                                     upper = c(3, 3))))

# No passed gradient; Randomized: FALSE
stogoTest <- suppressMessages(stogo(c(-1.2, 1), fr, lower = c(-3, -3),
                                    upper = c(3, 3)))

stogoControl <- nloptr(x0 = c(-1.2, 1),
                       eval_f = fr,
                       eval_grad_f = function(x) nl.grad(x, fr),
                       lb = c(-3, -3),
                       ub = c(3, 3),
                       opts = list(algorithm = "NLOPT_GD_STOGO",
                                    xtol_rel = 1e-6, maxeval = 10000L))

expect_identical(stogoTest$par, stogoControl$solution)
expect_identical(stogoTest$value, stogoControl$objective)
expect_identical(stogoTest$iter, stogoControl$iterations)
expect_identical(stogoTest$convergence, stogoControl$status)
expect_identical(stogoTest$message, stogoControl$message)

# Passed gradient; Randomized: FALSE
stogoTest <- suppressMessages(stogo(c(-1.2, 1), fr, lower = c(-3, -3), gr = gr,
                                    upper = c(3, 3)))

stogoControl <- nloptr(x0 = c(-1.2, 1),
                       eval_f = fr,
                       eval_grad_f = gr,
                       lb = c(-3, -3),
                       ub = c(3, 3),
                       opts = list(algorithm = "NLOPT_GD_STOGO",
                                   xtol_rel = 1e-6, maxeval = 10000L))

expect_identical(stogoTest$par, stogoControl$solution)
expect_identical(stogoTest$value, stogoControl$objective)
expect_identical(stogoTest$iter, stogoControl$iterations)
expect_identical(stogoTest$convergence, stogoControl$status)
expect_identical(stogoTest$message, stogoControl$message)

# Passed gradient; Randomized: TRUE
stogoTest <- suppressMessages(stogo(c(-1.2, 1), fr, lower = c(-3, -3), gr = gr,
                                    upper = c(3, 3), randomized = TRUE))

stogoControl <- nloptr(x0 = c(-1.2, 1),
                       eval_f = fr,
                       eval_grad_f = gr,
                       lb = c(-3, -3),
                       ub = c(3, 3),
                       opts = list(algorithm = "NLOPT_GD_STOGO_RAND",
                                   xtol_rel = 1e-6, maxeval = 10000L))

expect_identical(stogoTest$par, stogoControl$solution)
expect_identical(stogoTest$value, stogoControl$objective)
expect_identical(stogoTest$iter, stogoControl$iterations)
expect_identical(stogoTest$convergence, stogoControl$status)
expect_identical(stogoTest$message, stogoControl$message)

## ISRES
# Test message
expect_message(isres(c(-1.2, 1), fr, lower = c(-3, -3), upper = c(3, 3),
                     hin = hin, nl.info = FALSE), ineqMess)

# Test printout if nl.info passed. The word "Call:" should be in output if
# passed and not if not passed.
expect_output(suppressMessages(isres(c(-1.2, 1), fr, lower = c(-3, -3),
                                     upper = c(3, 3), nl.info = TRUE)),
              "Call:", fixed = TRUE)

expect_silent(suppressMessages(isres(c(-1.2, 1), fr, lower = c(-3, -3),
                                     upper = c(3, 3))))

# As ISRES is stochastic, more iterations and a much looser tolerance is needed.
# Also, iteration count will almost surely not be equal.

# No passed hin or heq
isresTest <- suppressMessages(isres(c(-1.2, 1), fr, lower = c(-3, -3),
                                    upper = c(3, 3), maxeval = 2e4L))

isresControl <- nloptr(x0 = c(-1.2, 1),
                       eval_f = fr,
                       lb = c(-3, -3),
                       ub = c(3, 3),
                       opts = list(algorithm = "NLOPT_GN_ISRES",
                                   maxeval = 2e4L, xtol_rel = 1e-6,
                                   population = 60))

expect_equal(isresTest$par, isresControl$solution, tolerance = 1e-4)
expect_equal(isresTest$value, isresControl$objective, tolerance = 1e-4)
expect_identical(stogoTest$convergence, stogoControl$status)
expect_identical(stogoTest$message, stogoControl$message)

# Passing heq
# Need a rediculously loose tolerance on ISRES now.
# (AA: 2023-02-06)
isresTest <- suppressMessages(isres(c(-1.2, 1), fr, lower = c(-3, -3),
                                    upper = c(3, 3), heq = heq, maxeval = 2e4L,
                                    xtol_rel = 1e-6))

isresControl <- nloptr(x0 = c(-1.2, 1),
                       eval_f = fr,
                       eval_g_eq = heq,
                       lb = c(-3, -3),
                       ub = c(3, 3),
                       opts = list(algorithm = "NLOPT_GN_ISRES",
                                   maxeval = 2e4L, xtol_rel = 1e-6,
                                   population = 60))

expect_equal(isresTest$par, isresControl$solution, tolerance = 1e-1)
expect_equal(isresTest$value, isresControl$objective, tolerance = 1e-1)
expect_identical(stogoTest$convergence, stogoControl$status)
expect_identical(stogoTest$message, stogoControl$message)

## CRS2LM
# Test printout if nl.info passed. The word "Call:" should be in output if
# passed and not if not passed.
expect_output(suppressMessages(crs2lm(x0 = rep(0, 6L), hartmann6,
                                      lower = rep(0, 6L), upper = rep(1, 6L),
                                      nl.info = TRUE, xtol_rel = 1e-8,
                                      maxeval = 10000L)),
              "Call:", fixed = TRUE)

expect_silent(suppressMessages(crs2lm(x0 = rep(0, 6L), hartmann6,
                                      lower = rep(0, 6L), upper = rep(1, 6L),
                                      xtol_rel = 1e-8, maxeval = 10000L)))

crs2lmTest <- suppressMessages(crs2lm(x0 = rep(0, 6L), hartmann6, ranseed = 43L,
                                      lower = rep(0, 6L), upper = rep(1, 6L),
                                      xtol_rel = 1e-8, maxeval = 10000L))

crs2lmControl <- nloptr(x0 = rep(0, 6L),
                        eval_f = hartmann6,
                        lb = rep(0, 6L),
                        ub = rep(1, 6L),
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
