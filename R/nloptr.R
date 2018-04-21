# Copyright (C) 2010 Jelmer Ypma. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   nloptr.R
# Author: Jelmer Ypma
# Date:   9 June 2010
#
# Input:
#        x0 : vector with initial values
#        eval_f : function to evaluate objective function (and optionally its gradient)
#        eval_grad_f : function evaluate the gradient of the objective function (optional)
#        lb : lower bounds of the control (optional)
#        ub : upper bounds of the control (optional)
#        eval_g_ineq : function to evaluate (non-)linear inequality constraints that should
#                      hold in the solution and its jacobian (optional)
#        eval_jac_g_ineq : function to evaluate jacobian of the (non-)linear inequality constraints (optional)
#        eval_g_eq : function to evaluate (non-)linear equality constraints that should hold
#                    in the solution and its jacobian (optional)
#        eval_jac_g_eq : function to evaluate jacobian of the (non-)linear equality constraints (optional)
#        opts : list with options that are passed to Ipopt
#        ... : arguments that are passed to user-defined functions
#
# Output: structure with inputs and
#        call : the call that was made to solve
#        status : integer value with the status of the optimization (0 is success)
#        message : more informative message with the status of the optimization
#        iterations : number of iterations that were executed
#        objective : value if the objective function in the solution
#        solution : optimal value of the controls
#
# CHANGELOG:
#   13/01/2011: added print_level option
#   24/07/2011: added finite difference gradient checker
#   07/08/2011: moved addition of default options to separate function
#               show documentation of options if print_options_doc == TRUE
#   05/05/2014: Replaced cat by message, so messages can now be suppressed by suppressMessages.
#   22/03/2015: Added while-loop around solve statement. This should solve the problem that NLopt sometimes exits with NLOPT_MAXTIME_REACHED when no maxtime was set in the options.



#' R interface to NLopt
#'
#' nloptr is an R interface to NLopt, a free/open-source library for nonlinear
#' optimization started by Steven G. Johnson, providing a common interface for
#' a number of different free optimization routines available online as well as
#' original implementations of various other algorithms. The NLopt library is
#' available under the GNU Lesser General Public License (LGPL), and the
#' copyrights are owned by a variety of authors. Most of the information here
#' has been taken from \href{http://ab-initio.mit.edu/nlopt}{the NLopt website},
#' where more details are available.
#'
#' NLopt addresses general nonlinear optimization problems of the form:
#'
#' min f(x) x in R^n
#'
#' s.t.  g(x) <= 0 h(x) = 0 lb <= x <= ub
#'
#' where f is the objective function to be minimized and x represents the n
#' optimization parameters. This problem may optionally be subject to the bound
#' constraints (also called box constraints), lb and ub. For partially or
#' totally unconstrained problems the bounds can take -Inf or Inf. One may also
#' optionally have m nonlinear inequality constraints (sometimes called a
#' nonlinear programming problem), which can be specified in g(x), and equality
#' constraints that can be specified in h(x). Note that not all of the
#' algorithms in NLopt can handle constraints.
#'
#' @param x0 vector with starting values for the optimization.
#' @param eval_f function that returns the value of the objective function. It
#' can also return gradient information at the same time in a list with
#' elements "objective" and "gradient" (see below for an example).
#' @param eval_grad_f function that returns the value of the gradient of the
#' objective function. Not all of the algorithms require a gradient.
#' @param lb vector with lower bounds of the controls (use -Inf for controls
#' without lower bound), by default there are no lower bounds for any of the
#' controls.
#' @param ub vector with upper bounds of the controls (use Inf for controls
#' without upper bound), by default there are no upper bounds for any of the
#' controls.
#' @param eval_g_ineq function to evaluate (non-)linear inequality constraints
#' that should hold in the solution.  It can also return gradient information
#' at the same time in a list with elements "objective" and "jacobian" (see
#' below for an example).
#' @param eval_jac_g_ineq function to evaluate the jacobian of the (non-)linear
#' inequality constraints that should hold in the solution.
#' @param eval_g_eq function to evaluate (non-)linear equality constraints that
#' should hold in the solution.  It can also return gradient information at the
#' same time in a list with elements "objective" and "jacobian" (see below for
#' an example).
#' @param eval_jac_g_eq function to evaluate the jacobian of the (non-)linear
#' equality constraints that should hold in the solution.
#' @param opts list with options. The option "algorithm" is required. Check the
#' \href{http://ab-initio.mit.edu/wiki/index.php/NLopt_Algorithms}{NLopt website}
#' for a full list of available algorithms. Other options control the
#' termination conditions (minf_max, ftol_rel, ftol_abs, xtol_rel, xtol_abs,
#' maxeval, maxtime). Default is xtol_rel = 1e-4. More information
#' \href{http://ab-initio.mit.edu/wiki/index.php/NLopt_Introduction\#Termination_conditions}{here}.
#' A full description of all options is shown by the function
#' \code{nloptr.print.options()}.
#'
#' Some algorithms with equality constraints require the option local_opts,
#' which contains a list with an algorithm and a termination condition for the
#' local algorithm. See ?`nloptr-package` for an example.
#'
#' The option print_level controls how much output is shown during the
#' optimization process. Possible values: \tabular{ll}{ 0 (default) \tab no
#' output \cr 1 \tab show iteration number and value of objective function \cr
#' 2 \tab 1 + show value of (in)equalities \cr 3 \tab 2 + show value of
#' controls }
#'
#' The option check_derivatives (default = FALSE) can be used to run to compare
#' the analytic gradients with finite difference approximations.  The option
#' check_derivatives_print ('all' (default), 'errors', 'none') controls the
#' output of the derivative checker, if it is run, showing all comparisons,
#' only those that resulted in an error, or none.  The option
#' check_derivatives_tol (default = 1e-04), determines when a difference
#' between an analytic gradient and its finite difference approximation is
#' flagged as an error.
#'
#' @param ...  arguments that will be passed to the user-defined objective and
#' constraints functions.
#'
#' @return The return value contains a list with the inputs, and additional
#' elements
#'   \item{call}{the call that was made to solve}
#'   \item{status}{integer value with the status of the optimization (0 is
#'     success)}
#' \item{message}{more informative message with the status of the optimization}
#' \item{iterations}{number of iterations that were executed}
#' \item{objective}{value if the objective function in the solution}
#' \item{solution}{optimal value of the controls}
#' \item{version}{version of NLopt that was used}
#'
#' @export nloptr
#'
#' @author Steven G. Johnson and others (C code) \cr Jelmer Ypma (R interface)
#'
#' @note See ?`nloptr-package` for an extended example.
#'
#' @seealso
#'   \code{\link[nloptr:nloptr.print.options]{nloptr.print.options}}
#'   \code{\link[nloptr:check.derivatives]{check.derivatives}}
#'   \code{\link{optim}}
#'   \code{\link{nlm}}
#'   \code{\link{nlminb}}
#'   \code{Rsolnp::Rsolnp}
#'   \code{Rsolnp::solnp}
#'
#' @references Steven G. Johnson, The NLopt nonlinear-optimization package,
#' \url{http://ab-initio.mit.edu/nlopt}
#'
#' @keywords optimize interface
#'
#' @examples
#'
#' library('nloptr')
#'
#' ## Rosenbrock Banana function and gradient in separate functions
#' eval_f <- function(x) {
#'     return( 100 * (x[2] - x[1] * x[1])^2 + (1 - x[1])^2 )
#' }
#'
#' eval_grad_f <- function(x) {
#'     return( c( -400 * x[1] * (x[2] - x[1] * x[1]) - 2 * (1 - x[1]),
#'                 200 * (x[2] - x[1] * x[1])) )
#' }
#'
#'
#' # initial values
#' x0 <- c( -1.2, 1 )
#'
#' opts <- list("algorithm"="NLOPT_LD_LBFGS",
#'              "xtol_rel"=1.0e-8)
#'
#' # solve Rosenbrock Banana function
#' res <- nloptr( x0=x0,
#'                eval_f=eval_f,
#'                eval_grad_f=eval_grad_f,
#'                opts=opts)
#' print( res )
#'
#'
#' ## Rosenbrock Banana function and gradient in one function
#' # this can be used to economize on calculations
#' eval_f_list <- function(x) {
#'     return( list( "objective" = 100 * (x[2] - x[1] * x[1])^2 + (1 - x[1])^2,
#'                   "gradient"  = c( -400 * x[1] * (x[2] - x[1] * x[1]) - 2 * (1 - x[1]),
#'                                     200 * (x[2] - x[1] * x[1])) ) )
#' }
#'
#' # solve Rosenbrock Banana function using an objective function that
#' # returns a list with the objective value and its gradient
#' res <- nloptr( x0=x0,
#'                eval_f=eval_f_list,
#'                opts=opts)
#' print( res )
#'
#'
#'
#' # Example showing how to solve the problem from the NLopt tutorial.
#' #
#' # min sqrt( x2 )
#' # s.t. x2 >= 0
#' #      x2 >= ( a1*x1 + b1 )^3
#' #      x2 >= ( a2*x1 + b2 )^3
#' # where
#' # a1 = 2, b1 = 0, a2 = -1, b2 = 1
#' #
#' # re-formulate constraints to be of form g(x) <= 0
#' #      ( a1*x1 + b1 )^3 - x2 <= 0
#' #      ( a2*x1 + b2 )^3 - x2 <= 0
#'
#' library('nloptr')
#'
#'
#' # objective function
#' eval_f0 <- function( x, a, b ){
#'     return( sqrt(x[2]) )
#' }
#'
#' # constraint function
#' eval_g0 <- function( x, a, b ) {
#'     return( (a*x[1] + b)^3 - x[2] )
#' }
#'
#' # gradient of objective function
#' eval_grad_f0 <- function( x, a, b ){
#'     return( c( 0, .5/sqrt(x[2]) ) )
#' }
#'
#' # jacobian of constraint
#' eval_jac_g0 <- function( x, a, b ) {
#'     return( rbind( c( 3*a[1]*(a[1]*x[1] + b[1])^2, -1.0 ),
#'                    c( 3*a[2]*(a[2]*x[1] + b[2])^2, -1.0 ) ) )
#' }
#'
#'
#' # functions with gradients in objective and constraint function
#' # this can be useful if the same calculations are needed for
#' # the function value and the gradient
#' eval_f1 <- function( x, a, b ){
#'     return( list("objective"=sqrt(x[2]),
#'                  "gradient"=c(0,.5/sqrt(x[2])) ) )
#' }
#'
#' eval_g1 <- function( x, a, b ) {
#'     return( list( "constraints"=(a*x[1] + b)^3 - x[2],
#'                   "jacobian"=rbind( c( 3*a[1]*(a[1]*x[1] + b[1])^2, -1.0 ),
#'                                     c( 3*a[2]*(a[2]*x[1] + b[2])^2, -1.0 ) ) ) )
#' }
#'
#'
#' # define parameters
#' a <- c(2,-1)
#' b <- c(0, 1)
#'
#' # Solve using NLOPT_LD_MMA with gradient information supplied in separate function
#' res0 <- nloptr( x0=c(1.234,5.678),
#'                 eval_f=eval_f0,
#'                 eval_grad_f=eval_grad_f0,
#'                 lb = c(-Inf,0),
#'                 ub = c(Inf,Inf),
#'                 eval_g_ineq = eval_g0,
#'                 eval_jac_g_ineq = eval_jac_g0,
#'                 opts = list("algorithm"="NLOPT_LD_MMA"),
#'                 a = a,
#'                 b = b )
#' print( res0 )
#'
#' # Solve using NLOPT_LN_COBYLA without gradient information
#' res1 <- nloptr( x0=c(1.234,5.678),
#'                 eval_f=eval_f0,
#'                 lb = c(-Inf,0),
#'                 ub = c(Inf,Inf),
#'                 eval_g_ineq = eval_g0,
#'                 opts = list("algorithm"="NLOPT_LN_COBYLA"),
#'                 a = a,
#'                 b = b )
#' print( res1 )
#'
#'
#' # Solve using NLOPT_LD_MMA with gradient information in objective function
#' res2 <- nloptr( x0=c(1.234,5.678),
#'                 eval_f=eval_f1,
#'                 lb = c(-Inf,0),
#'                 ub = c(Inf,Inf),
#'                 eval_g_ineq = eval_g1,
#'                 opts = list("algorithm"="NLOPT_LD_MMA", "check_derivatives"=TRUE),
#'                 a = a,
#'                 b = b )
#' print( res2 )
#'
nloptr <-
function( x0,
          eval_f,
          eval_grad_f = NULL,
          lb = NULL,
          ub = NULL,
          eval_g_ineq = NULL,
          eval_jac_g_ineq = NULL,
          eval_g_eq = NULL,
          eval_jac_g_eq = NULL,
          opts = list(),
          ... ) {

    # internal function to check the arguments of the functions
    .checkfunargs = function( fun, arglist, funname ) {
        if( !is.function(fun) ) stop(paste(funname, " must be a function\n", sep = ""))
        flist = formals(fun)
        if ( length(flist) > 1 ) {
            fnms  = names(flist)[2:length(flist)]    # remove first argument, which is x
            rnms  = names(arglist)
            m1 = match(fnms, rnms)
            if( any(is.na(m1)) ){
                mx1 = which( is.na(m1) )
                for( i in 1:length(mx1) ){
                    stop(paste(funname, " requires argument '", fnms[mx1[i]], "' but this has not been passed to the 'nloptr' function.\n", sep = ""))
                }
            }
            m2 = match(rnms, fnms)
            if( any(is.na(m2)) ){
                mx2 = which( is.na(m2) )
                for( i in 1:length(mx2) ){
                    stop(paste(rnms[mx2[i]], "' passed to (...) in 'nloptr' but this is not required in the ", funname, " function.\n", sep = ""))
                }
            }
        }
        return( 0 )
    }


    # extract list of additional arguments and check user-defined functions
    arglist = list(...)
    .checkfunargs( eval_f, arglist, 'eval_f' )
    if( !is.null( eval_grad_f ) ) { .checkfunargs( eval_grad_f, arglist, 'eval_grad_f' ) }
    if( !is.null( eval_g_ineq ) ) { .checkfunargs( eval_g_ineq, arglist, 'eval_g_ineq' ) }
    if( !is.null( eval_jac_g_ineq ) ) { .checkfunargs( eval_jac_g_ineq, arglist, 'eval_jac_g_ineq' ) }
    if( !is.null( eval_g_eq ) ) { .checkfunargs( eval_g_eq, arglist, 'eval_g_eq' ) }
    if( !is.null( eval_jac_g_eq ) ) { .checkfunargs( eval_jac_g_eq, arglist, 'eval_jac_g_eq' ) }

    # define 'infinite' lower and upper bounds of the control if they haven't been set
    if ( is.null( lb ) ) { lb <- rep( -Inf, length(x0) ) }
    if ( is.null( ub ) ) { ub <- rep(  Inf, length(x0) ) }

    # if eval_f does not return a list, write a wrapper function combining eval_f and eval_grad_f
    if ( is.list( eval_f( x0, ... ) ) |
         is.null( eval_grad_f ) ) {

            eval_f_wrapper <- function(x) { eval_f(x, ...) }

    } else {

        eval_f_wrapper <- function( x ) {
            return( list( "objective" = eval_f( x, ... ),
                          "gradient"  = eval_grad_f( x, ... ) ) )
        }
    }

    # change the environment of the inequality constraint functions that we're calling
    num_constraints_ineq <- 0
    if ( !is.null( eval_g_ineq ) ) {

        # if eval_g_ineq does not return a list, write a wrapper function combining eval_g_ineq and eval_jac_g_ineq
        if ( is.list( eval_g_ineq( x0, ... ) ) |
             is.null( eval_jac_g_ineq ) ) {

            eval_g_ineq_wrapper <- function(x) { eval_g_ineq(x, ...) }

        } else {

            eval_g_ineq_wrapper <- function( x ) {
                return( list( "constraints" = eval_g_ineq( x, ... ),
                              "jacobian"  = eval_jac_g_ineq( x, ... ) ) )
            }
        }

        # determine number of constraints
        tmp_constraints <- eval_g_ineq_wrapper( x0 )
        if ( is.list( tmp_constraints ) ) {
            num_constraints_ineq <- length( tmp_constraints$constraints )
        } else {
            num_constraints_ineq <- length( tmp_constraints )
        }

    } else {
        # define dummy function
        eval_g_ineq_wrapper <- NULL
    }


    # change the environment of the equality constraint functions that we're calling
    num_constraints_eq <- 0
    if ( !is.null( eval_g_eq ) ) {

        # if eval_g_eq does not return a list, write a wrapper function combining eval_g_eq and eval_jac_g_eq
        if ( is.list( eval_g_eq( x0, ... ) ) |
             is.null( eval_jac_g_eq ) ) {

            eval_g_eq_wrapper <- function(x) { eval_g_eq(x, ...) }

        } else {

            eval_g_eq_wrapper <- function( x ) {
                return( list( "constraints" = eval_g_eq( x, ... ),
                              "jacobian"  = eval_jac_g_eq( x, ... ) ) )
            }

        }

        # determine number of constraints
        tmp_constraints <- eval_g_eq_wrapper( x0 )
        if ( is.list( tmp_constraints ) ) {
            num_constraints_eq <- length( tmp_constraints$constraints )
        } else {
            num_constraints_eq <- length( tmp_constraints )
        }

    } else {
        # define dummy function
        eval_g_eq_wrapper <- NULL
    }


    # extract local options from list of options if they exist
    if ( "local_opts" %in% names(opts) ) {
        res.opts.add <- nloptr.add.default.options(
                        opts.user                 = opts$local_opts,
                        x0                         = x0,
                        num_constraints_ineq     = num_constraints_ineq,
                        num_constraints_eq         = num_constraints_eq )
        local_opts   <- res.opts.add$opts.user
        opts$local_opts <- NULL
    } else {
        local_opts <- NULL
    }

    # add defaults to list of options
    res.opts.add <- nloptr.add.default.options(
                opts.user                 = opts,
                x0                         = x0,
                num_constraints_ineq     = num_constraints_ineq,
                num_constraints_eq         = num_constraints_eq )
    opts <- res.opts.add$opts.user

    # add the termination criteria to the list
    termination_conditions <- res.opts.add$termination_conditions

    # print description of options if requested
    if (opts$print_options_doc) {
        nloptr.print.options( opts.user = opts )
    }

    # define list with all algorithms
    # nloptr.options.description is a data.frame with options
    # that is loaded when nloptr is loaded.
    nloptr.default.options <- nloptr.get.default.options()
    list_algorithms <-  unlist(
                            strsplit(
                                nloptr.default.options[ nloptr.default.options$name=="algorithm", "possible_values" ],
                                ", "
                            )
                        )

    # run derivative checker
    if ( opts$check_derivatives ) {

        if ( opts$algorithm %in% list_algorithms[ grep( "NLOPT_[G,L]N", list_algorithms ) ] ) {
            warning( paste("Skipping derivative checker because algorithm '", opts$algorithm, "' does not use gradients.", sep='') )
        }
        else {
            # check derivatives of objective function
            message( "Checking gradients of objective function." )
            check.derivatives(
                .x = x0,
                func = function( x ) { eval_f_wrapper( x )$objective },
                func_grad = function( x ) { eval_f_wrapper( x )$gradient },
                check_derivatives_tol = opts$check_derivatives_tol,
                check_derivatives_print = opts$check_derivatives_print,
                func_grad_name = 'eval_grad_f'
            )

            if ( num_constraints_ineq > 0 ) {
                # check derivatives of inequality constraints
                message( "Checking gradients of inequality constraints.\n" )
                check.derivatives(
                    .x = x0,
                    func = function( x ) { eval_g_ineq_wrapper( x )$constraints },
                    func_grad = function( x ) { eval_g_ineq_wrapper( x )$jacobian },
                    check_derivatives_tol = opts$check_derivatives_tol,
                    check_derivatives_print = opts$check_derivatives_print,
                    func_grad_name = 'eval_jac_g_ineq'
                )
            }

            if ( num_constraints_eq > 0 ) {
                # check derivatives of equality constraints
                message( "Checking gradients of equality constraints.\n" )
                check.derivatives(
                    .x = x0,
                    func = function( x ) { eval_g_eq_wrapper( x )$constraints },
                    func_grad = function( x ) { eval_g_eq_wrapper( x )$jacobian },
                    check_derivatives_tol = opts$check_derivatives_tol,
                    check_derivatives_print = opts$check_derivatives_print,
                    func_grad_name = 'eval_jac_g_eq'
                )
            }
        }

    }

    ret <- list( "x0"                   = x0,
                 "eval_f"               = eval_f_wrapper,
                 "lower_bounds"         = lb,
                 "upper_bounds"         = ub,
                 "num_constraints_ineq" = num_constraints_ineq,
                 "eval_g_ineq"          = eval_g_ineq_wrapper,
                 "num_constraints_eq"   = num_constraints_eq,
                 "eval_g_eq"            = eval_g_eq_wrapper,
                 "options"              = opts,
                 "local_options"        = local_opts,
                 "nloptr_environment"   = new.env() )

    attr(ret, "class") <- "nloptr"

    # add the current call to the list
    ret$call <- match.call()

    # add the termination criteria to the list
    ret$termination_conditions <- termination_conditions

    # check whether we have a correctly formed ipoptr object
    is.nloptr( ret )

    # Count the number of times that we try to solve the problem.
    num.evals <- 0
    solve.continue <- TRUE
    while ( num.evals <= 10 & solve.continue ) {
        # Update the number of evaluations.
        num.evals <- num.evals + 1

        # choose correct minimzation function based on wether constrained were supplied
        solution <- .Call( "NLoptR_Optimize", ret, PACKAGE = "nloptr" )

        # remove the environment from the return object
        ret$environment <- NULL

        # add solution variables to object
        ret$status     <- solution$status
        ret$message    <- solution$message
        ret$iterations <- solution$iterations
        ret$objective  <- solution$objective
        ret$solution   <- solution$solution
        ret$version    <- paste( c(solution$version_major, solution$version_minor, solution$version_bugfix), collapse='.' )
        ret$num.evals  <- num.evals

        # If maxtime is set to a positive number in the options
        # or if the return status of the solver is not equal to
        # 6, we can stop trying to solve the problem.
        #
        # Solution status 6: NLOPT_MAXTIME_REACHED: Optimization
        # stopped because maxtime (above) was reached.
        #
        # This loop is need, because sometimes the solver exits
        # with this code, even if maxtime is set to 0 or a negative
        # number.
        if ( opts$maxtime > 0 | solution$status != 6 ) {
            solve.continue <- FALSE
        }
    }

    return( ret )
}
