# Copyright (C) 2023 Avraham Adler. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   test-gradients
# Author: Avraham Adler
# Date:   6 February 2023
#
# Test code in nl.grad and nl.jacobian functions that is not tested elsewhere.
#
# Changelog:
#

library(nloptr)

tol <- sqrt(.Machine$double.eps)

fn1 <- function(x) sum(x ^ 2)
fn2 <- function(x) c(3, 5)

expect_error(nl.grad("C", fn1),
             "Argument 'x0' must be a numeric value.", fixed = TRUE)

expect_error(nl.grad(2, fn2),
             "Function 'f' must be a scalar function (return a single value).",
             fixed = TRUE)

expect_error(nl.jacobian("C", fn1),
             "Argument 'x' must be a non-empty numeric vector.", fixed = TRUE)

expect_error(nl.jacobian(NULL, fn1),
             "Argument 'x' must be a non-empty numeric vector.", fixed = TRUE)

# Test accuracy of multivariate gradient of scalar function
x0 <- c(-2, 2, 2, -1, -1)
fnE <- function(x) exp(x[1] * x[2] * x[3] * x[4] * x[5])
grE <- function(x) {
  c(x[2] * x[3] * x[4] * x[5],
    x[1] * x[3] * x[4] * x[5],
    x[1] * x[2] * x[4] * x[5],
    x[1] * x[2] * x[3] * x[5],
    x[1] * x[2] * x[3] * x[4]) * exp(prod(x))
}

expect_equal(nl.grad(x0, fnE), grE(x0), tolerance = tol)

# Test accuracy of multivariate Jacobian of vector function
x0 <- 1:3
fn1 <- function(x) {
  c(3 * x[1L] ^ 2 * x[2L] * log(x[3L]),
    x[3] ^ 3 - 2 * x[1L] * x[2L])
}

jac1 <- function(x) {
  matrix(c(6 * x[1L] * x[2L] * log(x[3L]),
           3 * x[1L] ^ 2 * log(x[3L]),
           3 * x[1L] ^ 2 * x[2L] / x[3L],
           -2 * x[2L], -2 * x[1L], 3 * x[3L] ^ 2),
         nrow = 2L, byrow = TRUE)
}

expect_equal(nl.jacobian(x0, fn1), jac1(x0), tolerance = tol)
