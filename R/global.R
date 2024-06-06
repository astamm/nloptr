# Copyright (C) 2014 Hans W. Borchers. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   global.R
# Author: Hans W. Borchers
# Date:   27 January 2014
#
# Wrapper to solve optimization problem using StoGo.
#
# CHANGELOG
#
# 2023-02-08: Tweaks for efficiency and readability. (Avraham Adler)
# 2024-06-04: Switched desired direction of the hin/hinjac inequalities, leaving
#       the old behavior as the default for now. Also cleaned up the Hartmann 6
#       example. (Avraham Adler)
#
#----------------------------------StoGo----------------------------------------
#' Stochastic Global Optimization
#'
#' \acronym{StoGO} is a global optimization algorithm that works by
#' systematically dividing the search space---which must be
#' bound-constrained---into smaller hyper-rectangles via a branch-and-bound
#' technique, and searching them using a gradient-based local-search algorithm
#' (a \acronym{BFGS} variant), optionally including some randomness.
#'
#' @param x0 initial point for searching the optimum.
#' @param fn objective function that is to be minimized.
#' @param gr optional gradient of the objective function.
#' @param lower,upper lower and upper bound constraints.
#' @param maxeval maximum number of function evaluations.
#' @param xtol_rel stopping criterion for relative change reached.
#' @param randomized logical; shall a randomizing variant be used?
#' @param nl.info logical; shall the original \acronym{NLopt} info be shown.
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
#' @export stogo
#'
#' @author Hans W. Borchers
#'
#' @note Only bounds-constrained problems are supported by this algorithm.
#'
#' @references S. Zertchaninov and K. Madsen, ``A C++ Programme for Global
#' Optimization,'' IMM-REP-1998-04, Department of Mathematical Modelling,
#' Technical University of Denmark.
#'
#' @examples
#'
#' ## Rosenbrock Banana objective function
#'
#' rbf <- function(x) {(1 - x[1]) ^ 2 + 100 * (x[2] - x[1] ^ 2) ^ 2}
#'
#' x0 <- c(-1.2, 1)
#' lb <- c(-3, -3)
#' ub <- c(3,  3)
#'
#' ## The function as written above has a minimum of 0 at (1, 1)
#'
#' stogo(x0 = x0, fn = rbf, lower = lb, upper = ub)
#'

stogo <- function(x0, fn, gr = NULL, lower = NULL, upper = NULL,
                  maxeval = 10000, xtol_rel = 1e-6, randomized = FALSE,
                  nl.info = FALSE, ...) {

  opts <- list()
  opts$maxeval <- maxeval
  opts$xtol_rel <- xtol_rel
  if (randomized) {
    opts["algorithm"] <- "NLOPT_GD_STOGO_RAND"
  } else {
    opts["algorithm"] <- "NLOPT_GD_STOGO"
  }

  fun <- match.fun(fn)
  fn <- function(x) fun(x, ...)

  if (is.null(gr)) {gr <- function(x) nl.grad(x, fn)}

  S0 <- nloptr(x0,
               eval_f = fn,
               eval_grad_f = gr,
               lb = lower,
               ub = upper,
               opts = opts)

  if (nl.info) print(S0)

  list(par = S0$solution, value = S0$objective, iter = S0$iterations,
       convergence = S0$status, message = S0$message)
}

#---------------------------------ISRES-----------------------------------------
# ISRES supports nonlinear constraints but mat be quite inaccurate!

#' Improved Stochastic Ranking Evolution Strategy
#'
#' The Improved Stochastic Ranking Evolution Strategy (\acronym{ISRES}) is an
#' algorithm for nonlinearly constrained global optimization, or at least
#' semi-global, although it has heuristics to escape local optima.
#'
#' The evolution strategy is based on a combination of a mutation rule---with a
#' log-normal step-size update and exponential smoothing---and differential
#' variation---a Nelder-Mead-like update rule). The fitness ranking is simply
#' via the objective function for problems without nonlinear constraints, but
#' when nonlinear constraints are included the stochastic ranking proposed by
#' Runarsson and Yao is employed.
#'
#' This method supports arbitrary nonlinear inequality and equality constraints
#' in addition to the bounds constraints.
#'
#' @param x0 initial point for searching the optimum.
#' @param fn objective function that is to be minimized.
#' @param lower,upper lower and upper bound constraints.
#' @param hin function defining the inequality constraints, that is
#' \code{hin <= 0} for all components.
#' @param heq function defining the equality constraints, that is \code{heq = 0}
#' for all components.
#' @param maxeval maximum number of function evaluations.
#' @param pop.size population size.
#' @param xtol_rel stopping criterion for relative change reached.
#' @param nl.info logical; shall the original \acronym{NLopt} info be shown.
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
#' @export isres
#'
#' @author Hans W. Borchers
#'
#' @note The initial population size for CRS defaults to \eqn{20x(n+1)} in
#' \eqn{n} dimensions, but this can be changed. The initial population must be
#' at least \eqn{n+1}.
#'
#' @references Thomas Philip Runarsson and Xin Yao, ``Search biases in
#' constrained evolutionary optimization,'' IEEE Trans. on Systems, Man, and
#' Cybernetics Part C: Applications and Reviews, vol. 35 (no. 2), pp. 233-243
#' (2005).
#'
#' @examples
#'
#' ## Rosenbrock Banana objective function
#'
#' rbf <- function(x) {(1 - x[1]) ^ 2 + 100 * (x[2] - x[1] ^ 2) ^ 2}
#'
#' x0 <- c(-1.2, 1)
#' lb <- c(-3, -3)
#' ub <- c(3,  3)
#'
#' ## The function as written above has a minimum of 0 at (1, 1)
#'
#' isres(x0 = x0, fn = rbf, lower = lb, upper = ub)
#'
#' ## Now subject to the inequality that x[1] + x[2] <= 1.5
#'
#' hin <- function(x) {x[1] + x[2] - 1.5}
#'
#' S <- isres(x0 = x0, fn = rbf, hin = hin, lower = lb, upper = ub,
#'            maxeval = 2e5L, deprecatedBehavior = FALSE)
#'
#' S
#'
#' sum(S$par)
#'

isres <- function(x0, fn, lower, upper, hin = NULL, heq = NULL, maxeval = 10000,
                  pop.size = 20 * (length(x0) + 1), xtol_rel = 1e-6,
                  nl.info = FALSE, deprecatedBehavior = TRUE, ...) {

  opts <- list()
  opts$maxeval  <- maxeval
  opts$xtol_rel   <- xtol_rel
  opts$population <- pop.size
  opts$algorithm  <- "NLOPT_GN_ISRES"

  fun <- match.fun(fn)
  fn  <- function(x) fun(x, ...)

  if (!is.null(hin)) {
    if (deprecatedBehavior) {
      warning("The old behavior for hin >= 0 has been deprecated. Please ",
              "restate the inequality to be <=0. The ability to use the old ",
              "behavior will be removed in a future release.")
      .hin <- match.fun(hin)
      hin <- function(x) -.hin(x)      # change  hin >= 0  to  hin <= 0 !
    }
  }

  if (!is.null(heq)) {
    .heq <- match.fun(heq)
    heq <- function(x) .heq(x)
  }

  S0 <- nloptr(x0 = x0,
               eval_f = fn,
               lb = lower,
               ub = upper,
               eval_g_ineq = hin,
               eval_g_eq = heq,
               opts = opts)

  if (nl.info) print(S0)
  list(par = S0$solution, value = S0$objective, iter = S0$iterations,
       convergence = S0$status, message = S0$message)
}

#-  --------------------------------- CRS --------------------------------------

#' Controlled Random Search
#'
#' The Controlled Random Search (\acronym{CRS}) algorithm (and in particular,
#' the \acronym{CRS2} variant) with the `local mutation' modification.
#'
#' The \acronym{CRS} algorithms are sometimes compared to genetic algorithms, in
#' that they start with a random population of points, and randomly evolve these
#' points by heuristic rules. In this case, the evolution somewhat resembles a
#' randomized Nelder-Mead algorithm.
#'
#' The published results for \acronym{CRS} seem to be largely empirical.
#'
#' @param x0 initial point for searching the optimum.
#' @param fn objective function that is to be minimized.
#' @param lower,upper lower and upper bound constraints.
#' @param maxeval maximum number of function evaluations.
#' @param pop.size population size.
#' @param ranseed prescribe seed for random number generator.
#' @param xtol_rel stopping criterion for relative change reached.
#' @param nl.info logical; shall the original \acronym{NLopt} info be shown.
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
#' @export crs2lm
#'
#' @note The initial population size for CRS defaults to \eqn{10x(n+1)} in
#' \eqn{n} dimensions, but this can be changed. The initial population must be
#' at least \eqn{n+1}.
#'
#' @references W. L. Price, ``Global optimization by controlled random
#' search,'' J. Optim. Theory Appl. 40 (3), p. 333-348 (1983).
#'
#' P. Kaelo and M. M. Ali, ``Some variants of the controlled random search
#' algorithm for global optimization,'' J. Optim. Theory Appl. 130 (2), 253-264
#' (2006).
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
#' S <- crs2lm(x0 = rep(0, 6), hartmann6, lower = rep(0, 6), upper = rep(1, 6),
#'             ranseed = 10L, nl.info = TRUE, xtol_rel=1e-8, maxeval = 10000,
#'             a = a, A = A, B = B)
#'
#' S
#'

crs2lm <- function(x0, fn, lower, upper, maxeval = 10000,
                   pop.size = 10 * (length(x0) + 1), ranseed = NULL,
                   xtol_rel = 1e-6, nl.info = FALSE, ...) {

  opts <- list()
  opts$maxeval <- maxeval
  opts$xtol_rel <- xtol_rel
  opts$population <- pop.size
  if (!is.null(ranseed)) {opts$ranseed <- as.integer(ranseed)}
  opts$algorithm  <- "NLOPT_GN_CRS2_LM"

  fun <- match.fun(fn)
  fn  <- function(x) fun(x, ...)

  S0 <- nloptr(x0,
               eval_f = fn,
               lb = lower,
               ub = upper,
               opts = opts)

  if (nl.info) print(S0)

  list(par = S0$solution, value = S0$objective, iter = S0$iterations,
       convergence = S0$status, message = S0$message)
}
