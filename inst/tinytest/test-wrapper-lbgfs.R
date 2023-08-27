# Copyright (C) 2023 Avraham Adler. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   test-wrapper-lbgfs
# Author: Avraham Adler
# Date:   6 February 2023
#
# Test wrapper calls to LBGFS
#
# Changelog:
#   2023-08-23: Change _output to _stdout
#

library(nloptr)

## Functions for the algorithms
flb <- function(x) {
  p <- length(x)
  sum(c(1, rep(4, p - 1)) * (x - c(1, x[-p]) ^ 2) ^ 2)
}

x0 <- rep(3, 25L)
lb <- rep(2, 25L)
ub <- rep(4, 25L)
ctl <- list(xtol_rel = 1e-8)


# Test printout if nl.info passed. The word "Call:" should be in output if
# passed and not if not passed.
expect_stdout(lbfgs(x0, flb, nl.info = TRUE), "Call:", fixed = TRUE)

expect_silent(lbfgs(x0, flb))

# No passed gradient
lbfgsTest <- lbfgs(x0, flb, lower = lb, upper = ub, control = ctl)

lbfgsControl <- nloptr(x0 = x0,
                       eval_f = flb,
                       eval_grad_f = function(x) nl.grad(x, flb),
                       lb = lb,
                       ub = ub,
                       opts = list(algorithm = "NLOPT_LD_LBFGS",
                                   xtol_rel = 1e-8, maxeval = 1000L))

expect_identical(lbfgsTest$par, lbfgsControl$solution)
expect_identical(lbfgsTest$value, lbfgsControl$objective)
expect_identical(lbfgsTest$iter, lbfgsControl$iterations)
expect_identical(lbfgsTest$convergence, lbfgsControl$status)
expect_identical(lbfgsTest$message, lbfgsControl$message)

# Passed gradient
fr <- function(x) {100 * (x[2L] - x[1L] ^ 2) ^ 2 + (1 - x[1L]) ^ 2}
gr <- function(x) {
  .expr2 <- x[2L] - x[1L] ^ 2
  .expr5 <- 1 - x[1L]
  c(-(2 * .expr5 + 100 * (2 * (2 * x[1L] * .expr2))),
    100 * (2 * .expr2))
}

lbfgsTest <- lbfgs(c(-1.2, 2), fr, gr, lower = c(-3, -3), upper = c(3, 3),
                   control = ctl)

lbfgsControl <- nloptr(x0 = c(-1.2, 2),
                       eval_f = fr,
                       eval_grad_f = gr,
                       lb = c(-3, -3),
                       ub = c(3, 3),
                       opts = list(algorithm = "NLOPT_LD_LBFGS",
                                   xtol_rel = 1e-8, maxeval = 1000L))

expect_identical(lbfgsTest$par, lbfgsControl$solution)
expect_identical(lbfgsTest$value, lbfgsControl$objective)
expect_identical(lbfgsTest$iter, lbfgsControl$iterations)
expect_identical(lbfgsTest$convergence, lbfgsControl$status)
expect_identical(lbfgsTest$message, lbfgsControl$message)
