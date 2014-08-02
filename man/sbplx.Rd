\name{sbplx}
\alias{sbplx}
\title{
  Subplex Algorithm
}
\description{
  Subplex is a variant of Nelder-Mead that uses Nelder-Mead on a sequence of
  subspaces.
}
\usage{
sbplx(x0, fn, lower = NULL, upper = NULL,
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
  SUBPLEX is claimed to be much more efficient and robust than the original
  Nelder-Mead, while retaining the latter's facility with discontinuous
  objectives.

  This implementation has explicit support for bound constraints (via the
  method in the Box paper as described on the \code{neldermead} help page).
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
  T. Rowan, ``Functional Stability Analysis of Numerical Algorithms'', Ph.D.
  thesis, Department of Computer Sciences, University of Texas at Austin, 1990.
}
\note{
  It is the request of Tom Rowan that reimplementations of his algorithm shall
  not use the name `subplex'.
}
\seealso{
  \code{subplex::subplex}
}
\examples{
# Fletcher and Powell's helic valley
fphv <- function(x)
    100*(x[3] - 10*atan2(x[2], x[1])/(2*pi))^2 + 
        (sqrt(x[1]^2 + x[2]^2) - 1)^2 +x[3]^2
x0 <- c(-1, 0, 0)
sbplx(x0, fphv)    #  1 0 0

# Powell's Singular Function (PSF)
psf <- function(x)  (x[1] + 10*x[2])^2 + 5*(x[3] - x[4])^2 + 
                    (x[2] - 2*x[3])^4 + 10*(x[1] - x[4])^4
x0 <- c(3, -1, 0, 1)
sbplx(x0, psf, control = list(maxeval = Inf, ftol_rel = 1e-6))  #  0 0 0 0 (?)
}
