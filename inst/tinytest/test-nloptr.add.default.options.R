# Copyright (C) 2023 Avraham Adler. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   test-nloptr.add.default.options
# Author: Avraham Adler
# Date:   8 February 2023
#
# Test code in nloptr.add.default.options function that is not tested elsewhere.
#
# Changelog:
#

library(nloptr)

fn <- function(x) x ^ 2 - 4 * x + 4

expect_warning(nloptr(3, fn, opts = list(algorithm = "NLOPT_LN_NELDERMEAD")),
               "No termination criterion specified, using default",
               fixed = TRUE)
