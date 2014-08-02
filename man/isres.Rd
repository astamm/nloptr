\name{isres}
\alias{isres}
\title{
  Improved Stochastic Ranking Evolution Strategy
}
\description{
  The Improved Stochastic Ranking Evolution Strategy (ISRES) algorithm for
  nonlinearly constrained global optimization (or at least semi-global:
  although it has heuristics to escape local optima.
}
\usage{
isres(x0, fn, lower, upper, hin = NULL, heq = NULL,
        maxeval = 10000, pop.size = 20*(length(x0)+1),
        xtol_rel = 1e-6, nl.info = FALSE, ...)
}
\arguments{
  \item{x0}{initial point for searching the optimum.}
  \item{fn}{objective function that is to be minimized.}
  \item{lower, upper}{lower and upper bound constraints.}
  \item{hin}{function defining the inequality constraints, that is
             \code{hin>=0} for all components.}
  \item{heq}{function defining the equality constraints, that is
             \code{heq==0} for all components.}
  \item{maxeval}{maximum number of function evaluations.}
  \item{pop.size}{population size.}
  \item{xtol_rel}{stopping criterion for relative change reached.}
  \item{nl.info}{logical; shall the original NLopt info been shown.}
  \item{\ldots}{additional arguments passed to the function.}
}
\details{
  The evolution strategy is based on a combination of a mutation rule (with
  a log-normal step-size update and exponential smoothing) and differential
  variation (a Nelder-Mead-like update rule). The fitness ranking is simply
  via the objective function for problems without nonlinear constraints, but
  when nonlinear constraints are included the stochastic ranking proposed by
  Runarsson and Yao is employed.

  This method supports arbitrary nonlinear inequality and equality constraints
  in addition to the bound constraints.
}
\value{
List with components:
  \item{par}{the optimal solution found so far.}
  \item{value}{the function value corresponding to \code{par}.}
  \item{iter}{number of (outer) iterations, see \code{maxeval}.}
  \item{convergence}{integer code indicating successful completion (> 0)
                     or a possible error number (< 0).}
  \item{message}{character string produced by NLopt and giving additional
                 information.}
}
\references{
  Thomas Philip Runarsson and Xin Yao, ``Search biases in constrained
  evolutionary optimization,'' IEEE Trans. on Systems, Man, and Cybernetics
  Part C: Applications and Reviews, vol. 35 (no. 2), pp. 233-243 (2005).
}
\note{
  The initial population size for CRS defaults to \code{20x(n+1)} in \code{n}
  dimensions, but this can be changed; the initial population must be at least
  \code{n+1}.
}
\examples{
### Rosenbrock Banana objective function
fn <- function(x)
    return( 100 * (x[2] - x[1] * x[1])^2 + (1 - x[1])^2 )

x0 <- c( -1.2, 1 )
lb <- c( -3, -3 )
ub <- c(  3,  3 )

isres(x0 = x0, fn = fn, lower = lb, upper = ub)
}
