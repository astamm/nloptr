\name{grad, jacobian}
\alias{nl.grad}
\alias{nl.jacobian}
\title{
  Numerical Gradients and Jacobians
}
\description{
  Provides numerical gradients and jacobians.
}
\usage{
nl.grad(x0, fn, heps = .Machine$double.eps^(1/3), ...)
nl.jacobian(x0, fn, heps = .Machine$double.eps^(1/3), ...)
}
\arguments{
  \item{x0}{point as a vector where the gradient is to be calculated.}
  \item{fn}{scalar function of one or several variables.}
  \item{heps}{step size to be used.}
  \item{\dots}{additional arguments passed to the function.}
}
\details{
  Both functions apply the ``central difference formula'' with step size
  as recommended in the literature.
}
\value{
  \code{grad} returns the gradient as a vector; \code{jacobian} returns the
  Jacobian as a matrix of usual dimensions.
}
\examples{
  fn1 <- function(x) sum(x^2)
  nl.grad(seq(0, 1, by = 0.2), fn1)
  ## [1] 0.0  0.4  0.8  1.2  1.6  2.0
  nl.grad(rep(1, 5), fn1)
  ## [1] 2  2  2  2  2

  fn2 <- function(x) c(sin(x), cos(x))
  x <- (0:1)*2*pi
  nl.jacobian(x, fn2)
  ##      [,1] [,2]
  ## [1,]    1    0
  ## [2,]    0    1
  ## [3,]    0    0
  ## [4,]    0    0
}
