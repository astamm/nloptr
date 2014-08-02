\name{stogo}
\alias{stogo}
\title{
  Stochastic Global Optimization
}
\description{
  StoGO is a global optimization algorithm that works by systematically 
  dividing the search space into smaller hyper-rectangles.
}
\usage{
stogo(x0, fn, gr = NULL, lower = NULL, upper = NULL,
      maxeval = 10000, xtol_rel = 1e-6, randomized = FALSE,
      nl.info = FALSE, ...)
}
\arguments{
  \item{x0}{initial point for searching the optimum.}
  \item{fn}{objective function that is to be minimized.}
  \item{gr}{optional gradient of the objective function.}
  \item{lower, upper}{lower and upper bound constraints.}
  \item{maxeval}{maximum number of function evaluations.}
  \item{xtol_rel}{stopping criterion for relative change reached.}
  \item{randomized}{logical; shall a randomizing variant be used?}
  \item{nl.info}{logical; shall the original NLopt info been shown.}
  \item{\ldots}{additional arguments passed to the function.}
}
\details{
  StoGO is a global optimization algorithm that works by systematically 
  dividing the search space (which must be bound-constrained) into smaller 
  hyper-rectangles via a branch-and-bound technique, and searching them by 
  a gradient-based local-search algorithm (a BFGS variant), optionally 
  including some randomness.
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
  S. Zertchaninov and K. Madsen, ``A C++ Programme for Global Optimization,'' 
  IMM-REP-1998-04, Department of Mathematical Modelling, Technical University 
  of Denmark.
}
\note{
  Only bound-constrained problems are supported by this algorithm.
}
\examples{
### Rosenbrock Banana objective function
fn <- function(x)
    return( 100 * (x[2] - x[1] * x[1])^2 + (1 - x[1])^2 )

x0 <- c( -1.2, 1 )
lb <- c( -3, -3 )
ub <- c(  3,  3 )

stogo(x0 = x0, fn = fn, lower = lb, upper = ub)
}
