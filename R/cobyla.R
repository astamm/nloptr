# Copyright (C) 2014 Hans W. Borchers. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   cobyla.R
# Author: Hans W. Borchers
# Date:   27 January 2014
#
# Wrapper to solve optimization problem using COBYLA, BOBYQA, and NEWUOA.
#
# CHANGELOG
# 2023-02-10: Tweaks for efficiency and readability (Avraham Adler)
# 2024-06-04: Switched desired direction of the hin/hinjac inequalities, leaving
#       the old behavior as the default for now. Also cleaned up the HS100
#       example (Avraham Adler).
#

#' Constrained Optimization by Linear Approximations
#'
#' \acronym{COBYLA} is an algorithm for derivative-free optimization with
#' nonlinear inequality and equality constraints (but see below).
#'
#' It constructs successive linear approximations of the objective function and
#' constraints via a simplex of \eqn{n+1} points (in \eqn{n} dimensions), and
#' optimizes these approximations in a trust region at each step.
#'
#' \acronym{COBYLA} supports equality constraints by transforming them into two
#' inequality constraints. This functionality has not been added to the wrapper.
#' To use \acronym{COBYLA} with equality constraints, please use the full
#' \code{nloptr} invocation.
#'
#' @param x0 starting point for searching the optimum.
#' @param fn objective function that is to be minimized.
#' @param lower,upper lower and upper bound constraints.
#' @param hin function defining the inequality constraints, that is
#' \code{hin>=0} for all components.
#' @param nl.info logical; shall the original \acronym{NLopt} info be shown.
#' @param control list of options, see \code{nl.opts} for help.
#' @param deprecatedBehavior logical; if \code{TRUE} (default for now), the old
#' behavior of the Jacobian function is used, where the equality is \eqn{\ge 0}
#' instead of \eqn{\le 0}. This will be reversed in a future release and
#' eventually removed.
#' @param ... additional arguments passed to the function.
#'
#' @return List with components:
#'   \item{par}{the optimal solution found so far.}
#'   \item{value}{the function value corresponding to \code{par}.}
#'   \item{iter}{number of (outer) iterations, see \code{maxeval}.}
#'   \item{convergence}{integer code indicating successful completion (> 0)
#'   or a possible error number (< 0).}
#'   \item{message}{character string produced by NLopt and giving additional
#'   information.}
#'
#' @author Hans W. Borchers
#'
#' @note The original code, written in Fortran by Powell, was converted in C
#' for the \acronym{SciPy} project.
#'
#' @seealso \code{\link{bobyqa}}, \code{\link{newuoa}}
#'
#' @references M. J. D. Powell, ``A direct search optimization method that
#' models the objective and constraint functions by linear interpolation,'' in
#' Advances in Optimization and Numerical Analysis, eds. S. Gomez and J.-P.
#' Hennart (Kluwer Academic: Dordrecht, 1994), p. 51-67.
#'
#' @examples
#'
#' ##  Solve the Hock-Schittkowski problem no. 100 with analytic gradients
#' ##  See https://apmonitor.com/wiki/uploads/Apps/hs100.apm
#'
#' x0.hs100 <- c(1, 2, 0, 4, 0, 1, 1)
#' fn.hs100 <- function(x) {(x[1] - 10) ^ 2 + 5 * (x[2] - 12) ^ 2 + x[3] ^ 4 +
#'                          3 * (x[4] - 11) ^ 2 + 10 * x[5] ^ 6 + 7 * x[6] ^ 2 +
#'                          x[7] ^ 4 - 4 * x[6] * x[7] - 10 * x[6] - 8 * x[7]}
#'
#' hin.hs100 <- function(x) {c(
#' 2 * x[1] ^ 2 + 3 * x[2] ^ 4 + x[3] + 4 * x[4] ^ 2 + 5 * x[5] - 127,
#' 7 * x[1] + 3 * x[2] + 10 * x[3] ^ 2 + x[4] - x[5] - 282,
#' 23 * x[1] + x[2] ^ 2 + 6 * x[6] ^ 2 - 8 * x[7] - 196,
#' 4 * x[1] ^ 2 + x[2] ^ 2 - 3 * x[1] * x[2] + 2 * x[3] ^ 2 + 5 * x[6] -
#'  11 * x[7])
#' }
#'
#' S <- cobyla(x0.hs100, fn.hs100, hin = hin.hs100,
#'       nl.info = TRUE, control = list(xtol_rel = 1e-8, maxeval = 2000),
#'       deprecatedBehavior = FALSE)
#'
#' ##  The optimum value of the objective function should be 680.6300573
#' ##  A suitable parameter vector is roughly
#' ##  (2.330, 1.9514, -0.4775, 4.3657, -0.6245, 1.0381, 1.5942)
#'
#' S
#'
#' @export cobyla
#'

cobyla <- function(
  x0,
  fn,
  lower = NULL,
  upper = NULL,
  hin = NULL,
  nl.info = FALSE,
  control = list(),
  deprecatedBehavior = TRUE,
  ...
) {
  opts <- nl.opts(control)
  opts["algorithm"] <- "NLOPT_LN_COBYLA"

  f1 <- match.fun(fn)
  fn <- function(x) f1(x, ...)

  if (!is.null(hin)) {
    if (deprecatedBehavior) {
      warning(
        "The old behavior for hin >= 0 has been deprecated. Please ",
        "restate the inequality to be <=0. The ability to use the old ",
        "behavior will be removed in a future release."
      )
      .hin <- match.fun(hin)
      hin <- function(x) -.hin(x, ...) # change  hin >= 0  to  hin <= 0 !
    }
  }

  S0 <- nloptr(
    x0,
    eval_f = fn,
    lb = lower,
    ub = upper,
    eval_g_ineq = hin,
    opts = opts
  )

  if (nl.info) {
    print(S0)
  }

  list(
    par = S0$solution,
    value = S0$objective,
    iter = S0$iterations,
    convergence = S0$status,
    message = S0$message
  )
}

#' Bound Optimization by Quadratic Approximation
#'
#' \acronym{BOBYQA} performs derivative-free bound-constrained optimization
#' using an iteratively constructed quadratic approximation for the objective
#' function.
#'
#' This is an algorithm derived from the \acronym{BOBYQA} Fortran subroutine of
#' Powell, converted to C and modified for the \acronym{NLopt} stopping
#' criteria.
#'
#' @param x0 starting point for searching the optimum.
#' @param fn objective function that is to be minimized.
#' @param lower,upper lower and upper bound constraints.
#' @param nl.info logical; shall the original \acronym{NLopt} info be shown.
#' @param control list of options, see \code{nl.opts} for help.
#' @param ... additional arguments passed to the function.
#'
#' @return List with components:
#'   \item{par}{the optimal solution found so far.}
#'   \item{value}{the function value corresponding to \code{par}.}
#'   \item{iter}{number of (outer) iterations, see \code{maxeval}.}
#'   \item{convergence}{integer code indicating successful completion (> 0)
#'   or a possible error number (< 0).}
#'   \item{message}{character string produced by \acronym{NLopt} and giving
#'   additional information.}
#'
#' @export bobyqa
#'
#' @note Because \acronym{BOBYQA} constructs a quadratic approximation of the
#'   objective, it may perform poorly for objective functions that are not
#'   twice-differentiable.
#'
#' @seealso \code{\link{cobyla}}, \code{\link{newuoa}}
#'
#' @references M. J. D. Powell. ``The BOBYQA algorithm for bound constrained
#' optimization without derivatives,'' Department of Applied Mathematics and
#' Theoretical Physics, Cambridge England, technical reportNA2009/06 (2009).
#'
#' @examples
#'
#' ## Rosenbrock Banana function
#'
#' rbf <- function(x) {(1 - x[1]) ^ 2 + 100 * (x[2] - x[1] ^ 2) ^ 2}
#'
#' ## The function as written above has a minimum of 0 at (1, 1)
#'
#' S <- bobyqa(c(0, 0), rbf)
#'
#'
#' S
#'
#' ## Rosenbrock Banana function with both parameters constrained to [0, 0.5]
#'
#' S <- bobyqa(c(0, 0), rbf, lower = c(0, 0), upper = c(0.5, 0.5))
#'
#' S
#'

bobyqa <- function(
  x0,
  fn,
  lower = NULL,
  upper = NULL,
  nl.info = FALSE,
  control = list(),
  ...
) {
  opts <- nl.opts(control)
  opts["algorithm"] <- "NLOPT_LN_BOBYQA"

  fun <- match.fun(fn)
  fn <- function(x) fun(x, ...)

  S0 <- nloptr(x0, fn, lb = lower, ub = upper, opts = opts)

  if (nl.info) {
    print(S0)
  }

  list(
    par = S0$solution,
    value = S0$objective,
    iter = S0$iterations,
    convergence = S0$status,
    message = S0$message
  )
}

#' New Unconstrained Optimization with quadratic Approximation
#'
#' \acronym{NEWUOA} solves quadratic subproblems in a spherical trust region via
#' a truncated conjugate-gradient algorithm. For bound-constrained problems,
#' \acronym{BOBYQA} should be used instead, as Powell developed it as an
#' enhancement thereof for bound constraints.
#'
#' This is an algorithm derived from the \acronym{NEWUOA} Fortran subroutine of
#' Powell, converted to C and modified for the \acronym{NLopt} stopping
#' criteria.
#'
#' @param x0 starting point for searching the optimum.
#' @param fn objective function that is to be minimized.
#' @param nl.info logical; shall the original \acronym{NLopt} info be shown.
#' @param control list of options, see \code{nl.opts} for help.
#' @param ... additional arguments passed to the function.
#'
#' @return List with components:
#'   \item{par}{the optimal solution found so far.}
#'   \item{value}{the function value corresponding to \code{par}.}
#'   \item{iter}{number of (outer) iterations, see \code{maxeval}.}
#'   \item{convergence}{integer code indicating successful completion (> 0)
#'   or a possible error number (< 0).}
#'   \item{message}{character string produced by NLopt and giving additional
#'   information.}
#'
#' @export newuoa
#'
#' @author Hans W. Borchers
#'
#' @note \acronym{NEWUOA} may be largely superseded by \acronym{BOBYQA}.
#'
#' @seealso \code{\link{bobyqa}}, \code{\link{cobyla}}
#'
#' @references M. J. D. Powell. ``The BOBYQA algorithm for bound constrained
#' optimization without derivatives,'' Department of Applied Mathematics and
#' Theoretical Physics, Cambridge England, technical reportNA2009/06 (2009).
#'
#' @examples
#'
#' ## Rosenbrock Banana function
#'
#' rbf <- function(x) {(1 - x[1]) ^ 2 + 100 * (x[2] - x[1] ^ 2) ^ 2}
#'
#' S <- newuoa(c(1, 2), rbf)
#'
#' ## The function as written above has a minimum of 0 at (1, 1)
#'
#' S
#'

newuoa <- function(x0, fn, nl.info = FALSE, control = list(), ...) {
  opts <- nl.opts(control)
  opts["algorithm"] <- "NLOPT_LN_NEWUOA"

  fun <- match.fun(fn)
  fn <- function(x) fun(x, ...)

  S0 <- nloptr(x0, fn, opts = opts)

  if (nl.info) {
    print(S0)
  }

  list(
    par = S0$solution,
    value = S0$objective,
    iter = S0$iterations,
    convergence = S0$status,
    message = S0$message
  )
}
