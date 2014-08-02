\name{slsqp}
\alias{slsqp}
\title{
  Sequential Quadratic Programming (SQP)
}
\description{
  Sequential (least-squares) quadratic programming (SQP) algorithm for
  nonlinearly constrained, gradient-based optimization, supporting both
  equality and inequality constraints.
}
\usage{
slsqp(x0, fn, gr = NULL, lower = NULL, upper = NULL,
      hin = NULL, hinjac = NULL, heq = NULL, heqjac = NULL,
      nl.info = FALSE, control = list(), ...)
}
\arguments{
  \item{x0}{starting point for searching the optimum.}
  \item{fn}{objective function that is to be minimized.}
  \item{gr}{gradient of function \code{fn};
            will be calculated numerically if not specified.}
  \item{lower, upper}{lower and upper bound constraints.}
  \item{hin}{function defining the inequality constraints, that is
             \code{hin>=0} for all components.}
  \item{hinjac}{Jacobian of function \code{hin};
                will be calculated numerically if not specified.}
  \item{heq}{function defining the equality constraints, that is
             \code{heq==0} for all components.}
  \item{heqjac}{Jacobian of function \code{heq};
                will be calculated numerically if not specified.}
  \item{nl.info}{logical; shall the original NLopt info been shown.}
  \item{control}{list of options, see \code{nl.opts} for help.}
  \item{\ldots}{additional arguments passed to the function.}
}
\details{
  The algorithm optimizes successive second-order (quadratic/least-squares)
  approximations of the objective function (via BFGS updates),
  with first-order (affine) approximations of the constraints.
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
  Dieter Kraft, ``A software package for sequential quadratic programming'',
  Technical Report DFVLR-FB 88-28, Institut fuer Dynamik der Flugsysteme,
  Oberpfaffenhofen, July 1988.
}
\note{
  See more infos at
  \url{http://ab-initio.mit.edu/wiki/index.php/NLopt_Algorithms}.
}
\seealso{
  \code{alabama::auglag}, \code{Rsolnp::solnp}, \code{Rdonlp2::donlp2}
}
\examples{
##  Solve the Hock-Schittkowski problem no. 100
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

S <- slsqp(x0.hs100, fn = fn.hs100,     # no gradients and jacobians provided
           hin = hin.hs100,
           control = list(xtol_rel = 1e-8, check_derivatives = TRUE))
S
## Optimal value of objective function:  690.622270249131   *** WRONG ***

# Even the numerical derivatives seem to be too tight.
# Let's try with a less accurate jacobian.

hinjac.hs100 <- function(x) nl.jacobian(x, hin.hs100, heps = 1e-2)
S <- slsqp(x0.hs100, fn = fn.hs100,
           hin = hin.hs100, hinjac = hinjac.hs100, 
           control = list(xtol_rel = 1e-8))
S
## Optimal value of objective function:  680.630057392593   *** CORRECT ***
}
