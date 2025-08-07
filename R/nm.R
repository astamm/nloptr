# Copyright (C) 2014 Hans W. Borchers. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   nm.R
# Author: Hans W. Borchers
# Date:   27 January 2014
#
# Wrapper to solve optimization problem using Nelder-Mead and Subplex.
#
# CHANGELOG
# 2023-02-09: Cleanup and tweaks for safety and efficiency (Avraham Adler)
#

#' Nelder-Mead Simplex
#'
#' An implementation of almost the original Nelder-Mead simplex algorithm.
#'
#' Provides explicit support for bound constraints, using essentially the method
#' proposed in Box.  Whenever a new point would lie outside the bound
#' constraints the point is moved back exactly onto the constraint.
#'
#' @param x0 starting point for searching the optimum.
#' @param fn objective function that is to be minimized.
#' @param lower,upper lower and upper bound constraints.
#' @param nl.info logical; shall the original NLopt info been shown.
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
#' @export neldermead
#'
#' @author Hans W. Borchers
#'
#' @note The author of NLopt would tend to recommend the Subplex method
#' instead.
#'
#' @seealso \code{dfoptim::nmk}
#'
#' @references J. A. Nelder and R. Mead, ``A simplex method for function
#' minimization,'' The Computer Journal 7, p. 308-313 (1965).
#'
#' M. J. Box, ``A new method of constrained optimization and a comparison with
#' other methods,'' Computer J. 8 (1), 42-52 (1965).
#'
#' @examples
#'
#' # Fletcher and Powell's helic valley
#' fphv <- function(x)
#'   100*(x[3] - 10*atan2(x[2], x[1])/(2*pi))^2 +
#'     (sqrt(x[1]^2 + x[2]^2) - 1)^2 +x[3]^2
#' x0 <- c(-1, 0, 0)
#' neldermead(x0, fphv)  #  1 0 0
#'
#' # Powell's Singular Function (PSF)
#' psf <- function(x)  (x[1] + 10*x[2])^2 + 5*(x[3] - x[4])^2 +
#'           (x[2] - 2*x[3])^4 + 10*(x[1] - x[4])^4
#' x0 <- c(3, -1, 0, 1)
#' neldermead(x0, psf)   #  0 0 0 0, needs maximum number of function calls
#'
#' \dontrun{
#' # Bounded version of Nelder-Mead
#' rosenbrock <- function(x) { ## Rosenbrock Banana function
#'   100 * (x[2] - x[1]^2)^2 + (1 - x[1])^2 +
#'   100 * (x[3] - x[2]^2)^2 + (1 - x[2])^2
#' }
#' lower <- c(-Inf, 0,   0)
#' upper <- c( Inf, 0.5, 1)
#' x0 <- c(0, 0.1, 0.1)
#' S <- neldermead(c(0, 0.1, 0.1), rosenbrock, lower, upper, nl.info = TRUE)
#' # $xmin = c(0.7085595, 0.5000000, 0.2500000)
#' # $fmin = 0.3353605}
#'
neldermead <- function(
  x0,
  fn,
  lower = NULL,
  upper = NULL,
  nl.info = FALSE,
  control = list(),
  ...
) {
  opts <- nl.opts(control)
  opts["algorithm"] <- "NLOPT_LN_NELDERMEAD"

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


#' Subplex Algorithm
#'
#' Subplex is a variant of Nelder-Mead that uses Nelder-Mead on a sequence of
#' subspaces.
#'
#' SUBPLEX is claimed to be much more efficient and robust than the original
#' Nelder-Mead while retaining the latter's facility with discontinuous
#' objectives.
#'
#' This implementation has explicit support for bound constraints via the
#' method in the Box paper as described on the \code{neldermead} help page.
#'
#' @param x0 starting point for searching the optimum.
#' @param fn objective function that is to be minimized.
#' @param lower,upper lower and upper bound constraints.
#' @param nl.info logical; shall the original NLopt info been shown.
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
#' @export sbplx
#'
#' @note It is the request of Tom Rowan that reimplementations of his algorithm
#' shall not use the name `subplex'.
#'
#' @seealso \code{subplex::subplex}
#'
#' @references T. Rowan, ``Functional Stability Analysis of Numerical
#' Algorithms'', Ph.D.  thesis, Department of Computer Sciences, University of
#' Texas at Austin, 1990.
#'
#' @examples
#'
#' # Fletcher and Powell's helic valley
#' fphv <- function(x)
#'   100*(x[3] - 10*atan2(x[2], x[1])/(2*pi))^2 +
#'     (sqrt(x[1]^2 + x[2]^2) - 1)^2 +x[3]^2
#' x0 <- c(-1, 0, 0)
#' sbplx(x0, fphv)  #  1 0 0
#'
#' # Powell's Singular Function (PSF)
#' psf <- function(x)  (x[1] + 10*x[2])^2 + 5*(x[3] - x[4])^2 +
#'           (x[2] - 2*x[3])^4 + 10*(x[1] - x[4])^4
#' x0 <- c(3, -1, 0, 1)
#' sbplx(x0, psf, control = list(maxeval = Inf, ftol_rel = 1e-6)) #  0 0 0 0 (?)
#'
sbplx <- function(
  x0,
  fn,
  lower = NULL,
  upper = NULL,
  nl.info = FALSE,
  control = list(),
  ...
) {
  opts <- nl.opts(control)
  opts["algorithm"] <- "NLOPT_LN_SBPLX"

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
