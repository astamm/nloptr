# Copyright (C) 2023 Avraham Adler. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   test-nloptr
# Author: Avraham Adler
# Date:   7 February 2023
#
# Test code in "nloptr" function that is not tested elsewhere.
#
# Changelog:
#

ctlNM <- list(algorithm = "NLOPT_LN_NELDERMEAD", xtol_rel = 1e-8,
              check_derivatives = TRUE)
ctlSQP <- list(algorithm = "NLOPT_LD_SLSQP", xtol_rel = 1e-8,
               check_derivatives = TRUE, print_options_doc = TRUE)

# internal function to check the arguments of the functions
expect_error(nloptr(3, "Zed"), "must be a function", fixed = TRUE)

fn <- function(x, b = NULL, c = NULL) x
expect_error(nloptr(3, fn, c = "Q"),
             "but this has not been passed to the 'nloptr' function",
             fixed = TRUE)

expect_error(nloptr(3, fn, b = "X", c = "Y", d = "Q"),
             "passed to (...) in 'nloptr' but this is not required in the",
             fixed = TRUE)

fn <- function(x) x ^ 2 - 4 * x + 4
gr <- function(x) 2 * x - 4
hin <- function(x) 2.5 - x
hinjac <- function(x) -1
heq <- function(x) 3 * x ^ 2 - 23.52
heqjac <- function(x) 6 * x

expect_warning(nloptr(3, fn, opts = ctlNM),
               "Skipping derivative checker because algorithm", fixed = TRUE)

# The remaining messages are complicated enough that moving to a snapshot is
# warranted. Otherwise there would need to be over six levels of sinking.
# Snapshots should be wrapped in "test_that" so that the comments make sense.
# Otherwise they pull from the nearest invocation of "test_that" which is
# slightly ridiculous.

test_that("Complicated message output from nloptr derivative checks.", {
  expect_snapshot(
    nloptr(4, fn, gr, eval_g_ineq = hin, eval_jac_g_ineq = hinjac,
           eval_g_eq = heq, eval_jac_g_eq = heqjac, opts = ctlSQP)
  )
})
