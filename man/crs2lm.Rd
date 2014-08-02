\name{csr2lm}
\alias{crs2lm}
\title{
  Controlled Random Search
}
\description{
  The Controlled Random Search (CRS) algorithm (and in particular, the CRS2
  variant) with the `local mutation' modification.
}
\usage{
crs2lm(x0, fn, lower, upper,
        maxeval = 10000, pop.size = 10*(length(x0)+1), ranseed = NULL,
        xtol_rel = 1e-6, nl.info = FALSE, ...)
}
\arguments{
  \item{x0}{initial point for searching the optimum.}
  \item{fn}{objective function that is to be minimized.}
  \item{lower, upper}{lower and upper bound constraints.}
  \item{maxeval}{maximum number of function evaluations.}
  \item{pop.size}{population size.}
  \item{ranseed}{prescribe seed for random number generator.}
  \item{xtol_rel}{stopping criterion for relative change reached.}
  \item{nl.info}{logical; shall the original NLopt info been shown.}
  \item{\ldots}{additional arguments passed to the function.}
}
\details{
  The CRS algorithms are sometimes compared to genetic algorithms, in that
  they start with a random population of points, and randomly evolve these
  points by heuristic rules. In this case, the evolution somewhat resembles
  a randomized Nelder-Mead algorithm.

    The published results for CRS seem to be largely empirical.
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
  W. L. Price, ``Global optimization by controlled random search,''
  J. Optim. Theory Appl. 40 (3), p. 333-348 (1983).

  P. Kaelo and M. M. Ali, ``Some variants of the controlled random search
  algorithm for global optimization,''
  J. Optim. Theory Appl. 130 (2), 253-264 (2006).
}
\note{
  The initial population size for CRS defaults to \code{10x(n+1)} in \code{n}
  dimensions, but this can be changed; the initial population must be at least
  \code{n+1}.
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

S <- mlsl(x0 = rep(0, 6), hartmann6, lower = rep(0,6), upper = rep(1,6),
            nl.info = TRUE, control=list(xtol_rel=1e-8, maxeval=1000))
## Number of Iterations....: 4050 
## Termination conditions:  maxeval: 10000	xtol_rel: 1e-06 
## Number of inequality constraints:  0 
## Number of equality constraints:    0 
## Optimal value of objective function:  -3.32236801141328 
## Optimal value of controls:
##     0.2016893 0.1500105 0.4768738 0.2753326 0.3116516 0.6573004
}
