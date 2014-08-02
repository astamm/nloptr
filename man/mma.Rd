\name{mma}
\alias{mma}
\title{
  Method of Moving Asymptotes
}
\description{
  Globally-convergent method-of-moving-asymptotes (MMA) algorithm for
  gradient-based local optimization, including nonlinear inequality
  constraints (but not equality constraints).
}
\usage{
mma(x0, fn, gr = NULL, lower = NULL, upper = NULL,
        hin = NULL, hinjac = NULL,
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
  \item{nl.info}{logical; shall the original NLopt info been shown.}
  \item{control}{list of options, see \code{nl.opts} for help.}
  \item{\ldots}{additional arguments passed to the function.}
}
\details{
  This is an improved CCSA ("conservative convex separable approximation")
  variant of the original MMA algorithm published by Svanberg in 1987, which
  has become popular for topology optimization. Note: 
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
  Krister Svanberg, ``A class of globally convergent optimization methods
  based on conservative convex separable approximations,''
  SIAM J. Optim. 12 (2), p. 555-573 (2002).
}
\note{
  ``Globally convergent'' does not mean that this algorithm converges to the
  global optimum; it means that it is guaranteed to converge to some local
  minimum from any feasible starting point.
}
\seealso{
  \code{\link{slsqp}}
}
\examples{
##  Solve the Hock-Schittkowski problem no. 100 with analytic gradients
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
gr.hs100 <- function(x) {
   c(  2 * x[1] -  20,
      10 * x[2] - 120,
       4 * x[3]^3,
       6 * x[4] - 66,
      60 * x[5]^5,
      14 * x[6]   - 4 * x[7] - 10,
       4 * x[7]^3 - 4 * x[6] -  8 )}
hinjac.hs100 <- function(x) {
    matrix(c(4*x[1], 12*x[2]^3, 1, 8*x[4], 5, 0, 0,
        7, 3, 20*x[3], 1, -1, 0, 0,
        23, 2*x[2], 0, 0, 0, 12*x[6], -8,
        8*x[1]-3*x[2], 2*x[2]-3*x[1], 4*x[3], 0, 0, 5, -11), 4, 7, byrow=TRUE)
}

# incorrect result with exact jacobian
S <- mma(x0.hs100, fn.hs100, gr = gr.hs100,
            hin = hin.hs100, hinjac = hinjac.hs100,
            nl.info = TRUE, control = list(xtol_rel = 1e-8))

# correct result with inexact jacobian
S <- mma(x0.hs100, fn.hs100, hin = hin.hs100,
            nl.info = TRUE, control = list(xtol_rel = 1e-8))
}
