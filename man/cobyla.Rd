\name{cobyla}
\alias{cobyla}
\title{
  Constrained Optimization by Linear Approximations
}
\description{
  COBYLA is an algorithm for derivative-free optimization with nonlinear
  inequality and equality constraints (but see below).
}
\usage{
cobyla(x0, fn, lower = NULL, upper = NULL, hin = NULL,
        nl.info = FALSE, control = list(), ...)
}
\arguments{
  \item{x0}{starting point for searching the optimum.}
  \item{fn}{objective function that is to be minimized.}
  \item{lower, upper}{lower and upper bound constraints.}
  \item{hin}{function defining the inequality constraints, that is
               \code{hin>=0} for all components.}
  \item{nl.info}{logical; shall the original NLopt info been shown.}
  \item{control}{list of options, see \code{nl.opts} for help.}
  \item{\ldots}{additional arguments passed to the function.}
}
\details{
  It constructs successive linear approximations of the objective function
  and constraints via a simplex of n+1 points (in n dimensions), and
  optimizes these approximations in a trust region at each step.

  COBYLA supports equality constraints by transforming them into two
  inequality constraints. As this does not give full satisfaction with the
  implementation in NLOPT, it has not been made available here.
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
  M. J. D. Powell, ``A direct search optimization method that models the
  objective and constraint functions by linear interpolation,'' in Advances
  in Optimization and Numerical Analysis, eds. S. Gomez and J.-P. Hennart
  (Kluwer Academic: Dordrecht, 1994), p. 51-67.
}
\note{
  The original code, written in Fortran by Powell, was converted in C for the
  Scipy project.
}
\seealso{
  \code{\link{bobyqa}}, \code{\link{newuoa}}
}
\examples{
### Solve Hock-Schittkowski no. 100
x0.hs100 <- c(1, 2, 0, 4, 0, 1, 1)
fn.hs100 <- function(x) {
    (x[1]-10)^2 + 5*(x[2]-12)^2 + x[3]^4 + 3*(x[4]-11)^2 + 10*x[5]^6 +
                  7*x[6]^2 + x[7]^4 - 4*x[6]*x[7] - 10*x[6] - 8*x[7]
}
hin.hs100 <- function(x) {
    h <- numeric(4)
    h[1] <- 127 - 2*x[1]^2 - 3*x[2]^4 - x[3] - 4*x[4]^2 - 5*x[5]
    h[2] <- 282 - 7*x[1] - 3*x[2] - 10*x[3]^2 - x[4] + x[5]
    h[3] <- 196 - 23*x[1] - x[2]^2 - 6*x[6]^2 + 8*x[7]
    h[4] <- -4*x[1]^2 - x[2]^2 + 3*x[1]*x[2] -2*x[3]^2 - 5*x[6]	+11*x[7]
    return(h)
}

S <- cobyla(x0.hs100, fn.hs100, hin = hin.hs100,
            nl.info = TRUE, control = list(xtol_rel = 1e-8, maxeval = 2000))
## Optimal value of objective function:  680.630057374431
}
