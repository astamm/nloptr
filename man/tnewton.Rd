\name{tnewton}
\alias{tnewton}
\title{
  Preconditioned Truncated Newton
}
\description{
  Truncated Newton methods, also calledNewton-iterative methods, solve an
  approximating Newton system using a conjugate-gradient approach and are
  related to limited-memory BFGS.
}
\usage{
tnewton(x0, fn, gr = NULL, lower = NULL, upper = NULL,
        precond = TRUE, restart = TRUE,
        nl.info = FALSE, control = list(), ...)
}
\arguments{
  \item{x0}{starting point for searching the optimum.}
  \item{fn}{objective function that is to be minimized.}
  \item{gr}{gradient of function \code{fn};
            will be calculated numerically if not specified.}
  \item{lower, upper}{lower and upper bound constraints.}
  \item{precond}{logical; preset L-BFGS with steepest descent.}
  \item{restart}{logical; restarting L-BFGS with steepest descent.}
  \item{nl.info}{logical; shall the original NLopt info been shown.}
  \item{control}{list of options, see \code{nl.opts} for help.}
  \item{\ldots}{additional arguments passed to the function.}
}
\details{
  Truncated Newton methods are based on approximating the objective with
  a quadratic function and applying an iterative scheme such as the linear
  conjugate-gradient algorithm.
}
\value{
List with components:
  \item{par}{the optimal solution found so far.}
  \item{value}{the function value corresponding to \code{par}.}
  \item{iter}{number of (outer) iterations, see \code{maxeval}.}
  \item{convergence}{integer code indicating successful completion (> 1)
                     or a possible error number (< 0).}
  \item{message}{character string produced by NLopt and giving additional
                 information.}
}
\references{
  R. S. Dembo and T. Steihaug, ``Truncated Newton algorithms for large-scale
  optimization,'' Math. Programming 26, p. 190-212 (1982).
}
\note{
  Less reliable than Newton's method, but can handle very large problems.
}
\seealso{
  \code{\link{lbfgs}}
}
\examples{
flb <- function(x) {
    p <- length(x)
    sum(c(1, rep(4, p-1)) * (x - c(1, x[-p])^2)^2)
}
# 25-dimensional box constrained: par[24] is *not* at boundary
S <- tnewton(rep(3, 25), flb, lower=rep(2, 25), upper=rep(4, 25),
                nl.info = TRUE, control = list(xtol_rel=1e-8))
## Optimal value of objective function:  368.105912874334 
## Optimal value of controls: 2  ...  2  2.109093  4
}
