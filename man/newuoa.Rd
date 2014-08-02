\name{newuoa}
\alias{newuoa}
\title{
  New Unconstrained Optimization with quadratic Approximation
}
\description{
  NEWUOA solves quadratic subproblems in a spherical trust regionvia a
  truncated conjugate-gradient algorithm. For bound-constrained problems,
  BOBYQA shold be used instead, as Powell developed it as an enhancement
  thereof for bound constraints.
}
\usage{
newuoa(x0, fn, nl.info = FALSE, control = list(), ...)
}
\arguments{
  \item{x0}{starting point for searching the optimum.}
  \item{fn}{objective function that is to be minimized.}
  \item{nl.info}{logical; shall the original NLopt info been shown.}
  \item{control}{list of options, see \code{nl.opts} for help.}
  \item{\ldots}{additional arguments passed to the function.}
}
\details{
  This is an algorithm derived from the NEWUOA Fortran subroutine of Powell,
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
  NEWUOA may be largely superseded by BOBYQA.
}
\seealso{
  \code{\link{bobyqa}}, \code{\link{cobyla}}
}
\examples{
fr <- function(x) {   ## Rosenbrock Banana function
    100 * (x[2] - x[1]^2)^2 + (1 - x[1])^2
}
(S <- newuoa(c(1, 2), fr))
}
