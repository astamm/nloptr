\name{auglag}
\alias{auglag}
\title{
  Augmented Lagrangian Algorithm
}
\description{
  The Augmented Lagrangian method adds additional terms to the unconstrained
  objective function, designed to emulate a Lagrangian multiplier.
}
\usage{
auglag(x0, fn, gr = NULL, lower = NULL, upper = NULL,
            hin = NULL, hinjac = NULL, heq = NULL, heqjac = NULL,
            localsolver = c("COBYLA"), localtol = 1e-6, ineq2local = FALSE,
            nl.info = FALSE, control = list(), ...)
}
\arguments{
  \item{x0}{starting point for searching the optimum.}
  \item{fn}{objective function that is to be minimized.}
  \item{gr}{gradient of the objective function; will be provided provided 
            is \code{NULL} and the solver requires derivatives.}
  \item{lower, upper}{lower and upper bound constraints.}
  \item{hin, hinjac}{defines the inequalty constraints, \code{hin(x) >= 0}}
  \item{heq, heqjac}{defines the equality constraints, \code{heq(x) = 0}.}
  \item{localsolver}{available local solvers: COBYLA, LBFGS, MMA, or SLSQP.}
  \item{localtol}{tolerance applied in the selected local solver.}
  \item{ineq2local}{logical; shall the inequality constraints be treated
                    by the local solver?; not possible at the moment.}
  \item{nl.info}{logical; shall the original NLopt info been shown.}
  \item{control}{list of options, see \code{nl.opts} for help.}
  \item{\ldots}{additional arguments passed to the function.}
}
\details{
  This method combines the objective function and the nonlinear 
  inequality/equality constraints (if any) in to a single function: 
  essentially, the objective plus a `penalty' for any violated constraints.

  This modified objective function is then passed to another optimization 
  algorithm with no nonlinear constraints. If the constraints are violated 
  by the solution of this sub-problem, then the size of the penalties is 
  increased and the process is repeated; eventually, the process must 
  converge to the desired solution (if it exists).

  Since all of the actual optimization is performed in this subsidiary 
  optimizer, the subsidiary algorithm that you specify determines whether 
  the optimization is gradient-based or derivative-free.

  The local solvers available at the moment are ``COBYLA'' (for the
  derivative-free approach) and ``LBFGS'', ``MMA'', or ``SLSQP'' (for 
  smooth functions). The tolerance for the local solver has to be provided.

  There is a variant that only uses penalty functions for equality constraints 
  while inequality constraints are passed through to the subsidiary algorithm 
  to be handled directly; in this case, the subsidiary algorithm must handle 
  inequality constraints.  
  (At the moment, this variant has been turned off because of problems with
  the NLOPT library.)
}
\value{
List with components:
  \item{par}{the optimal solution found so far.}
  \item{value}{the function value corresponding to \code{par}.}
  \item{iter}{number of (outer) iterations, see \code{maxeval}.}
  \item{global_solver}{the global NLOPT solver used.}
  \item{local_solver}{the local NLOPT solver used, LBFGS or COBYLA.}
  \item{convergence}{integer code indicating successful completion (> 0)
                     or a possible error number (< 0).}
  \item{message}{character string produced by NLopt and giving additional
                 information.}
}
\references{
  Andrew R. Conn, Nicholas I. M. Gould, and Philippe L. Toint, ``A globally 
  convergent augmented Lagrangian algorithm for optimization with general 
  constraints and simple bounds,''
  SIAM J. Numer. Anal. vol. 28, no. 2, p. 545-572 (1991).

  E. G. Birgin and J. M. Martinez, ``Improving ultimate convergence of an 
  augmented Lagrangian method,"
  Optimization Methods and Software vol. 23, no. 2, p. 177-195 (2008).
}
\note{
  Birgin and Martinez provide their own free implementation of the method as
  part of the TANGO project; other implementations can be found in semi-free
  packages like LANCELOT.
}
\seealso{
  \code{alabama::auglag}, \code{Rsolnp::solnp}
}
\examples{
x0 <- c(1, 1)
fn <- function(x) (x[1]-2)^2 + (x[2]-1)^2
hin <- function(x) -0.25*x[1]^2 - x[2]^2 + 1    # hin >= 0
heq <- function(x) x[1] - 2*x[2] + 1            # heq == 0
gr <- function(x) nl.grad(x, fn)
hinjac <- function(x) nl.jacobian(x, hin)
heqjac <- function(x) nl.jacobian(x, heq)

auglag(x0, fn, gr = NULL, hin = hin, heq = heq) # with COBYLA
# $par:     0.8228761 0.9114382
# $value:   1.393464
# $iter:    1001

auglag(x0, fn, gr = NULL, hin = hin, heq = heq, localsolver = "SLSQP")
# $par:     0.8228757 0.9114378
# $value:   1.393465
# $iter     173

##  Example from the alabama::auglag help page
fn <- function(x) (x[1] + 3*x[2] + x[3])^2 + 4 * (x[1] - x[2])^2
heq <- function(x) x[1] + x[2] + x[3] - 1
hin <- function(x) c(6*x[2] + 4*x[3] - x[1]^3 - 3, x[1], x[2], x[3])

auglag(runif(3), fn, hin = hin, heq = heq, localsolver="lbfgs")
# $par:     2.380000e-09 1.086082e-14 1.000000e+00
# $value:   1
# $iter:    289

##  Powell problem from the Rsolnp::solnp help page
x0 <- c(-2, 2, 2, -1, -1)
fn1  <- function(x) exp(x[1]*x[2]*x[3]*x[4]*x[5])
eqn1 <-function(x)
	c(x[1]*x[1]+x[2]*x[2]+x[3]*x[3]+x[4]*x[4]+x[5]*x[5],
	  x[2]*x[3]-5*x[4]*x[5],
	  x[1]*x[1]*x[1]+x[2]*x[2]*x[2])

auglag(x0, fn1, heq = eqn1, localsolver = "mma")
# $par: -3.988458e-10 -1.654201e-08 -3.752028e-10  8.904445e-10  8.926336e-10
# $value:   1
# $iter:    1001
}
