# Copyright (C) 2023 Avraham Adler. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   test-check.derivatives
# Author: Avraham Adler
# Date:   6 February 2023
#
# Test code in "check.derivatives" function that is not tested elsewhere.
#
# Changelog:
#   2024-07-03: With removal of finite.diff, combine tests here and in old
#               "test-derivative-checker.R". Update "snapshots" for use of more
#               accurate algorithm (Avraham Adler).

library(nloptr)
options(digits = 7)
tol <- 1e-7

# UNIVARIATE FUNCTION
# Define objective function.
f <- function(x, a) sum((x - a) ^ 2)

# Define gradient function without errors.
f_grad <- function(x, a)  2 * (x - a)

# Generated 'a' using:
# > set.seed(3141)
# > a <- runif(10)
# > dump("a", file = "")

a <- c(0.75499595934525132, 0.9649918619543314, 0.041430773446336389,
       0.42781219445168972, 0.65170943737030029, 0.83836922678165138,
       0.77428539283573627, 0.53199269832111895, 0.76871572202071548,
       0.7851746492087841)

expect_warning(suppressMessages(check.derivatives(.x = 1:10, func = f,
                                                  func_grad = f_grad,
                                                  check_derivatives_print = "z",
                                                  points = 5L,
                                                  a = runif(10L))),
               "for check_derivatives_print is unknown; use 'all'",
               fixed = TRUE)

expect_message(check.derivatives(.x = 1:10, func = f, func_grad = f_grad,
                                 check_derivatives_print = "all", points = 5L,
                                 a = 1:10),
               "] = 0e+00 ~ -3.700520e-17   [", fixed = TRUE)

expect_message(check.derivatives(.x = 1:10, func = f, func_grad = f_grad,
                                 check_derivatives_print = "all", points = 5L,
                                 a = 1:10),
               "Derivative checker results: 3 error(s) detected.",
               fixed = TRUE)

expect_message(check.derivatives(.x = 1:10, func = f, func_grad = f_grad,
                                 check_derivatives_print = "errors",
                                 points = 5L, a = 1:10),
               "] = 0e+00 ~ -3.700520e-17   [1e+00]", fixed = TRUE)

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
    points = 5L,
    a = a
  )
)

expect_identical(sum(res$flag_derivative_warning), 1L)

# MULTIVARIATE FUNCTION
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
    points = 5L,
    a = a
  )
)

expect_identical(sum(res$flag_derivative_warning), 2L)
