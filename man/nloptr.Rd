\name{nloptr}
\alias{nloptr}
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
}
\usage{
nloptr( x0, 
        eval_f, 
        eval_grad_f = NULL,
        lb = NULL, 
        ub = NULL, 
        eval_g_ineq = NULL, 
        eval_jac_g_ineq = NULL,
        eval_g_eq = NULL, 
        eval_jac_g_eq = NULL,
        opts = list(),
        ... )
}

%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x0}{
    vector with starting values for the optimization.
}
  \item{eval_f}{
    function that returns the value of the objective function. It can also return gradient 
    information at the same time in a list with elements "objective" and "gradient" (see below for an example).
}
  \item{eval_grad_f}{
    function that returns the value of the gradient of the objective function. Not all of the algorithms require a gradient.
}
  \item{lb}{
    vector with lower bounds of the controls (use -Inf for controls without lower bound), by default there are no lower bounds for any of the controls.
}
  \item{ub}{
    vector with upper bounds of the controls (use  Inf for controls without upper bound), by default there are no upper bounds for any of the controls.
}
  \item{eval_g_ineq}{
    function to evaluate (non-)linear inequality constraints that should hold in the solution. 
    It can also return gradient information at the same time in a list with elements 
    "objective" and "jacobian" (see below for an example).
}
  \item{eval_jac_g_ineq}{
    function to evaluate the jacobian of the (non-)linear inequality constraints that should hold 
    in the solution.
}
  \item{eval_g_eq}{
    function to evaluate (non-)linear equality constraints that should hold in the solution. 
    It can also return gradient information at the same time in a list with elements 
    "objective" and "jacobian" (see below for an example).
}
  \item{eval_jac_g_eq}{
    function to evaluate the jacobian of the (non-)linear equality constraints that should hold 
    in the solution.
}
  \item{opts}{
    list with options. The option "algorithm" is required. Check the
    \href{http://ab-initio.mit.edu/wiki/index.php/NLopt_Algorithms}{NLopt website} for a full list 
    of available algorithms. Other options control the termination conditions (minf_max, ftol_rel, 
    ftol_abs, xtol_rel, xtol_abs, maxeval, maxtime). Default is xtol_rel = 1e-4. More information
    \href{http://ab-initio.mit.edu/wiki/index.php/NLopt_Introduction\#Termination_conditions}{here}.
	A full description of all options is shown by the function \code{nloptr.print.options()}.
    
    Some algorithms with equality constraints require the option local_opts, which contains a list with 
    an algorithm and a termination condition for the local algorithm. See ?`nloptr-package` for an example.
    
    The option print_level controls how much output is shown during the optimization process. Possible values: 
    \tabular{ll}{
        0 (default) \tab no output \cr
        1 \tab show iteration number and value of objective function \cr
        2 \tab 1 + show value of (in)equalities \cr
        3 \tab 2 + show value of controls
    }
	
	The option check_derivatives (default = FALSE) can be used to run to compare the analytic gradients with finite difference approximations. 
	The option check_derivatives_print ('all' (default), 'errors', 'none') controls the output of the derivative checker, if it is run, showing all comparisons, only those that resulted in an error, or none.
	The option check_derivatives_tol (default = 1e-04), determines when a difference between an analytic gradient and its finite difference approximation is flagged as an error.
  }
  \item{...}{
    arguments that will be passed to the user-defined objective and constraints functions.
  }
}
\value{
    The return value contains a list with the inputs, and additional elements
    \item{call}{the call that was made to solve}
    \item{status}{integer value with the status of the optimization (0 is success)}
    \item{message}{more informative message with the status of the optimization}
    \item{iterations}{number of iterations that were executed}
    \item{objective}{value if the objective function in the solution}
    \item{solution}{optimal value of the controls}
    \item{version}{version op NLopt that was used}
}
\references{
Steven G. Johnson, The NLopt nonlinear-optimization package, \url{http://ab-initio.mit.edu/nlopt}
}
\author{
Steven G. Johnson and others (C code) \cr
Jelmer Ypma (R interface)
}
\seealso{
\code{\link[nloptr:nloptr.print.options]{nloptr.print.options}}
\code{\link[nloptr:check.derivatives]{check.derivatives}}
\code{\link{optim}}
\code{\link{nlm}}
\code{\link{nlminb}}
\code{\link[Rsolnp:Rsolnp-package]{Rsolnp}}
\code{\link[Rsolnp:solnp]{ssolnp}}
}
\note{See ?`nloptr-package` for an extended example.}
\examples{
library('nloptr')

## Rosenbrock Banana function and gradient in separate functions
eval_f <- function(x) {
    return( 100 * (x[2] - x[1] * x[1])^2 + (1 - x[1])^2 )
}

eval_grad_f <- function(x) {
    return( c( -400 * x[1] * (x[2] - x[1] * x[1]) - 2 * (1 - x[1]),
                200 * (x[2] - x[1] * x[1])) )
}


# initial values
x0 <- c( -1.2, 1 )

opts <- list("algorithm"="NLOPT_LD_LBFGS",
             "xtol_rel"=1.0e-8)
 
# solve Rosenbrock Banana function
res <- nloptr( x0=x0, 
               eval_f=eval_f, 
               eval_grad_f=eval_grad_f,
               opts=opts)
print( res )               

               
## Rosenbrock Banana function and gradient in one function
# this can be used to economize on calculations
eval_f_list <- function(x) {
    return( list( "objective" = 100 * (x[2] - x[1] * x[1])^2 + (1 - x[1])^2,
                  "gradient"  = c( -400 * x[1] * (x[2] - x[1] * x[1]) - 2 * (1 - x[1]),
                                    200 * (x[2] - x[1] * x[1])) ) )
}
               
# solve Rosenbrock Banana function using an objective function that
# returns a list with the objective value and its gradient               
res <- nloptr( x0=x0, 
               eval_f=eval_f_list,
               opts=opts)
print( res )



# Example showing how to solve the problem from the NLopt tutorial.
#
# min sqrt( x2 )
# s.t. x2 >= 0
#      x2 >= ( a1*x1 + b1 )^3
#      x2 >= ( a2*x1 + b2 )^3
# where
# a1 = 2, b1 = 0, a2 = -1, b2 = 1
#
# re-formulate constraints to be of form g(x) <= 0
#      ( a1*x1 + b1 )^3 - x2 <= 0
#      ( a2*x1 + b2 )^3 - x2 <= 0

library('nloptr')


# objective function
eval_f0 <- function( x, a, b ){ 
    return( sqrt(x[2]) )
}

# constraint function
eval_g0 <- function( x, a, b ) {
    return( (a*x[1] + b)^3 - x[2] )
}

# gradient of objective function
eval_grad_f0 <- function( x, a, b ){ 
    return( c( 0, .5/sqrt(x[2]) ) )
}

# jacobian of constraint
eval_jac_g0 <- function( x, a, b ) {
    return( rbind( c( 3*a[1]*(a[1]*x[1] + b[1])^2, -1.0 ), 
                   c( 3*a[2]*(a[2]*x[1] + b[2])^2, -1.0 ) ) )
}


# functions with gradients in objective and constraint function
# this can be useful if the same calculations are needed for
# the function value and the gradient
eval_f1 <- function( x, a, b ){ 
    return( list("objective"=sqrt(x[2]), 
                 "gradient"=c(0,.5/sqrt(x[2])) ) )
}

eval_g1 <- function( x, a, b ) {
    return( list( "constraints"=(a*x[1] + b)^3 - x[2],
                  "jacobian"=rbind( c( 3*a[1]*(a[1]*x[1] + b[1])^2, -1.0 ), 
                                    c( 3*a[2]*(a[2]*x[1] + b[2])^2, -1.0 ) ) ) )
}


# define parameters
a <- c(2,-1)
b <- c(0, 1)

# Solve using NLOPT_LD_MMA with gradient information supplied in separate function
res0 <- nloptr( x0=c(1.234,5.678), 
                eval_f=eval_f0, 
                eval_grad_f=eval_grad_f0,
                lb = c(-Inf,0), 
                ub = c(Inf,Inf), 
                eval_g_ineq = eval_g0,
                eval_jac_g_ineq = eval_jac_g0,                
                opts = list("algorithm"="NLOPT_LD_MMA"),
                a = a, 
                b = b )
print( res0 )
        
# Solve using NLOPT_LN_COBYLA without gradient information
res1 <- nloptr( x0=c(1.234,5.678), 
                eval_f=eval_f0, 
                lb = c(-Inf,0), 
                ub = c(Inf,Inf), 
                eval_g_ineq = eval_g0, 
                opts = list("algorithm"="NLOPT_LN_COBYLA"),
                a = a, 
                b = b )
print( res1 )


# Solve using NLOPT_LD_MMA with gradient information in objective function
res2 <- nloptr( x0=c(1.234,5.678), 
                eval_f=eval_f1, 
                lb = c(-Inf,0), 
                ub = c(Inf,Inf), 
                eval_g_ineq = eval_g1, 
                opts = list("algorithm"="NLOPT_LD_MMA", "check_derivatives"=TRUE),
                a = a,
                b = b )
print( res2 )

}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ optimize }
\keyword{ interface }

