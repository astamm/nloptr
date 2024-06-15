# Copyright (C) 2023 Avraham Adler. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   test-wrapper-cobyla
# Author: Avraham Adler
# Date:   6 February 2023
#
# Test wrapper calls to cobyla, bobyqa, and newuoa algorithms
#
# CHANGELOG
#
# 2023-08-23: Change _output to _stdout
# 2024-06-04: Switched desired direction of the hin/hinjac inequalities, leaving
#       the old behavior as the default for now. Also cleaned up the HS100
#       example (Avraham Adler).
#

library(nloptr)

depMess <- paste("The old behavior for hin >= 0 has been deprecated. Please",
                 "restate the inequality to be <=0. The ability to use the old",
                 "behavior will be removed in a future release.")

## Functions for COBYLA, BOBYQA, and NEWUOA
x0.hs100 <- c(1, 2, 0, 4, 0, 1, 1)
fn.hs100 <- function(x) {(x[1] - 10) ^ 2 + 5 * (x[2] - 12) ^ 2 + x[3] ^ 4 +
    3 * (x[4] - 11) ^ 2 + 10 * x[5] ^ 6 + 7 * x[6] ^ 2 +
    x[7] ^ 4 - 4 * x[6] * x[7] - 10 * x[6] - 8 * x[7]}

hin.hs100 <- function(x) {c(
  2 * x[1] ^ 2 + 3 * x[2] ^ 4 + x[3] + 4 * x[4] ^ 2 + 5 * x[5] - 127,
  7 * x[1] + 3 * x[2] + 10 * x[3] ^ 2 + x[4] - x[5] - 282,
  23 * x[1] + x[2] ^ 2 + 6 * x[6] ^ 2 - 8 * x[7] - 196,
  4 * x[1] ^ 2 + x[2] ^ 2 - 3 * x[1] * x[2] + 2 * x[3] ^ 2 + 5 * x[6] -
    11 * x[7])
}

hin2.hs100 <- function(x) -hin.hs100(x)           # Needed to test old behavior

rbf <- function(x) {(1 - x[1]) ^ 2 + 100 * (x[2] - x[1] ^ 2) ^ 2}

ctl <- list(xtol_rel = 1e-8)

# Test printout if nl.info passed. The word "Call:" should be in output if
# passed and not if not passed.
expect_stdout(cobyla(x0.hs100, fn.hs100, nl.info = TRUE,
                     deprecatedBehavior = FALSE), "Call:", fixed = TRUE)
expect_stdout(bobyqa(x0.hs100, fn.hs100, nl.info = TRUE), "Call:", fixed = TRUE)
expect_stdout(newuoa(x0.hs100, fn.hs100, nl.info = TRUE), "Call:", fixed = TRUE)

expect_silent(cobyla(x0.hs100, fn.hs100, deprecatedBehavior = FALSE))
expect_silent(bobyqa(x0.hs100, fn.hs100))
expect_silent(newuoa(x0.hs100, fn.hs100))

# Test COBYLA algorithm
cobylaTest <- cobyla(x0.hs100, fn.hs100, hin = hin.hs100, control = ctl,
                     deprecatedBehavior = FALSE)

cobylaControl <- nloptr(x0 = x0.hs100,
                        eval_f = fn.hs100,
                        eval_g_ineq = hin.hs100,
                        opts = list(algorithm = "NLOPT_LN_COBYLA",
                                    xtol_rel = 1e-8, maxeval = 1000L))

expect_identical(cobylaTest$par, cobylaControl$solution)
expect_identical(cobylaTest$value, cobylaControl$objective)
expect_identical(cobylaTest$iter, cobylaControl$iterations)
expect_identical(cobylaTest$convergence, cobylaControl$status)
expect_identical(cobylaTest$message, cobylaControl$message)

# Test deprecated message
expect_warning(cobyla(x0.hs100, fn.hs100, hin = hin2.hs100), depMess)

# Test deprecated behavior
cobylaTest <- suppressWarnings(cobyla(x0.hs100, fn.hs100, hin = hin2.hs100,
                                      control = ctl))

expect_identical(cobylaTest$par, cobylaControl$solution)
expect_identical(cobylaTest$value, cobylaControl$objective)
expect_identical(cobylaTest$iter, cobylaControl$iterations)
expect_identical(cobylaTest$convergence, cobylaControl$status)
expect_identical(cobylaTest$message, cobylaControl$message)

# Test BOBYQA algorithm
bobyqaTest <- bobyqa(c(0, 0), rbf, lower = c(0, 0), upper = c(0.5, 0.5))

bobyqaControl <- nloptr(x0 = c(0, 0), eval_f = rbf, lb = c(0, 0),
                        ub = c(0.5, 0.5),
                        opts = list(algorithm = "NLOPT_LN_BOBYQA",
                                    xtol_rel = 1e-6, maxeval = 1000L))

expect_identical(bobyqaTest$par, bobyqaControl$solution)
expect_identical(bobyqaTest$value, bobyqaControl$objective)
expect_identical(bobyqaTest$iter, bobyqaControl$iterations)
expect_identical(bobyqaTest$convergence, bobyqaControl$status)
expect_identical(bobyqaTest$message, bobyqaControl$message)

# Test NEWUOA algorithm
newuoaTest <- newuoa(c(1, 2), rbf)

newuoaControl <- nloptr(x0 = c(1, 2), eval_f = rbf,
                        opts = list(algorithm = "NLOPT_LN_NEWUOA",
                                    xtol_rel = 1e-6, maxeval = 1000L))

expect_identical(newuoaTest$par, newuoaControl$solution)
expect_identical(newuoaTest$value, newuoaControl$objective)
expect_identical(newuoaTest$iter, newuoaControl$iterations)
expect_identical(newuoaTest$convergence, newuoaControl$status)
expect_identical(newuoaTest$message, newuoaControl$message)
