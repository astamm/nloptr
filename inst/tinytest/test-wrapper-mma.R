# Copyright (C) 2023 Avraham Adler. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   test-wrapper-mma
# Author: Avraham Adler
# Date:   6 February 2023
#
# Test wrapper calls to MMA algorithm
#
# CHANGELOG
#
# 2023-08-23: Change _output to _stdout
# 2024-06-04: Switched desired direction of the hin/hinjac inequalities, leaving
#       the old behavior as the default for now. Also cleaned up the HS100
#       example. (Avraham Adler)

library(nloptr)

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

hin2.hs100 <- function(x) -hin.hs100(x)        # Needed to test old behavior
hinjac2.hs100 <- function(x) -hinjac.hs100(x)  # Needed to test old behavior

ctl <- list(xtol_rel = 1e-8)

# Test printout if nl.info passed. The word "Call:" should be in output if
# passed and not if not passed.
expect_stdout(suppressMessages(mma(x0.hs100, fn.hs100, nl.info = TRUE)),
              "Call:", fixed = TRUE)

# Expect unconstrained call to work
expect_silent(mma(x0.hs100, fn.hs100))

# Test MMA algorithm with inequality but passing neither gradient nor Jacobian.
# As everyone is on Windows64, timing should be less of an issue.
mmaTest <- mma(x0.hs100, fn.hs100, hin = hin.hs100, control = ctl,
               deprecatedBehavior = FALSE)

mmaControl <- nloptr(x0 = x0.hs100,
                     eval_f = fn.hs100,
                     eval_grad_f = function(x) nl.grad(x, fn.hs100),
                     eval_g_ineq = hin.hs100,
                     eval_jac_g_ineq = function(x) nl.jacobian(x, hin.hs100),
                     opts = list(algorithm = "NLOPT_LD_MMA",
                                 xtol_rel = 1e-8, maxeval = 1000L))

expect_identical(mmaTest$par, mmaControl$solution)
expect_identical(mmaTest$value, mmaControl$objective)
expect_identical(mmaTest$iter, mmaControl$iterations)
expect_identical(mmaTest$convergence, mmaControl$status)
expect_identical(mmaTest$message, mmaControl$message)

# Test MMA algorithm passing both gradient and Jacobian. Now correct.
# (AA: 2024-06-04)
mmaControl <- nloptr(x0 = x0.hs100,
                     eval_f = fn.hs100,
                     eval_grad_f = gr.hs100,
                     eval_g_ineq = hin.hs100,
                     eval_jac_g_ineq = hinjac.hs100,
                     opts = list(algorithm = "NLOPT_LD_MMA",
                                 xtol_rel = 1e-8, maxeval = 1000L))

mmaTest <- mma(x0.hs100, fn.hs100, gr = gr.hs100, hin = hin.hs100,
               hinjac = hinjac.hs100, control = ctl, deprecatedBehavior = FALSE)

expect_identical(mmaTest$par, mmaControl$solution)
expect_identical(mmaTest$value, mmaControl$objective)
expect_identical(mmaTest$iter, mmaControl$iterations)
expect_identical(mmaTest$convergence, mmaControl$status)
expect_identical(mmaTest$message, mmaControl$message)

# Test deprecated message
expect_warning(mma(x0.hs100, fn.hs100, hin = hin.hs100), depMess)

# Test deprecated behavior
mmaTest <- suppressWarnings(mma(x0.hs100, fn.hs100, gr = gr.hs100,
                                hin = hin2.hs100, hinjac = hinjac2.hs100,
                                control = ctl))

expect_identical(mmaTest$par, mmaControl$solution)
expect_identical(mmaTest$value, mmaControl$objective)
expect_identical(mmaTest$iter, mmaControl$iterations)
expect_identical(mmaTest$convergence, mmaControl$status)
expect_identical(mmaTest$message, mmaControl$message)
