\name{DIRECT}
\alias{direct}
\alias{directL}
\title{
  DIviding RECTangles Algorithm for Global Optimization
}
\description{
  DIRECT is a deterministic search algorithm based on systematic division of
  the search domain into smaller and smaller hyperrectangles. The DIRECT_L
  makes the algorithm more biased towards local search (more efficient for
  functions without too many minima).
}
\usage{
direct(fn, lower, upper, scaled = TRUE, original = FALSE,
        nl.info = FALSE, control = list(), ...)

directL(fn, lower, upper, randomized = FALSE, original = FALSE,
        nl.info = FALSE, control = list(), ...)
}
\arguments{
  \item{fn}{objective function that is to be minimized.}
  \item{lower, upper}{lower and upper bound constraints.}
  \item{scaled}{logical; shall the hypercube be scaled before starting.}
  \item{randomized}{logical; shall some randomization be used to decide which
                    dimension to halve next in the case of near-ties.}
  \item{original}{logical; whether to use the original implementation by
                  Gablonsky -- the performance is mostly similar.}
  \item{nl.info}{logical; shall the original NLopt info been shown.}
  \item{control}{list of options, see \code{nl.opts} for help.}
  \item{\ldots}{additional arguments passed to the function.}
}
\details{
  The DIRECT and DIRECT-L algorithms start by rescaling the bound constraints
  to a hypercube, which gives all dimensions equal weight in the search
  procedure. If your dimensions do not have equal weight, e.g. if you have a
  ``long and skinny'' search space and your function varies at about the same
  speed in all directions, it may be better to use unscaled variant of the
  DIRECT algorithm.

  The algorithms only handle finite bound constraints which must be provided.
  The original versions may include some support for arbitrary nonlinear
  inequality, but this has not been tested.

  The original versions do not have randomized or unscaled variants, so these
  options will be disregarded for these versions.
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
  D. R. Jones, C. D. Perttunen, and B. E. Stuckmann, ``Lipschitzian
  optimization without the lipschitz constant,'' J. Optimization Theory and
  Applications, vol. 79, p. 157 (1993).

  J. M. Gablonsky and C. T. Kelley, ``A locally-biased form of the DIRECT
  algorithm," J. Global Optimization, vol. 21 (1), p. 27-37 (2001).
}
\note{
  The DIRECT_L algorithm should be tried first.
}
\seealso{
  The \code{dfoptim} package will provide a pure R version of this algorithm.
}
\examples{
### Minimize the Hartmann6 function
hartmann6 <- function(x) {
    n <- length(x)
    a <- c(1.0, 1.2, 3.0, 3.2)
    A <- matrix(c(10.0,  0.05, 3.0, 17.0,
                   3.0, 10.0,  3.5,  8.0,
                  17.0, 17.0,  1.7,  0.05,
                   3.5,  0.1, 10.0, 10.0,
                   1.7,  8.0, 17.0,  0.1,
                   8.0, 14.0,  8.0, 14.0), nrow=4, ncol=6)
    B  <- matrix(c(.1312,.2329,.2348,.4047,
                   .1696,.4135,.1451,.8828,
                   .5569,.8307,.3522,.8732,
                   .0124,.3736,.2883,.5743,
                   .8283,.1004,.3047,.1091,
                   .5886,.9991,.6650,.0381), nrow=4, ncol=6)
    fun <- 0.0
    for (i in 1:4) {
        fun <- fun - a[i] * exp(-sum(A[i,]*(x-B[i,])^2))
    }
    return(fun)
}
S <- directL(hartmann6, rep(0,6), rep(1,6),
             nl.info = TRUE, control=list(xtol_rel=1e-8, maxeval=1000))
## Number of Iterations....: 500 
## Termination conditions:  stopval: -Inf
##     xtol_rel: 1e-08,  maxeval: 500,  ftol_rel: 0,  ftol_abs: 0 
## Number of inequality constraints:  0 
## Number of equality constraints:    0 
## Current value of objective function:  -3.32236800687327
## Current value of controls:
##     0.2016884 0.1500025 0.4768667 0.2753391 0.311648 0.6572931
}
