# Copyright (C) 2014 Hans W. Borchers. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   tnewton.R
# Author: Hans W. Borchers
# Date:   27 January 2014
#
# Wrapper to solve optimization problem using Preconditioned Truncated Newton.
#
# CHANGELOG
#   2023-02-08: Cleanup and tweaks for safety and efficiency (Avraham Adler)
#

#' Preconditioned Truncated Newton
#'
#' Truncated Newton methods, also called Newton-iterative methods, solve an
#' approximating Newton system using a conjugate-gradient approach and are
#' related to limited-memory BFGS.
#'
#' Truncated Newton methods are based on approximating the objective with a
#' quadratic function and applying an iterative scheme such as the linear
#' conjugate-gradient algorithm.
#'
#' @param x0 starting point for searching the optimum.
#' @param fn objective function that is to be minimized.
#' @param gr gradient of function \code{fn}; will be calculated numerically if
#' not specified.
#' @param lower,upper lower and upper bound constraints.
#' @param precond logical; preset L-BFGS with steepest descent.
#' @param restart logical; restarting L-BFGS with steepest descent.
#' @param nl.info logical; shall the original NLopt info been shown.
#' @param control list of options, see \code{nl.opts} for help.
#' @param ... additional arguments passed to the function.
#'
#' @return List with components:
#'   \item{par}{the optimal solution found so far.}
#'   \item{value}{the function value corresponding to \code{par}.}
#'   \item{iter}{number of (outer) iterations, see \code{maxeval}.}
#'   \item{convergence}{integer code indicating successful completion (> 1)
#'   or a possible error number (< 0).}
#'   \item{message}{character string produced by NLopt and giving additional
#'   information.}
#'
#' @export tnewton
#'
#' @author Hans W. Borchers
#'
#' @note Less reliable than Newton's method, but can handle very large
#' problems.
#'
#' @seealso \code{\link{lbfgs}}
#'
#' @references R. S. Dembo and T. Steihaug, ``Truncated Newton algorithms for
#' large-scale optimization,'' Math. Programming 26, p. 190-212 (1982).
#'
#' @examples
#'
#' flb <- function(x) {
#'   p <- length(x)
#'   sum(c(1, rep(4, p - 1)) * (x - c(1, x[-p]) ^ 2) ^ 2)
#' }
#' # 25-dimensional box constrained: par[24] is *not* at boundary
#' S <- tnewton(rep(3, 25L), flb, lower = rep(2, 25L), upper = rep(4, 25L),
#'        nl.info = TRUE, control = list(xtol_rel = 1e-8))
#' ## Optimal value of objective function:  368.105912874334
#' ## Optimal value of controls: 2  ...  2  2.109093  4
#'
tnewton <- function(
  x0,
  fn,
  gr = NULL,
  lower = NULL,
  upper = NULL,
  precond = TRUE,
  restart = TRUE,
  nl.info = FALSE,
  control = list(),
  ...
) {
  opts <- nl.opts(control)
  if (precond) {
    if (restart) {
      opts["algorithm"] <- "NLOPT_LD_TNEWTON_PRECOND_RESTART"
    } else {
      opts["algorithm"] <- "NLOPT_LD_TNEWTON_PRECOND"
    }
  } else {
    if (restart) {
      opts["algorithm"] <- "NLOPT_LD_TNEWTON_RESTART"
    } else {
      opts["algorithm"] <- "NLOPT_LD_TNEWTON"
    }
  }

  fun <- match.fun(fn)
  fn <- function(x) fun(x, ...)

  if (is.null(gr)) {
    gr <- function(x) nl.grad(x, fn)
  } else {
    .gr <- match.fun(gr)
    gr <- function(x) .gr(x, ...)
  }

  S0 <- nloptr(
    x0,
    eval_f = fn,
    eval_grad_f = gr,
    lb = lower,
    ub = upper,
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
