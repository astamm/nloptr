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
#

library(nloptr)
options(digits=7)

f <- function(x, a) {sum((x - a) ^ 2)}
f_grad <- function(x, a) {2 * (x - a)}

expect_warning(suppressMessages(check.derivatives(.x = 1:10, func = f,
                                                  func_grad = f_grad,
                                                  check_derivatives_print = "z",
                                                  a = runif(10L))),
               "for check_derivatives_print is unknown; use 'all'",
               fixed = TRUE)

expect_message(check.derivatives(.x = 1:10, func = f, func_grad = f_grad,
                                 check_derivatives_print = "all", a = 1:10),
               "] = 0e+00 ~ 1.490116e-08   [", fixed = TRUE)

expect_message(check.derivatives(.x = 1:10, func = f, func_grad = f_grad,
                                 check_derivatives_print = "all", a = 1:10),
               "Derivative checker results: 10 error(s) detected.",
               fixed = TRUE)

expect_message(check.derivatives(.x = 1:10, func = f, func_grad = f_grad,
                                 check_derivatives_print = "errors", a = 1:10),
               "] = 0e+00 ~ 2.980232e-08   [1e+00]", fixed = TRUE)
