# Copyright (C) 2023 Avraham Adler. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   test-nloptr
# Author: Avraham Adler
# Date:   7 February 2023
#
# Test code in nloptr.R and nloptr.c which is not tested elsewhere.
#
# Changelog:
#   2023-08-23: Converted snapshots to testing portions of outputs and messages.
#
# It is possible for NLOPT to go slightly beyond maxtime or maxeval, especially
# for the global algorithms, which is why the stopping criterion has a
# weird-looking test. See
# https://nlopt.readthedocs.io/en/latest/NLopt_Reference/#stopping-criteria

library(nloptr)
options(digits = 7)

tol <- sqrt(.Machine$double.eps)

########################## Tests for nloptr.R ##################################

ctlNM <- list(algorithm = "NLOPT_LN_NELDERMEAD", xtol_rel = 1e-8,
              check_derivatives = FALSE)

# check x0
expect_error(nloptr("3", function(x) x, opts = ctlNM),
             "x0 must be numeric", fixed = TRUE)
expect_error(nloptr(numeric(), function(x) x, opts = ctlNM),
             "x0 must have length > 0", fixed = TRUE)

ctlNM <- list(algorithm = "NLOPT_LN_NELDERMEAD", xtol_rel = 1e-8,
              check_derivatives = TRUE)
ctlSQP <- list(algorithm = "NLOPT_LD_SLSQP", xtol_rel = 1e-8,
               check_derivatives = TRUE)

# internal function to check the arguments of the functions
expect_error(nloptr(3, "Zed"), "must be a function", fixed = TRUE)

fn <- function(x, b = NULL, c = NULL) x
expect_error(nloptr(3, fn, c = "Q"),
             "but this has not been passed to the 'nloptr' function",
             fixed = TRUE)

expect_error(nloptr(3, fn, b = "X", c = "Y", d = "Q"),
             "passed to (...) in 'nloptr' but this is not required in the",
             fixed = TRUE)

expect_warning(nloptr(3, fn, b = 3, c = 4, opts = ctlNM),
               "Skipping derivative checker because algorithm", fixed = TRUE)

########################## Tests for nloptr.c ##################################
ctl <- list(xtol_rel = 1e-8, maxeval = 1000L)
fn <- function(x) x ^ 2 - 4 * x + 4
lb <- 0
ub <- 6
optSol <- 2
optVal <- 0

## NLOPT_GN_DIRECT_L_NOSCAL
alg <- list(algorithm = "NLOPT_GN_DIRECT_L_NOSCAL")
testRun <- nloptr(5, fn, lb = lb, ub = ub, opts = c(alg, ctl))

expect_equal(testRun$solution, optSol, tolerance = tol)
expect_equal(testRun$objective, optVal, tolerance = tol)
expect_true(testRun$iterations <= ctl$maxeval + 5)
expect_true(testRun$status > 0)

## NLOPT_GN_DIRECT_L_RAND_NOSCAL
alg <- list(algorithm = "NLOPT_GN_DIRECT_L_RAND_NOSCAL")
testRun <- nloptr(5, fn, lb = lb, ub = ub, opts = c(alg, ctl))

expect_equal(testRun$solution, optSol, tolerance = tol)
expect_equal(testRun$objective, optVal, tolerance = tol)
expect_true(testRun$iterations <= ctl$maxeval + 5)
expect_true(testRun$status > 0)

## NLOPT_LN_PRAXIS
alg <- list(algorithm = "NLOPT_LN_PRAXIS")
testRun <- nloptr(5, fn, lb = lb, ub = ub, opts = c(alg, ctl))

expect_equal(testRun$solution, optSol, tolerance = tol)
expect_equal(testRun$objective, optVal, tolerance = tol)
expect_true(testRun$iterations <= ctl$maxeval + 5)
expect_true(testRun$status > 0)

## NLOPT_GN_MLSL
alg <- list(algorithm = "NLOPT_GN_MLSL")
lopts <- list(local_opts = list(algorithm = "NLOPT_LN_COBYLA", xtol_rel = 1e-8))
testRun <- nloptr(5, fn, lb = lb, ub = ub, opts = c(alg, ctl, lopts))

expect_equal(testRun$solution, optSol, tolerance = tol)
expect_equal(testRun$objective, optVal, tolerance = tol)
expect_true(testRun$iterations <= ctl$maxeval + 5)
expect_true(testRun$status > 0)

## NLOPT_GN_MLSL_LDS
alg <- list(algorithm = "NLOPT_GN_MLSL_LDS")
lopts <- list(local_opts = list(algorithm = "NLOPT_LN_COBYLA", xtol_rel = 1e-8))
testRun <- nloptr(5, fn, lb = lb, ub = ub, opts = c(alg, ctl, lopts))

expect_equal(testRun$solution, optSol, tolerance = tol)
expect_equal(testRun$objective, optVal, tolerance = tol)
expect_true(testRun$iterations <= ctl$maxeval + 5)
expect_true(testRun$status > 0)

## NLOPT_LN_AUGLAG_EQ
x0 <- c(-2, 2, 2, -1, -1)
fn1 <- function(x) exp(x[1] * x[2] * x[3] * x[4] * x[5])

eqn1 <- function(x) {
  c(x[1] * x[1] + x[2] * x[2] + x[3] * x[3] + x[4] * x[4] + x[5] * x[5],
    x[2] * x[3] - 5 * x[4] * x[5],
    x[1] * x[1] * x[1] + x[2] * x[2] * x[2])
}

optSol <- rep(0, 5)
optVal <- 1

testRun <- nloptr(x0, fn1, eval_g_eq = eqn1,
                  opts = list(algorithm = "NLOPT_LN_AUGLAG_EQ", xtol_rel = 1e-6,
                              maxeval = 10000L,
                              local_opts = list(algorithm = "NLOPT_LN_COBYLA",
                                                xtol_rel = 1e-6, maxeval = 1000L)))

expect_equal(testRun$solution, optSol, tolerance = tol)
expect_equal(testRun$objective, optVal, tolerance = tol)
expect_true(testRun$iterations <=  10005L)
expect_true(testRun$status > 0)

## NLOPT_LD_AUGLAG_EQ
gr1 <- function(x) {
  c(x[2] * x[3] * x[4] * x[5],
    x[1] * x[3] * x[4] * x[5],
    x[1] * x[2] * x[4] * x[5],
    x[1] * x[2] * x[3] * x[5],
    x[1] * x[2] * x[3] * x[4]) * exp(prod(x))
}

heqjac <- function(x) nl.jacobian(x0, eqn1)

testRun <- nloptr(x0, fn1, gr1, eval_g_eq = eqn1, eval_jac_g_eq = heqjac,
                  opts = list(algorithm = "NLOPT_LD_AUGLAG_EQ", xtol_rel = 1e-6,
                              maxeval = 10000L,
                              local_opts = list(algorithm = "NLOPT_LN_COBYLA",
                                                xtol_rel = 1e-6, maxeval = 1000L)))

expect_equal(testRun$solution, optSol, tolerance = tol)
expect_equal(testRun$objective, optVal, tolerance = tol)
expect_true(testRun$iterations <=  10005L)
expect_true(testRun$status > 0)

# https://www.wolframalpha.com/input?i=minimum+of+x+%5E+4+%2B+y+%5E+2+-+5+*+x+*+y++%2B+5+ # nolint
fn <- function(x) x[1L] ^ 4 + x[2L] ^ 2 - 5 * x[1L] * x[2L] + 5
gr <- function(x) c(4 * x[1L] ^ 3 - 5 * x[2L], 2 * x[2L] - 5 * x[1L])

lb <- c(0, 0)
ub <- c(5, 5)

optSol <- c(5 / (2 * sqrt(2)), 25 / (4 * sqrt(2)))
optVal <- -305 / 64

## TO DO: check why this is not working
## NLOPT_LN_NEWUOA_BOUND
# alg <- list(algorithm = "NLOPT_LN_NEWUOA_BOUND")
# testRun <- nloptr(c(1, 1), fn, lb = lb, ub = ub, opts = c(alg, ctl))
#
# expect_equal(testRun$solution, optSol, tolerance = 1e-5)
# expect_equal(testRun$objective, optVal, tolerance = tol)
# expect_true(testRun$iterations <= ctl$maxeval + 5)
# expect_true(testRun$status > 0)

## NLOPT_GN_ESCH
alg <- list(algorithm = "NLOPT_GN_ESCH")
ctl <- list(xtol_rel = 1e-8, maxeval = 50000L)
testRun <- nloptr(c(1, 1), fn, lb = lb, ub = ub, opts = c(alg, ctl))

expect_equal(testRun$solution, optSol, tolerance = 1e-2)
expect_equal(testRun$objective, optVal, tolerance = 1e-2)
expect_true(testRun$iterations <= ctl$maxeval + 5)
expect_true(testRun$status > 0)

if (nloptr:::have.nlopt.ld.lbfgs.nocedal) {
  ## NLOPT_LD_LBFGS_NOCEDAL
  # NLOPT_LD_LBFGS_NOCEDAL as this algorithm has not been included as of NLOPT
  # 2.7.1 per https://github.com/stevengj/nlopt/issues/40 so the expected outcome
  # is NLOPT_INVALID_ARGS. Perhaps we should ring-fence it for now?
  # (AA: 2023-02-08)
  alg <- list(algorithm = "NLOPT_LD_LBFGS_NOCEDAL")
  testRun <- nloptr(c(1, 1), fn, gr, lb = lb, ub = ub, opts = c(alg, ctl))

  minus2mess <- paste("NLOPT_INVALID_ARGS: Invalid arguments (e.g. lower bounds",
                      "are bigger than upper bounds, an unknown algorithm was",
                      "specified, etcetera).")

  expect_identical(testRun$status, -2L)
  expect_identical(testRun$message, minus2mess)
}

## case NLOPT_FAILURE
fnl <- function(x) {
  list(objective = (x[1] - 1) ^ 2 + (x[2] - 1) ^ 2,
       gradient = c(4 * (x[1] - 1), 3 - (x[2] - 1)))
}
x0 <- c(3, 3)
testRun <- nloptr(x0, fnl,
                  opts = list(algorithm = "NLOPT_LD_LBFGS", xtol_rel = 1e-8))

expect_identical(testRun$status, -1L)
expect_identical(testRun$message, "NLOPT_FAILURE: Generic failure code.")

# Tinytest has no snapshot functionality. Instead, this will test the output
# and message against portions of the expected, instead of the totality.

## MULTIVARIATE FUNCTION
x0 <- c(2, 2)
ub <- c(5, 5)
lb <- c(-1, -1)
fn <- function(x) (x[1L] - 1) ^ 2 + (x[2L] - 1) ^ 2 + 1
gr <- function(x) c(2 * (x[1L] - 1), 2 * (x[2L] - 1))
hin <- function(x) c(1.44 - x[1L] ^ 2, 2.197 - x[2L] ^ 3)
hinjac <- function(x) matrix(c(-2 * x[1L], 0, 0, -3 * x[2L] ^ 2), 2L, 2L)
heq <- function(x) c(x[1L] * x[2L] - 2.55, x[1L] - x[2L] - 0.2)
heqjac <- function(x) matrix(c(x[2L], 1, x[1L], -1), 2L)
optSol <- c(1.7, 1.5)
optVal <- 1.74

expect_stdout(
  suppressMessages(
    nloptr(x0, fn, gr, lb, ub, hin, hinjac, heq, heqjac,
           opts = list(algorithm = "NLOPT_LD_SLSQP", xtol_rel = 1e-8,
                       print_level = 3, check_derivatives = TRUE))
  ),
  "g(x) = (-1.450000, -1.178000)", fixed = TRUE
)

# Wrap in capture.output to prevent wall of text on screen when running. This is
# to test the message; expect_stdout tests the output.
expect_message(
  capture.output(
    nloptr(x0, fn, gr, lb, ub, hin, hinjac, heq, heqjac,
           opts = list(algorithm = "NLOPT_LD_SLSQP", xtol_rel = 1e-8,
                       print_level = 3, check_derivatives = TRUE)),
    type = "output"
  ),
  "eval_jac_g_ineq[1, 1] = -4.0e+00 ~ -4.0e+00   [7.450581e-09]", fixed = TRUE
)

## UNIVARIATE FUNCTION
x0 <- 5
fn <- function(x) x ^ 2 - 4 * x + 4
gr <- function(x) 2 * x - 4
hin <- function(x) 5.29 - x ^ 2
hinjac <- function(x) -2 * x
heq <- function(x) 10 * x - 27
heqjac <- function(x) 10
lb <- 0
ub <- 6
optSol <- 2.7
optVal <- 0.49

## UNIVARIATE
expect_stdout(
  suppressMessages(
    nloptr(x0, fn, gr, lb, ub, hin, hinjac, heq, heqjac,
           opts = list(algorithm = "NLOPT_LD_SLSQP", xtol_rel = 1e-8,
                       print_level = 3, check_derivatives = TRUE))
  ),
  "g(x) = -2.000000", fixed = TRUE
)

expect_message(
  capture.output(
    nloptr(x0, fn, gr, lb, ub, hin, hinjac, heq, heqjac,
           opts = list(algorithm = "NLOPT_LD_SLSQP", xtol_rel = 1e-8,
                       print_level = 3, check_derivatives = TRUE)),
    type = "output"
  ),
  "eval_jac_g_ineq[1] = -1e+01 ~ -1e+01   [9.536743e-09]", fixed = TRUE
)

# Test NLOPT_ROUNDOFF_LIMITED
expect_true(
  grepl("Roundoff errors led to a breakdown",
        nloptr(x0, fn, gr, opts = list(algorithm = "NLOPT_LD_SLSQP",
                                       xtol_rel = -Inf))$message,
        fixed = TRUE)
)

# Test triggering stopval
expect_true(
  grepl("Optimization stopped because stopval",
        nloptr(c(4, 4), fn, opts = list(algorithm = "NLOPT_LN_SBPLX",
                                        stopval = 20))$message,
        fixed = TRUE)
)
