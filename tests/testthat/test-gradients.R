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

fn1 <- function(x) sum(x ^ 2)
fn2 <- function(x) c(3, 5)

expect_error(nl.grad("C", fn1),
             "Argument 'x0' must be a numeric value.", fixed = TRUE)

expect_error(nl.grad(2, fn2),
             "Function 'f' must be a univariate function of 2 variables.",
             fixed = TRUE)

expect_error(nl.jacobian("C", fn1),
             "Argument 'x' must be a non-empty numeric vector.", fixed = TRUE)

expect_error(nl.jacobian(NULL, fn1),
             "Argument 'x' must be a non-empty numeric vector.", fixed = TRUE)
