# Copyright (C) 2023 Avraham Adler. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   test-nloptions
# Author: Avraham Adler
# Date:   6 February 2023
#
# Test code in "nloptions" function that is not tested elsewhere.
#
# Changelog:
#

library(nloptr)

opts <- list(
  stopval = -Inf,            # stop minimization at this value
  xtol_rel = 1e-6,           # stop on small optimization step
  maxeval = 1000,            # stop on this many function evaluations
  ftol_rel = 0.0,            # stop on change times function value
  ftol_abs = 0.0,            # stop on small change of function value
  check_derivatives = FALSE,
  algorithm = NULL           # will be filled by each single function
)

opts2 <- opts
names(opts2) <- ""

expect_identical(nl.opts(NULL), opts)
expect_error(nl.opts("C"),
             "Argument `optlist` must be a named list.", fixed = TRUE)
expect_error(nl.opts(opts2),
             "Argument `optlist` must be a named list.", fixed = TRUE)

opts2 <- opts
opts2$algorithm <- "NLOPT_LN_NELDERMEAD"

expect_warning(nl.opts(opts2),
               "Option `algorithm` cannot be set here. It will be overwritten.",
               fixed = TRUE)

expect_null(suppressWarnings(nl.opts(opts2)$algorithm))
