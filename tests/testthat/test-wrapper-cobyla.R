# Copyright (C) 2023 Avraham Adler. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   test-wrapper-cobyla
# Author: Avraham Adler
# Date:   6 February 2023
#
# Test wrapper calls to cobyla, bobyqa, and newuoa algorithms
#
# Changelog:
#

ineqMess <- paste("For consistency with the rest of the package the inequality",
                  "sign may be switched from >= to <= in a future nloptr",
                  "version.")

## Functions for COBYLA, BOBYQA, and NEWUOA
x0.hs100 <- c(1, 2, 0, 4, 0, 1, 1)
fn.hs100 <- function(x) {
  (x[1L] - 10) ^ 2 + 5 * (x[2L] - 12) ^ 2 + x[3L] ^ 4 + 3 * (x[4L] - 11) ^ 2 +
    10 * x[5L] ^ 6 + 7 * x[6L] ^ 2 + x[7L] ^ 4 - 4 * x[6L] * x[7L] -
    10 * x[6L] - 8 * x[7L]
}

hin.hs100 <- function(x) {
  h <- double(4L)
  h[1L] <- 127 - 2 * x[1L] ^ 2 - 3 * x[2L] ^ 4 - x[3L] - 4 * x[4L] ^ 2 - 5 * x[5L]
  h[2L] <- 282 - 7 * x[1L] - 3 * x[2L] - 10 * x[3L] ^ 2 - x[4L] + x[5L]
  h[3L] <- 196 - 23 * x[1L] - x[2L] ^ 2 - 6 * x[6L] ^ 2 + 8 * x[7L]
  h[4L] <- -4 * x[1L] ^ 2 - x[2L] ^ 2 + 3 * x[1L] * x[2L] - 2 * x[3L] ^ 2 -
    5 * x[6L] + 11 * x[7L]
  return(h)
}

hin2.hs100 <- function(x) -hin.hs100(x) # Needed for nloptr call

fr <- function(x) {100 * (x[2L] - x[1L] ^ 2) ^ 2 + (1 - x[1L]) ^ 2}

# Test messages
expect_message(cobyla(x0.hs100, fn.hs100, hin = hin.hs100, nl.info = FALSE,
                      control = list(xtol_rel = 1e-8)), ineqMess)

# Test printout if nl.info passed. The word "Call:" should be in output if
# passed and not if not passed.
expect_output(suppressMessages(cobyla(x0.hs100, fn.hs100, hin = hin.hs100,
                                     nl.info = TRUE,
                                     control = list(xtol_rel = 1e-8))),
                               "Call:", fixed = TRUE)
expect_output(suppressMessages(bobyqa(c(0, 0), fr, lower = c(0, 0),
                                      upper = c(0.5, 0.5), nl.info = TRUE,
                                      control = list(xtol_rel = 1e-6))),
              "Call:", fixed = TRUE)

expect_output(suppressMessages(newuoa(c(1, 2), fr, nl.info = TRUE,
                                      control = list(xtol_rel = 1e-6))),
              "Call:", fixed = TRUE)

expect_silent(suppressMessages(cobyla(x0.hs100, fn.hs100, hin = hin.hs100,
                                     nl.info = FALSE,
                                     control = list(xtol_rel = 1e-8))))

expect_silent(suppressMessages(bobyqa(c(0, 0), fr, lower = c(0, 0),
                                      upper = c(0.5, 0.5), nl.info = FALSE,
                                      control = list(xtol_rel = 1e-6))))

expect_silent(suppressMessages(newuoa(c(1, 2), fr, nl.info = FALSE,
                                      control = list(xtol_rel = 1e-6))))

# Test COBYLA algorithm
cobylaTest <- suppressMessages(cobyla(x0.hs100, fn.hs100, hin = hin.hs100,
                                    nl.info = FALSE,
                                    control = list(xtol_rel = 1e-8)))

cobylaControl <- nloptr(x0 = x0.hs100,
                       eval_f = fn.hs100,
                       eval_g_ineq = hin2.hs100,
                       opts = list(algorithm = "NLOPT_LN_COBYLA",
                                   xtol_rel = 1e-6, maxeval = 1000L))

expect_identical(cobylaTest$par, cobylaControl$solution)
expect_identical(cobylaTest$value, cobylaControl$objective)
expect_identical(cobylaTest$iter, cobylaControl$iterations)
expect_identical(cobylaTest$convergence, cobylaControl$status)
expect_identical(cobylaTest$message, cobylaControl$message)

# Test BOBYQA algorithm
bobyqaTest <- bobyqa(c(0, 0), fr, lower = c(0, 0), upper = c(0.5, 0.5))

bobyqaControl <- nloptr(x0 = c(0, 0), eval_f = fr, lb = c(0, 0),
                        ub = c(0.5, 0.5),
                        opts = list(algorithm = "NLOPT_LN_BOBYQA",
                                    xtol_rel = 1e-6, maxeval = 1000L))

expect_identical(bobyqaTest$par, bobyqaControl$solution)
expect_identical(bobyqaTest$value, bobyqaControl$objective)
expect_identical(bobyqaTest$iter, bobyqaControl$iterations)
expect_identical(bobyqaTest$convergence, bobyqaControl$status)
expect_identical(bobyqaTest$message, bobyqaControl$message)

# Test NEWUOA algorithm
newuoaTest <- newuoa(c(1, 2), fr)

newuoaControl <- nloptr(x0 = c(1, 2), eval_f = fr,
                        opts = list(algorithm = "NLOPT_LN_NEWUOA",
                                    xtol_rel = 1e-6, maxeval = 1000L))

expect_identical(newuoaTest$par, newuoaControl$solution)
expect_identical(newuoaTest$value, newuoaControl$objective)
expect_identical(newuoaTest$iter, newuoaControl$iterations)
expect_identical(newuoaTest$convergence, newuoaControl$status)
expect_identical(newuoaTest$message, newuoaControl$message)
