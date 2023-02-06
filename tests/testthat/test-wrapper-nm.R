# Copyright (C) 2023 Avraham Adler. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   test-wrapper-nm
# Author: Avraham Adler
# Date:   6 February 2023
#
# Test wrapper calls for Nelder-Mead and Subplex algorithms.
#
# Changelog:
#

## Functions for the algorithms
fphv <- function(x) {
  100 * (x[3L] - 10 * atan2(x[2L], x[1L]) / (2 * pi)) ^ 2 +
    (sqrt(x[1L] ^ 2 + x[2L] ^ 2) - 1) ^ 2 + x[3L] ^ 2
}

## Nelder-Mead

# Test printout if nl.info passed. The word "Call:" should be in output if
# passed and not if not passed.
expect_output(neldermead(c(-1, 0, 0), fphv, nl.info = TRUE),
              "Call:", fixed = TRUE)

expect_silent(neldermead(c(-1, 0, 0), fphv))

nmTest <- neldermead(c(-1, 0.5, 0.5), fphv)

nmControl <- nloptr(x0 = c(-1, 0.5, 0.5),
                    eval_f = fphv,
                    opts = list(algorithm = "NLOPT_LN_NELDERMEAD",
                                  xtol_rel = 1e-6, maxeval = 1000L))

expect_identical(nmTest$par, nmControl$solution)
expect_identical(nmTest$value, nmControl$objective)
expect_identical(nmTest$iter, nmControl$iterations)
expect_identical(nmTest$convergence, nmControl$status)
expect_identical(nmTest$message, nmControl$message)

## Subplex
# Test printout if nl.info passed. The word "Call:" should be in output if
# passed and not if not passed.
expect_output(sbplx(c(-1, 0, 0), fphv, nl.info = TRUE), "Call:", fixed = TRUE)

expect_silent(sbplx(c(-1, 0, 0), fphv))

sbplTest <- sbplx(c(-1, 0.5, 0.5), fphv)

sbplControl <- nloptr(x0 = c(-1, 0.5, 0.5),
                      eval_f = fphv,
                      opts = list(algorithm = "NLOPT_LN_SBPLX",
                                  xtol_rel = 1e-6, maxeval = 1000L))

expect_identical(sbplTest$par, sbplControl$solution)
expect_identical(sbplTest$value, sbplControl$objective)
expect_identical(sbplTest$iter, sbplControl$iterations)
expect_identical(sbplTest$convergence, sbplControl$status)
expect_identical(sbplTest$message, sbplControl$message)
