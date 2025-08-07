# Copyright (C) 2014 Hans W. Borchers. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   mlsl.R
# Author: Hans W. Borchers
# Date:   27 January 2014
#
# Wrapper to solve optimization problem using Multi-Level Single-Linkage.
#
# CHANGELOG:
#
# 2014-05-05: Replaced cat by warning.
# 2023-02-09: Cleanup and tweaks for safety and efficiency. (Avraham Adler)
#       Question, should passing a non-Gradient solver fail directly? It will
#       anyway. (Avraham Adler)
# 2024-06-04: Cleaned up the Hartmann 6 example. (Avraham Adler)
#

#' Multi-level Single-linkage
#'
#' The \dQuote{Multi-Level Single-Linkage} (\acronym{MLSL}) algorithm for global
#' optimization searches by a sequence of local optimizations from random
#' starting points. A modification of \acronym{MLSL} is included using a
#' low-discrepancy sequence (\acronym{LDS}) instead of pseudorandom numbers.
#'
#' \acronym{MLSL} is a \sQuote{multistart} algorithm: it works by doing a
#' sequence of local optimizations---using some other local optimization
#' algorithm---from random or low-discrepancy starting points. MLSL is
#' distinguished, however, by a `clustering' heuristic that helps it to avoid
#' repeated searches of the same local optima and also has some theoretical
#' guarantees of finding all local optima in a finite number of local
#' minimizations.
#'
#' The local-search portion of \acronym{MLSL} can use any of the other
#' algorithms in \acronym{NLopt}, and, in particular, can use either
#' gradient-based or derivative-free algorithms. For this wrapper only
#' gradient-based \acronym{LBFGS} is available as local method.
#'
#' @param x0 initial point for searching the optimum.
#' @param fn objective function that is to be minimized.
#' @param gr gradient of function \code{fn}; will be calculated numerically if
#' not specified.
#' @param lower,upper lower and upper bound constraints.
#' @param local.method only \code{BFGS} for the moment.
#' @param low.discrepancy logical; shall a low discrepancy variation be used.
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
#' @export mlsl
#'
#' @author Hans W. Borchers
#'
#' @note If you don't set a stopping tolerance for your local-optimization
#' algorithm, \acronym{MLSL} defaults to \code{ftol_rel = 1e-15} and
#' \code{xtol_rel = 1e-7} for the local searches.
#'
#' @seealso \code{\link{direct}}
#'
#' @references A. H. G. Rinnooy Kan and G. T. Timmer, \dQuote{Stochastic global
#' optimization methods} Mathematical Programming, vol. 39, p. 27-78 (1987).
#'
#' Sergei Kucherenko and Yury Sytsko, \dQuote{Application of deterministic
#' low-discrepancy sequences in global optimization}, Computational
#' Optimization and Applications, vol. 30, p. 297-318 (2005).
#'
#' @examples
#'
#' ## Minimize the Hartmann 6-Dimensional function
#' ## See https://www.sfu.ca/~ssurjano/hart6.html
#'
#' a <- c(1.0, 1.2, 3.0, 3.2)
#' A <- matrix(c(10,  0.05, 3, 17,
#'               3, 10, 3.5, 8,
#'               17, 17, 1.7, 0.05,
#'               3.5, 0.1, 10, 10,
#'               1.7, 8, 17, 0.1,
#'               8, 14, 8, 14), nrow = 4)
#'
#' B  <- matrix(c(.1312, .2329, .2348, .4047,
#'                .1696, .4135, .1451, .8828,
#'                .5569, .8307, .3522, .8732,
#'                .0124, .3736, .2883, .5743,
#'                .8283, .1004, .3047, .1091,
#'                .5886, .9991, .6650, .0381), nrow = 4)
#'
#' hartmann6 <- function(x, a, A, B) {
#'   fun <- 0
#'   for (i in 1:4) {
#'     fun <- fun - a[i] * exp(-sum(A[i, ] * (x - B[i, ]) ^ 2))
#'   }
#'
#'   fun
#' }
#'
#' ## The function has a global minimum of -3.32237 at
#' ## (0.20169, 0.150011, 0.476874, 0.275332, 0.311652, 0.6573)
#'
#' S <- mlsl(x0 = rep(0, 6), hartmann6, lower = rep(0, 6), upper = rep(1, 6),
#'       nl.info = TRUE, control = list(xtol_rel = 1e-8, maxeval = 1000),
#'       a = a, A = A, B = B)
#'

mlsl <- function(
  x0,
  fn,
  gr = NULL,
  lower,
  upper,
  local.method = "LBFGS",
  low.discrepancy = TRUE,
  nl.info = FALSE,
  control = list(),
  ...
) {
  local_opts <- list(algorithm = "NLOPT_LD_LBFGS", xtol_rel = 1e-4)
  opts <- nl.opts(control)

  if (low.discrepancy) {
    opts["algorithm"] <- "NLOPT_GD_MLSL_LDS"
  } else {
    opts["algorithm"] <- "NLOPT_GD_MLSL"
  }

  opts[["local_opts"]] <- local_opts

  fun <- match.fun(fn)
  fn <- function(x) fun(x, ...)

  if (local.method == "LBFGS") {
    if (is.null(gr)) {
      gr <- function(x) nl.grad(x, fn)
    } else {
      .gr <- match.fun(gr)
      gr <- function(x) .gr(x, ...)
    }
  } else {
    warning(
      "Only gradient-based LBFGS available as local method. ",
      "To use another method please use the nloptr interface."
    )
    gr <- NULL
  }

  S0 <- nloptr(
    x0 = x0,
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
