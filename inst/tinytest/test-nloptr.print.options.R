# Copyright (C) 2023 Avraham Adler. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   test-nloptr.print.options
# Author: Avraham Adler
# Date:   7 February 2023
#
# Test code in "nloptr.print.options" function that is not tested elsewhere.
#
# Changelog:
#   2023-08-23: tinytest has no "snapshot" equivalent so removed that test.
#               Converted the others to tinytest format.
#

library(nloptr)

expect_stdout(nloptr.print.options(opts.show = "check_derivatives"),
              "user-supplied analytic gradients with finite difference",
              fixed = TRUE)

expect_stdout(nloptr(3, function(x) x ^ 2 + 1,
                     opts = list(algorithm = "NLOPT_LN_NELDERMEAD",
                                 xtol_rel = 1e-8, print_options_doc = TRUE)),
              "user-supplied analytic gradients with finite difference",
              fixed = TRUE)
