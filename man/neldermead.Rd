\name{neldermead}
\alias{neldermead}
\title{
  Nelder-Mead Simplex
}
\description{
  An implementation of almost the original Nelder-Mead simplex algorithm.
}
\usage{
neldermead(x0, fn, lower = NULL, upper = NULL,
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
  Provides xplicit support for bound constraints, using essentially the method
  proposed in [Box].
  Whenever a new point would lie outside the bound constraints the point is
  moved back exactly onto the constraint.
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
  J. A. Nelder and R. Mead, ``A simplex method for function minimization,''
  The Computer Journal 7, p. 308-313 (1965).

  M. J. Box, ``A new method of constrained optimization and a comparison with
  other methods,'' Computer J. 8 (1), 42-52 (1965).
}
\note{
  The author of NLopt would tend to recommend the Subplex method instead.
}
\seealso{
  \code{dfoptim::nmk}
}
\examples{
# Fletcher and Powell's helic valley
fphv <- function(x)
    100*(x[3] - 10*atan2(x[2], x[1])/(2*pi))^2 + 
        (sqrt(x[1]^2 + x[2]^2) - 1)^2 +x[3]^2
x0 <- c(-1, 0, 0)
neldermead(x0, fphv)    #  1 0 0

# Powell's Singular Function (PSF)
psf <- function(x)  (x[1] + 10*x[2])^2 + 5*(x[3] - x[4])^2 + 
                    (x[2] - 2*x[3])^4 + 10*(x[1] - x[4])^4
x0 <- c(3, -1, 0, 1)
neldermead(x0, psf)     #  0 0 0 0, needs maximum number of function calls

\dontrun{
# Bounded version of Nelder-Mead
lower <- c(-Inf, 0,   0)
upper <- c( Inf, 0.5, 1)
x0 <- c(0, 0.1, 0.1)
S <- neldermead(c(0, 0.1, 0.1), rosenbrock, lower, upper, nl.info = TRUE)
# $xmin = c(0.7085595, 0.5000000, 0.2500000)
# $fmin = 0.3353605}
}
