# Copyright (C) 2014 Hans W. Borchers. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   slsqp.R
# Author: Hans W. Borchers
# Date:   27 January 2014
#
# Wrapper to solve optimization problem using Sequential Quadratic Programming.
#
# CHANGELOG
#
# 2023-02-09: Direct Jacobian now converges to proper value so removing
#   confusing commentary in example. Also Cleanup and tweaks for safety and
#   efficiency (Avraham Adler)
# 2024-06-04: Switched desired direction of the hin/hinjac inequalities, leaving
#       the old behavior as the default for now. Also cleaned up the HS100
#       example (Avraham Adler).
#

#' Sequential Quadratic Programming (SQP)
#'
#' Sequential (least-squares) quadratic programming (SQP) algorithm for
#' nonlinearly constrained, gradient-based optimization, supporting both
#' equality and inequality constraints.
#'
#' The algorithm optimizes successive second-order (quadratic/least-squares)
#' approximations of the objective function (via BFGS updates), with
#' first-order (affine) approximations of the constraints.
#'
#' @param x0 starting point for searching the optimum.
#' @param fn objective function that is to be minimized.
#' @param gr gradient of function \code{fn}; will be calculated numerically if
#' not specified.
#' @param lower,upper lower and upper bound constraints.
#' @param hin function defining the inequality constraints, that is
#' \code{hin <= 0} for all components. This is new behavior in line with the
#' rest of the \code{nloptr} arguments. To use the old behavior, please set
#' \code{deprecatedBehavior} to \code{TRUE}.
#' @param hinjac Jacobian of function \code{hin}; will be calculated
#' numerically if not specified.
#' @param heq function defining the equality constraints, that is \code{heq = 0}
#' for all components.
#' @param heqjac Jacobian of function \code{heq}; will be calculated
#' numerically if not specified.
#' @param nl.info logical; shall the original NLopt info been shown.
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
#'   \item{convergence}{integer code indicating successful completion (> 1)
#'   or a possible error number (< 0).}
#'   \item{message}{character string produced by NLopt and giving additional
#'   information.}
#'
#' @export slsqp
#'
#' @author Hans W. Borchers
#'
#' @note See more infos at
#' \url{https://nlopt.readthedocs.io/en/latest/NLopt_Algorithms/}.
#'
#' @seealso \code{alabama::auglag}, \code{Rsolnp::solnp},
#' \code{Rdonlp2::donlp2}
#'
#' @references Dieter Kraft, ``A software package for sequential quadratic
#' programming'', Technical Report DFVLR-FB 88-28, Institut fuer Dynamik der
#' Flugsysteme, Oberpfaffenhofen, July 1988.
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
#' S <- slsqp(x0.hs100, fn = fn.hs100,   # no gradients and jacobians provided
#'      hin = hin.hs100,
#'      nl.info = TRUE,
#'      control = list(xtol_rel = 1e-8, check_derivatives = TRUE),
#'      deprecatedBehavior = FALSE)
#'
#' ##  The optimum value of the objective function should be 680.6300573
#' ##  A suitable parameter vector is roughly
#' ##  (2.330, 1.9514, -0.4775, 4.3657, -0.6245, 1.0381, 1.5942)
#'
#' S
#'

slsqp <- function(
  x0,
  fn,
  gr = NULL,
  lower = NULL,
  upper = NULL,
  hin = NULL,
  hinjac = NULL,
  heq = NULL,
  heqjac = NULL,
  nl.info = FALSE,
  control = list(),
  deprecatedBehavior = TRUE,
  ...
) {
  opts <- nl.opts(control)
  opts["algorithm"] <- "NLOPT_LD_SLSQP"

  fun <- match.fun(fn)
  fn <- function(x) fun(x, ...)

  if (is.null(gr)) {
    gr <- function(x) nl.grad(x, fn)
  } else {
    .gr <- match.fun(gr)
    gr <- function(x) .gr(x, ...)
  }

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

    if (is.null(hinjac)) {
      hinjac <- function(x) nl.jacobian(x, hin)
    } else if (deprecatedBehavior) {
      warning(
        "The old behavior for hinjac >= 0 has been deprecated. Please ",
        "restate the inequality to be <=0. The ability to use the old ",
        "behavior will be removed in a future release."
      )
      .hinjac <- match.fun(hinjac)
      hinjac <- function(x) -.hinjac(x)
    }
  }

  if (!is.null(heq)) {
    .heq <- match.fun(heq)
    heq <- function(x) .heq(x)
    if (is.null(heqjac)) {
      heqjac <- function(x) nl.jacobian(x, heq)
    } else {
      .heqjac <- match.fun(heqjac)
      heqjac <- function(x) .heqjac(x)
    }
  }

  S0 <- nloptr(
    x0,
    eval_f = fn,
    eval_grad_f = gr,
    lb = lower,
    ub = upper,
    eval_g_ineq = hin,
    eval_jac_g_ineq = hinjac,
    eval_g_eq = heq,
    eval_jac_g_eq = heqjac,
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
