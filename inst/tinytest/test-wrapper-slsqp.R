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

tol <- sqrt(.Machine$double.eps)

ineqMess <- paste("For consistency with the rest of the package the inequality",
                  "sign may be switched from >= to <= in a future nloptr",
                  "version.")

## Functions for SLSQP
x0.hs100 <- c(1, 2, 0, 4, 0, 1, 1)
fn.hs100 <- function(x) {
  (x[1L] - 10) ^ 2 + 5 * (x[2L] - 12) ^ 2 + x[3L] ^ 4 + 3 * (x[4L] - 11) ^ 2 +
    10 * x[5L] ^ 6 + 7 * x[6L] ^ 2 + x[7L] ^ 4 - 4 * x[6L] * x[7L] -
    10 * x[6L] - 8 * x[7L]
}

gr.hs100 <- function(x) {
  c(2 * x[1L] -  20,
    10 * x[2L] - 120,
    4 * x[3L] ^ 3,
    6 * x[4L] - 66,
    60 * x[5L] ^ 5,
    14 * x[6L] - 4 * x[7L] - 10,
    4 * x[7L] ^ 3 - 4 * x[6L] - 8)
}

gr <- function(x) nl.grad(x, fn.hs100)

hin.hs100 <- function(x) {
  h <- double(4L)
  h[1L] <- 127 - 2 * x[1L] ^ 2 - 3 * x[2L] ^ 4 - x[3L] - 4 * x[4L] ^ 2 - 5 * x[5L]
  h[2L] <- 282 - 7 * x[1L] - 3 * x[2L] - 10 * x[3L] ^ 2 - x[4L] + x[5L]
  h[3L] <- 196 - 23 * x[1L] - x[2L] ^ 2 - 6 * x[6L] ^ 2 + 8 * x[7L]
  h[4L] <- -4 * x[1L] ^ 2 - x[2L] ^ 2 + 3 * x[1L] * x[2L] - 2 * x[3L] ^ 2 -
    5 * x[6L] + 11 * x[7L]
  return(h)
}

hinjac.hs100 <- function(x) {
  matrix(c(4 * x[1L], 12 * x[2L] ^ 3, 1, 8 * x[4L], 5, 0, 0, 7, 3, 20 * x[3L],
           1, -1, 0, 0, 23, 2 * x[2L], 0, 0, 0, 12 * x[6L], -8,
           8 * x[1L] - 3 * x[2L], 2 * x[2L] - 3 * x[1L], 4 * x[3L], 0, 0, 5,
           -11), 4L, 7L, byrow = TRUE)
}

hin2.hs100 <- function(x) -hin.hs100(x)                 # Needed for nloptr call
hinjac2.hs100 <- function(x) -hinjac.hs100(x)           # Needed for nloptr call
hinjac2b.hs100 <- function(x) nl.jacobian(x, hin2.hs100)# Needed for nloptr call

# Test messages
expect_message(slsqp(x0.hs100, fn = fn.hs100, hin = hin.hs100), ineqMess)


# Test printout if nl.info passed. The word "Call:" should be in output if
# passed and not if not passed.
expect_stdout(slsqp(x0.hs100, fn = fn.hs100, nl.info = TRUE),
              "Call:", fixed = TRUE)

expect_silent(slsqp(x0.hs100, fn = fn.hs100))

# No passed gradient or Inequality Jacobians
slsqpTest <- suppressMessages(slsqp(x0.hs100, fn.hs100, hin = hin.hs100))

slsqpControl <- nloptr(x0 = x0.hs100,
                       eval_f = fn.hs100,
                       eval_grad_f = gr,
                       eval_g_ineq = hin2.hs100,
                       eval_jac_g_ineq = hinjac2b.hs100,
                       opts = list(algorithm = "NLOPT_LD_SLSQP",
                                  xtol_rel = 1e-6, maxeval = 1000L))

expect_identical(slsqpTest$par, slsqpControl$solution)
expect_identical(slsqpTest$value, slsqpControl$objective)
expect_identical(slsqpTest$iter, slsqpControl$iterations)
expect_identical(slsqpTest$convergence, slsqpControl$status)
expect_identical(slsqpTest$message, slsqpControl$message)

# Passed gradient or Inequality Jacobians
slsqpTest <- suppressMessages(slsqp(x0.hs100, fn = fn.hs100, gr = gr.hs100,
                                    hin = hin.hs100, hinjac = hinjac.hs100))

slsqpControl <- nloptr(x0 = x0.hs100,
                       eval_f = fn.hs100,
                       eval_grad_f = gr.hs100,
                       eval_g_ineq = hin2.hs100,
                       eval_jac_g_ineq = hinjac2.hs100,
                       opts = list(algorithm = "NLOPT_LD_SLSQP",
                                   xtol_rel = 1e-6, maxeval = 1000L))

expect_identical(slsqpTest$par, slsqpControl$solution)
expect_identical(slsqpTest$value, slsqpControl$objective)
expect_identical(slsqpTest$iter, slsqpControl$iterations)
expect_identical(slsqpTest$convergence, slsqpControl$status)
expect_identical(slsqpTest$message, slsqpControl$message)

# Not passing equality Jacobian
slsqpTest <- suppressMessages(slsqp(x0.hs100, fn = fn.hs100, heq = hin.hs100))

slsqpControl <- nloptr(x0 = x0.hs100,
                       eval_f = fn.hs100,
                       eval_grad_f = gr.hs100,
                       eval_g_eq = hin2.hs100,
                       eval_jac_g_eq = hinjac2b.hs100,
                       opts = list(algorithm = "NLOPT_LD_SLSQP",
                                   xtol_rel = 1e-6, maxeval = 1000L))

expect_equal(slsqpTest$par, slsqpControl$solution, tolerance = tol)
expect_equal(slsqpTest$value, slsqpControl$objective, tolerance = tol)
expect_identical(slsqpTest$iter, slsqpControl$iterations)
expect_identical(slsqpTest$convergence, slsqpControl$status)
expect_identical(slsqpTest$message, slsqpControl$message)

# Passing equality Jacobian
slsqpTest <- suppressMessages(slsqp(x0.hs100, fn = fn.hs100, heq = hin.hs100,
                                    heqjac = hinjac.hs100))

slsqpControl <- nloptr(x0 = x0.hs100,
                       eval_f = fn.hs100,
                       eval_grad_f = gr.hs100,
                       eval_g_eq = hin2.hs100,
                       eval_jac_g_eq = hinjac2.hs100,
                       opts = list(algorithm = "NLOPT_LD_SLSQP",
                                   xtol_rel = 1e-6, maxeval = 1000L))

expect_identical(slsqpTest$par, slsqpControl$solution)
expect_identical(slsqpTest$value, slsqpControl$objective)
expect_identical(slsqpTest$iter, slsqpControl$iterations)
expect_identical(slsqpTest$convergence, slsqpControl$status)
expect_identical(slsqpTest$message, slsqpControl$message)
