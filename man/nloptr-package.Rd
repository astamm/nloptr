\name{nloptr-package}
\alias{nloptr-package}
\docType{package}
\title{
R interface to NLopt
}
\description{
nloptr is an R interface to NLopt, a free/open-source library for nonlinear optimization started by Steven G. Johnson, 
providing a common interface for a number of different free optimization routines available online as well as original 
implementations of various other algorithms. The NLopt library is available under the GNU Lesser General Public License (LGPL), 
and the copyrights are owned by a variety of authors. Most of the information here has been taken from \href{http://ab-initio.mit.edu/nlopt}{the NLopt website}, where more details are available.

NLopt addresses general nonlinear optimization problems of the form:

   min     f(x)
x in R^n

s.t.       g(x) <= 0
           h(x)  = 0
           lb   <= x <= ub
    
where f is the objective function to be minimized and x represents the n optimization parameters. This problem may optionally be subject to the 
bound constraints (also called box constraints), lb and ub. For partially or totally unconstrained problems the bounds can take 
-Inf or Inf. One may also optionally have m nonlinear inequality constraints (sometimes called a nonlinear programming problem), 
which can be specified in g(x), and equality constraints that can be specified in h(x). Note that not all of the algorithms in NLopt can handle constraints.

An optimization problem can be solved with the general nloptr interface, or using one of the wrapper functions for the separate algorithms; auglag, bobyqa, cobyla, crs2lm, direct, lbfgs, mlsl, mma, neldermead, newuoa, sbplx, slsqp, stogo, tnewton, varmetric.
}
\details{
\tabular{ll}{
Package: \tab nloptr\cr
Type: \tab Package\cr
Version: \tab 0.9.9\cr
Date: \tab 2013-11-22\cr
License: \tab L-GPL\cr
LazyLoad: \tab yes\cr
}
}
\author{
Steven G. Johnson and others (C code)  \cr
Jelmer Ypma (R interface) \cr
Hans W. Borchers (wrappers)
}
\references{
Steven G. Johnson, The NLopt nonlinear-optimization package, \url{http://ab-initio.mit.edu/nlopt}
}
\keyword{ optimize }
\keyword{ interface }
\seealso{
\code{\link{optim}}
\code{\link{nlm}}
\code{\link{nlminb}}
\code{\link[Rsolnp:Rsolnp-package]{Rsolnp}}
\code{\link[Rsolnp:solnp]{ssolnp}}
\code{\link{nloptr}}
\code{\link{auglag}}
\code{\link{bobyqa}}
\code{\link{cobyla}}
\code{\link{crs2lm}}
\code{\link{direct}}
\code{\link{isres}}
\code{\link{lbfgs}}
\code{\link{mlsl}}
\code{\link{mma}}
\code{\link{neldermead}}
\code{\link{newuoa}}
\code{\link{sbplx}}
\code{\link{slsqp}}
\code{\link{stogo}}
\code{\link{tnewton}}
\code{\link{varmetric}}
}
\note{See ?nloptr for more examples.}
\examples{
# Example problem, number 71 from the Hock-Schittkowsky test suite.
#
# \min_{x} x1*x4*(x1 + x2 + x3) + x3
# s.t.
#    x1*x2*x3*x4 >= 25
#    x1^2 + x2^2 + x3^2 + x4^2 = 40
#    1 <= x1,x2,x3,x4 <= 5
# 
# we re-write the inequality as
#   25 - x1*x2*x3*x4 <= 0
#
# and the equality as
#   x1^2 + x2^2 + x3^2 + x4^2 - 40 = 0
#
# x0 = (1,5,5,1)
#
# optimal solution = (1.00000000, 4.74299963, 3.82114998, 1.37940829)


library('nloptr')

#
# f(x) = x1*x4*(x1 + x2 + x3) + x3
#
eval_f <- function( x ) { 
    return( list( "objective" = x[1]*x[4]*(x[1] + x[2] + x[3]) + x[3],
                  "gradient" = c( x[1] * x[4] + x[4] * (x[1] + x[2] + x[3]),
                                  x[1] * x[4],
                                  x[1] * x[4] + 1.0,
                                  x[1] * (x[1] + x[2] + x[3]) ) ) ) 
}

# constraint functions
# inequalities
eval_g_ineq <- function( x ) {
    constr <- c( 25 - x[1] * x[2] * x[3] * x[4] )
                 
    grad   <- c( -x[2]*x[3]*x[4],                       
                 -x[1]*x[3]*x[4],
                 -x[1]*x[2]*x[4],
                 -x[1]*x[2]*x[3] )
    return( list( "constraints"=constr, "jacobian"=grad ) )
}

# equalities
eval_g_eq <- function( x ) {
    constr <- c( x[1]^2 + x[2]^2 + x[3]^2 + x[4]^2 - 40 )
                 
    grad   <- c(  2.0*x[1],
                  2.0*x[2],
                  2.0*x[3],
                  2.0*x[4] )
    return( list( "constraints"=constr, "jacobian"=grad ) )
}

# initial values
x0 <- c( 1, 5, 5, 1 )

# lower and upper bounds of control
lb <- c( 1, 1, 1, 1 )
ub <- c( 5, 5, 5, 5 )


local_opts <- list( "algorithm" = "NLOPT_LD_MMA",
                    "xtol_rel"  = 1.0e-7 )
opts <- list( "algorithm" = "NLOPT_LD_AUGLAG",
              "xtol_rel"  = 1.0e-7,
              "maxeval"   = 1000,
              "local_opts" = local_opts )

res <- nloptr( x0=x0, 
               eval_f=eval_f, 
               lb=lb, 
               ub=ub, 
               eval_g_ineq=eval_g_ineq, 
               eval_g_eq=eval_g_eq, 
               opts=opts)               
print( res )
}
