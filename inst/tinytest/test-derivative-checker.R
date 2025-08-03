# Copyright (C) 201 Jelmer Ypma. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   test-derivative-checker.R
# Author: Jelmer Ypma
# Date:   24 July 2010
#
# Maintenance assumed by Avraham Adler (AA) on 2023-02-10
#
# Example showing results of the derivative checker and finite-difference
#
# Changelog:
#   2013-10-27: Changed example to use unit testing framework testthat.
#   2019-12-12: Corrected warnings and using updated testtthat framework (AA)
#   2023-02-10: Remove wrapping tests in "test_that" to reduce duplication.
#               and add explicit accuracy checks for nloptr:::finite.diff.R (AA)
#   2023-08-23: Prefix finite.diff with nloptr::: as part of move to tinytest
#

library(nloptr)

# Test derivative checker.

tol <- 1e-7

# Define objective function.
f <- function(x, a) sum((x - a) ^ 2)

# Define gradient function without errors.
f_grad <- function(x, a)  2 * (x - a)

# Generated a using:
# > set.seed(3141)
# > a <- runif(10)
# > dump("a", file = "")

a <- c(0.75499595934525132, 0.9649918619543314, 0.041430773446336389,
       0.42781219445168972, 0.65170943737030029, 0.83836922678165138,
       0.77428539283573627, 0.53199269832111895, 0.76871572202071548,
       0.7851746492087841)

# Test nloptr:::finite.diff on multivariate scalar function
expect_equal(nloptr:::finite.diff(f, 1:10, a = a), f_grad(1:10, a = a),
             tolerance = tol)

expect_equal(nloptr:::finite.diff(f, 1:10, a = a), nl.grad(1:10, f, a = a),
             tolerance = tol)

# Test nloptr:::finite.diff on multivariate Jacobian of vector function
x0 <- 1:3
fn1 <- function(x) {
  c(3 * x[1L] ^ 2 * x[2L] * log(x[3L]), x[3] ^ 3 - 2 * x[1L] * x[2L])
}

jac1 <- function(x) {
  matrix(c(6 * x[1L] * x[2L] * log(x[3L]),
           3 * x[1L] ^ 2 * log(x[3L]),
           3 * x[1L] ^ 2 * x[2L] / x[3L],
           -2 * x[2L], -2 * x[1L], 3 * x[3L] ^ 2),
         nrow = 2L, byrow = TRUE)
}

expect_equal(nloptr:::finite.diff(fn1, x0), jac1(x0), tolerance = tol)

res <- suppressMessages(
  check.derivatives(
    .x = 1:10,
    func = f,
    func_grad = f_grad,
    check_derivatives_print = "none",
    a = a
  )
)

expect_identical(sum(res$flag_derivative_warning), 0L)

# Define gradient function with 1 error.
f_grad <- function(x, a) 2 * (x - a) + c(0, 0.1, rep(0, 8L))

res <- suppressMessages(
  check.derivatives(
    .x = 1:10,
    func = f,
    func_grad = f_grad,
    check_derivatives_print = "none",
    a = a
  )
)

expect_identical(sum(res$flag_derivative_warning), 1L)

# Define objective function.
g <- function(x, a) c(sum(x - a), sum((x - a) ^ 2))

# Define gradient function with 2 errors.
g_grad <- function(x, a) {
  rbind(rep(1, length(x)) + c(0, 0.01, rep(0, 8L)),
        2 * (x - a) + c(0, 0.1, rep(0, 8L)))
}

res <- suppressMessages(
  check.derivatives(
    .x = 1:10,
    func = g,
    func_grad = g_grad,
    check_derivatives_print = "none",
    a = a
  )
)

expect_identical(sum(res$flag_derivative_warning), 2L)
