\name{varmetric}
\alias{varmetric}
\title{
  Shifted Limited-memory Variable-metric
}
\description{
  Shifted limited-memory variable-metric algorithm.
}
\usage{
    varmetric(x0, fn, gr = NULL, rank2 = TRUE,
                lower = NULL, upper = NULL,
                nl.info = FALSE, control = list(), ...)
}
\arguments{
  \item{x0}{initial point for searching the optimum.}
  \item{fn}{objective function to be minimized.}
  \item{gr}{gradient of function \code{fn};
            will be calculated numerically if not specified.}
  \item{rank2}{logical; if true uses a rank-2 update method, else rank-1.}
  \item{lower, upper}{lower and upper bound constraints.}
  \item{nl.info}{logical; shall the original NLopt info been shown.}
  \item{control}{list of control parameters, see \code{nl.opts} for help.}
  \item{\ldots}{further arguments to be passed to the function.}
}
\details{
  Variable-metric methods are a variant of the quasi-Newton methods,
  especially adapted to large-scale unconstrained (or bound constrained)
  minimization.
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
  J. Vlcek and L. Luksan, ``Shifted limited-memory variable metric methods
  for large-scale unconstrained minimization,''
  J. Computational Appl. Math. 186, p. 365-390 (2006).
}
\note{
  Based on L. Luksan's Fortran implementation of a shifted limited-memory
  variable-metric algorithm.
}
\seealso{
  \code{\link{lbfgs}}
}
\examples{
flb <- function(x) {
    p <- length(x)
    sum(c(1, rep(4, p-1)) * (x - c(1, x[-p])^2)^2)
}
# 25-dimensional box constrained: par[24] is *not* at the boundary
S <- varmetric(rep(3, 25), flb, lower=rep(2, 25), upper=rep(4, 25),
           nl.info = TRUE, control = list(xtol_rel=1e-8))
## Optimal value of objective function:  368.105912874334 
## Optimal value of controls: 2  ...  2  2.109093  4
}
