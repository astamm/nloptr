# Copyright (C) 2023 Avraham Adler. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   test-print.nloptr
# Author: Avraham Adler
# Date:   9 February 2023
#
# Test code in print.nloptr function that is not tested elsewhere.
#
# Changelog:
#   2023-08-23: Convert _output to _stdout for tinytest
#

library(nloptr)
options(digits=7)

x0 <- c(3, 3)
fn <- function(x) (x[1] - 1) ^ 2 + (x[2] - 1) ^ 2

# Successful convergence (very loose tolerance so converges < 100)
fit <- nloptr(x0, fn,
              opts = list(algorithm = "NLOPT_LN_NELDERMEAD", xtol_rel = 1e-2))

expect_stdout(print(fit),
              "Optimal value of controls: 1.004579 1.003978", fixed = TRUE)

expect_stdout(print(fit, 1),
              "Optimal value of user-defined subset of controls: 1.004579",
              fixed = TRUE)

expect_stdout(print(fit, 2),
              "Optimal value of user-defined subset of controls: 1.003978",
              fixed = TRUE)

# Unsuccessful convergence (hit maxeval in this case)
fit <- nloptr(x0, fn,
              opts = list(algorithm = "NLOPT_LN_NELDERMEAD", xtol_rel = 1e-8))

expect_stdout(print(fit),
              "Current value of controls: 0.9999994 1.000001", fixed = TRUE)

expect_stdout(print(fit, 1),
              "Current value of user-defined subset of controls: 0.9999994",
              fixed = TRUE)

expect_stdout(print(fit, 2),
              "Current value of user-defined subset of controls: 1.000001",
              fixed = TRUE)
