\name{bobyqa}
\alias{bobyqa}
\title{
  Bound Optimization by Quadratic Approximation
}
\description{
  BOBYQA performs derivative-free bound-constrained optimization using an
  iteratively constructed quadratic approximation for the objective function.
}
\usage{
bobyqa(x0, fn, lower = NULL, upper = NULL,
        nl.info = FALSE, control = list(), ...)
}
\arguments{
  \item{x0}{starting point for searching the optimum.}
  \item{fn}{objective function that is to be minimized.}
  \item{lower, upper}{lower and upper bound constraints.}
  \item{nl.info}{logical; shall the original NLopt info been shown.}
  \item{control}{list of options, see \code{nl.opts} for help.}
  \item{\ldots}{additional arguments passed to the function.}
}
\details{
  This is an algorithm derived from the BOBYQA Fortran subroutine of Powell,
  converted to C and modified for the NLOPT stopping criteria.
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
  M. J. D. Powell. ``The BOBYQA algorithm for bound constrained optimization
  without derivatives,'' Department of Applied Mathematics and Theoretical
  Physics, Cambridge England, technical reportNA2009/06 (2009).
}
\note{
  Because BOBYQA constructs a quadratic approximation of the objective,
  it may perform poorly for objective functions that are not
  twice-differentiable.
}
\seealso{
  \code{\link{cobyla}}, \code{\link{newuoa}}
}
\examples{
fr <- function(x) {   ## Rosenbrock Banana function
    100 * (x[2] - x[1]^2)^2 + (1 - x[1])^2
}
(S <- bobyqa(c(0, 0, 0), fr, lower = c(0, 0, 0), upper = c(0.5, 0.5, 0.5)))
}
