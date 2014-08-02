\name{lbfgs}
\alias{lbfgs}
\title{
  Low-storage BFGS
}
\description{
  Low-storage version of the Broyden-Fletcher-Goldfarb-Shanno (BFGS) method.
}
\usage{
lbfgs(x0, fn, gr = NULL, lower = NULL, upper = NULL,
        nl.info = FALSE, control = list(), ...)
}
\arguments{
  \item{x0}{initial point for searching the optimum.}
  \item{fn}{objective function to be minimized.}
  \item{gr}{gradient of function \code{fn};
            will be calculated numerically if not specified.}
  \item{lower, upper}{lower and upper bound constraints.}
  \item{nl.info}{logical; shall the original NLopt info been shown.}
  \item{control}{list of control parameters, see \code{nl.opts} for help.}
  \item{\ldots}{further arguments to be passed to the function.}
}
\details{
  The low-storage (or limited-memory) algorithm is a member of the class of
  quasi-Newton optimization methods. It is well suited for optimization
  problems with a large number of variables.

  One parameter of this algorithm is the number \code{m} of gradients to
  remember from previous optimization steps. NLopt sets \code{m} to a
  heuristic value by default. It can be changed by the NLopt function
  \code{set_vector_storage}.
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
  J. Nocedal, ``Updating quasi-Newton matrices with limited storage,''
  Math. Comput. 35, 773-782 (1980).

  D. C. Liu and J. Nocedal, ``On the limited memory BFGS method for large
  scale optimization,'' Math. Programming 45, p. 503-528 (1989).
}
\note{
  Based on a Fortran implementation of the low-storage BFGS algorithm written
  by L. Luksan, and posted under the GNU LGPL license.
}
\seealso{
  \code{\link{optim}}
}
\examples{
flb <- function(x) {
    p <- length(x)
    sum(c(1, rep(4, p-1)) * (x - c(1, x[-p])^2)^2)
}
# 25-dimensional box constrained: par[24] is *not* at the boundary
S <- lbfgs(rep(3, 25), flb, lower=rep(2, 25), upper=rep(4, 25),
           nl.info = TRUE, control = list(xtol_rel=1e-8))
## Optimal value of objective function:  368.105912874334 
## Optimal value of controls: 2  ...  2  2.109093  4
}
