# Copyright (C) 2023 Avraham Adler. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   test-wrapper-slsqp
# Author: Avraham Adler
# Date:   6 February 2023
#
# Test wrapper calls for the Sequential Quadratic Programming algorithm.
#
# Changelog:
#   2023-08-23: Change _output to _stdout
#

library(nloptr)

tol <- sqrt(.Machine$double.eps)

depMess <- paste("The old behavior for hin >= 0 has been deprecated. Please",
                 "restate the inequality to be <=0. The ability to use the old",
                 "behavior will be removed in a future release.")

# Taken from example
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

gr.hs100 <- function(x) {
  c( 2 * x[1] - 20,
     10 * x[2] - 120,
     4 * x[3] ^ 3,
     6 * x[4] - 66,
     60 * x[5] ^ 5,
     14 * x[6] - 4 * x[7] - 10,
     4 * x[7] ^ 3 - 4 * x[6] - 8)
}

hinjac.hs100 <- function(x) {
  matrix(c(4 * x[1], 12 * x[2] ^ 3, 1, 8 * x[4], 5, 0, 0,
           7, 3, 20 * x[3], 1, -1, 0, 0,
           23, 2 * x[2], 0, 0, 0, 12 * x[6], -8,
           8 * x[1] - 3 * x[2], 2 * x[2] - 3 * x[1], 4 * x[3], 0, 0, 5, -11),
         nrow = 4, byrow = TRUE)
}

hin2.hs100 <- function(x) -hin.hs100(x)           # Needed to test old behavior
hinjac2.hs100 <- function(x) -hinjac.hs100(x)     # Needed to test old behavior

gr.hs100.computed <- function(x) nl.grad(x, fn.hs100)
hinjac.hs100.computed <- function(x) nl.jacobian(x, hin.hs100)
hinjac2.hs100.computed <- function(x) nl.jacobian(x, hin2.hs100)

# Test printout if nl.info passed. The word "Call:" should be in output if
# passed and not if not passed.
expect_stdout(slsqp(x0.hs100, fn = fn.hs100, nl.info = TRUE),
              "Call:", fixed = TRUE)

expect_silent(slsqp(x0.hs100, fn = fn.hs100))

# No passed gradient or Inequality Jacobians
slsqpTest <- slsqp(x0.hs100, fn.hs100, hin = hin.hs100,
                   deprecatedBehavior = FALSE)

slsqpControl <- nloptr(x0 = x0.hs100,
                       eval_f = fn.hs100,
                       eval_grad_f = gr.hs100.computed,
                       eval_g_ineq = hin.hs100,
                       eval_jac_g_ineq = hinjac.hs100.computed,
                       opts = list(algorithm = "NLOPT_LD_SLSQP",
                                   xtol_rel = 1e-6, maxeval = 1000L))

expect_identical(slsqpTest$par, slsqpControl$solution)
expect_identical(slsqpTest$value, slsqpControl$objective)
expect_identical(slsqpTest$iter, slsqpControl$iterations)
expect_identical(slsqpTest$convergence, slsqpControl$status)
expect_identical(slsqpTest$message, slsqpControl$message)

# Passed gradient or Inequality Jacobians
slsqpTest <- slsqp(x0.hs100, fn = fn.hs100, gr = gr.hs100, hin = hin.hs100,
                   hinjac = hinjac.hs100, deprecatedBehavior = FALSE)

# Going to be reused below in new behavior test.
slsqpControlhinjac <- nloptr(x0 = x0.hs100,
                             eval_f = fn.hs100,
                             eval_grad_f = gr.hs100,
                             eval_g_ineq = hin.hs100,
                             eval_jac_g_ineq = hinjac.hs100,
                             opts = list(algorithm = "NLOPT_LD_SLSQP",
                                         xtol_rel = 1e-6, maxeval = 1000L))

expect_identical(slsqpTest$par, slsqpControlhinjac$solution)
expect_identical(slsqpTest$value, slsqpControlhinjac$objective)
expect_identical(slsqpTest$iter, slsqpControlhinjac$iterations)
expect_identical(slsqpTest$convergence, slsqpControlhinjac$status)
expect_identical(slsqpTest$message, slsqpControlhinjac$message)

# Not passing equality Jacobian
slsqpTest <- slsqp(x0.hs100, fn = fn.hs100, heq = hin.hs100,
                   deprecatedBehavior = FALSE)

slsqpControl <- nloptr(x0 = x0.hs100,
                       eval_f = fn.hs100,
                       eval_grad_f = gr.hs100.computed,
                       eval_g_eq = hin.hs100,
                       eval_jac_g_eq = hinjac.hs100.computed,
                       opts = list(algorithm = "NLOPT_LD_SLSQP",
                                   xtol_rel = 1e-6, maxeval = 1000L))

expect_equal(slsqpTest$par, slsqpControl$solution, tolerance = tol)
expect_equal(slsqpTest$value, slsqpControl$objective, tolerance = tol)
expect_identical(slsqpTest$iter, slsqpControl$iterations)
expect_identical(slsqpTest$convergence, slsqpControl$status)
expect_identical(slsqpTest$message, slsqpControl$message)

# Passing equality Jacobian
slsqpTest <- slsqp(x0.hs100, fn = fn.hs100, gr = gr.hs100, heq = hin.hs100,
                   heqjac = hinjac.hs100, deprecatedBehavior = FALSE)

slsqpControl <- nloptr(x0 = x0.hs100,
                       eval_f = fn.hs100,
                       eval_grad_f = gr.hs100,
                       eval_g_eq = hin.hs100,
                       eval_jac_g_eq = hinjac.hs100,
                       opts = list(algorithm = "NLOPT_LD_SLSQP",
                                   xtol_rel = 1e-6, maxeval = 1000L))

expect_identical(slsqpTest$par, slsqpControl$solution)
expect_identical(slsqpTest$value, slsqpControl$objective)
expect_identical(slsqpTest$iter, slsqpControl$iterations)
expect_identical(slsqpTest$convergence, slsqpControl$status)
expect_identical(slsqpTest$message, slsqpControl$message)

# Test deprecated message
expect_warning(slsqp(x0.hs100, fn = fn.hs100, hin = hin2.hs100), depMess)

# Test deprecated behavior Adjust tests above when old behavior made defunct.
slsqpTest <- suppressWarnings(slsqp(x0.hs100, fn = fn.hs100, gr = gr.hs100,
                                    hin = hin2.hs100, hinjac = hinjac2.hs100))

expect_identical(slsqpTest$par, slsqpControlhinjac$solution)
expect_identical(slsqpTest$value, slsqpControlhinjac$objective)
expect_identical(slsqpTest$iter, slsqpControlhinjac$iterations)
expect_identical(slsqpTest$convergence, slsqpControlhinjac$status)
expect_identical(slsqpTest$message, slsqpControlhinjac$message)
