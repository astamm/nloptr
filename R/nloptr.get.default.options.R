# Copyright (C) 2011 Jelmer Ypma. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   nloptr.default.options.R
# Author: Jelmer Ypma
# Date:   7 August 2011
#
# Defines a data.frame  with fields:
#		name:						name of the option.
#		type:						type (numeric, logical, integer, character).
#		possible_values:			string explaining the values the option can take.				
#		default:					default value of the option (as a string).
#		is_termination_condition:	is this option part of the termination conditions?
#		description:				description of the option (taken from NLopt website
#									if it's an option that is passed on to NLopt).
#
# CHANGELOG:
#   12/07/2014: Changed from creating a data.frame to a function returning a data.frame.

nloptr.get.default.options <- 
    function() 
{ 
	dat.opts <- data.frame( rbind(
		c("algorithm", 
		  "character", 
		  "NLOPT_GN_DIRECT, NLOPT_GN_DIRECT_L, NLOPT_GN_DIRECT_L_RAND, NLOPT_GN_DIRECT_NOSCAL, NLOPT_GN_DIRECT_L_NOSCAL, NLOPT_GN_DIRECT_L_RAND_NOSCAL, NLOPT_GN_ORIG_DIRECT, NLOPT_GN_ORIG_DIRECT_L, NLOPT_GD_STOGO, NLOPT_GD_STOGO_RAND, NLOPT_LD_SLSQP, NLOPT_LD_LBFGS_NOCEDAL, NLOPT_LD_LBFGS, NLOPT_LN_PRAXIS, NLOPT_LD_VAR1, NLOPT_LD_VAR2, NLOPT_LD_TNEWTON, NLOPT_LD_TNEWTON_RESTART, NLOPT_LD_TNEWTON_PRECOND, NLOPT_LD_TNEWTON_PRECOND_RESTART, NLOPT_GN_CRS2_LM, NLOPT_GN_MLSL, NLOPT_GD_MLSL, NLOPT_GN_MLSL_LDS, NLOPT_GD_MLSL_LDS, NLOPT_LD_MMA, NLOPT_LN_COBYLA, NLOPT_LN_NEWUOA, NLOPT_LN_NEWUOA_BOUND, NLOPT_LN_NELDERMEAD, NLOPT_LN_SBPLX, NLOPT_LN_AUGLAG, NLOPT_LD_AUGLAG, NLOPT_LN_AUGLAG_EQ, NLOPT_LD_AUGLAG_EQ, NLOPT_LN_BOBYQA, NLOPT_GN_ISRES", 
		  "none", 
		  FALSE, 
		  "This option is required. Check the NLopt website for a description of the algorithms."),
		c("stopval", 
		  "numeric", 
		  "-Inf <= stopval <= Inf", 
		  "-Inf", 
		  TRUE, 
		  "Stop minimization when an objective value <= stopval is found. Setting stopval to -Inf disables this stopping criterion (default)."),
		c("ftol_rel", 
		  "numeric", 
		  "ftol_rel > 0", 
		  "0.0", 
		  TRUE, 
		  "Stop when an optimization step (or an estimate of the optimum) changes the objective function value by less than ftol_rel multiplied by the absolute value of the function value. If there is any chance that your optimum function value is close to zero, you might want to set an absolute tolerance with ftol_abs as well. Criterion is disabled if ftol_rel is non-positive (default)."),
		c("ftol_abs", 
		  "numeric", 
		  "ftol_abs > 0", 
		  "0.0", 
		  TRUE, 
		  "Stop when an optimization step (or an estimate of the optimum) changes the function value by less than ftol_abs. Criterion is disabled if ftol_abs is non-positive (default)."),
		c("xtol_rel", 
		  "numeric", 
		  "xtol_rel > 0", 
		  "1.0e-04", 
		  TRUE, 
		  "Stop when an optimization step (or an estimate of the optimum) changes every parameter by less than xtol_rel multiplied by the absolute value of the parameter. If there is any chance that an optimal parameter is close to zero, you might want to set an absolute tolerance with xtol_abs as well. Criterion is disabled if xtol_rel is non-positive."),
		c("xtol_abs", 
		  "numeric", 
		  "xtol_abs > 0", 
		  "rep( 0.0, length(x0) )", 
		  TRUE, 
		  "xtol_abs is a vector of length n (the number of elements in x) giving the tolerances: stop when an optimization step (or an estimate of the optimum) changes every parameter x[i] by less than xtol_abs[i]. Criterion is disabled if all elements of xtol_abs are non-positive (default)."),
		c("maxeval", 
		  "integer", 
		  "maxeval is a positive integer", 
		  "100", 
		  TRUE, 
		  "Stop when the number of function evaluations exceeds maxeval. This is not a strict maximum: the number of function evaluations may exceed maxeval slightly, depending upon the algorithm. Criterion is disabled if maxeval is non-positive."),
		c("maxtime", 
		  "numeric", 
		  "maxtime > 0", 
		  "-1.0", 
		  TRUE, 
		  "Stop when the optimization time (in seconds) exceeds maxtime. This is not a strict maximum: the time may exceed maxtime slightly, depending upon the algorithm and on how slow your function evaluation is. Criterion is disabled if maxtime is non-positive (default)."),
		c("tol_constraints_ineq", 
		  "numeric", 
		  "tol_constraints_ineq > 0.0", 
		  "rep( 1e-8, num_constraints_ineq )", 
		  FALSE, 
		  "The parameter tol_constraints_ineq is a vector of tolerances. Each tolerance corresponds to one of the inequality constraints. The tolerance is used for the purpose of stopping criteria only: a point x is considered feasible for judging whether to stop the optimization if eval_g_ineq(x) <= tol. A tolerance of zero means that NLopt will try not to consider any x to be converged unless eval_g_ineq(x) is strictly non-positive; generally, at least a small positive tolerance is advisable to reduce sensitivity to rounding errors. By default the tolerances for all inequality constraints are set to 1e-8."),
        c("tol_constraints_eq", 
		  "numeric", 
		  "tol_constraints_eq > 0.0", 
		  "rep( 1e-8, num_constraints_eq )", 
		  FALSE, 
		  "The parameter tol_constraints_eq is a vector of tolerances. Each tolerance corresponds to one of the equality constraints. The tolerance is used for the purpose of stopping criteria only: a point x is considered feasible for judging whether to stop the optimization if abs( eval_g_ineq(x) ) <= tol. For equality constraints, a small positive tolerance is strongly advised in order to allow NLopt to converge even if the equality constraint is slightly nonzero. By default the tolerances for all equality constraints are set to 1e-8."),
        c("print_level", 
		  "interger", 
		  "0, 1, 2, or 3", 
		  "0", 
		  FALSE, 
		  "The option print_level controls how much output is shown during the optimization process. Possible values: 0 (default): no output;
1: show iteration number and value of objective function; 2: 1 + show value of (in)equalities; 3: 2 + show value of controls."),
		c("check_derivatives", 
		  "logical", 
		  "TRUE or FALSE", 
		  "FALSE", 
		  FALSE, 
		  "The option check_derivatives can be activated to compare the user-supplied analytic gradients with finite difference approximations."),
		c("check_derivatives_tol", 
		  "numeric", 
		  "check_derivatives_tol > 0.0", 
		  "1e-04", 
		  FALSE, 
		  "The option check_derivatives_tol determines when a difference between an analytic gradient and its finite difference approximation is flagged as an error."),
		c("check_derivatives_print", 
		  "character", 
		  "'none', 'all', 'errors',", 
		  "all", 
		  FALSE, 
		  "The option check_derivatives_print controls the output of the derivative checker (if check_derivatives==TRUE). All comparisons are shown ('all'), only those comparisions that resulted in an error ('error'), or only the number of errors is shown ('none')."),
		c("print_options_doc",
		  "logical",
		  "TRUE or FALSE",
		  "FALSE",
		  FALSE,
		  "If TRUE, a description of all options and their current and default values is printed to the screen."),
		c("population",
		  "integer",
		  "population is a positive integer",
		  "0",
		  FALSE,
		  "Several of the stochastic search algorithms (e.g., CRS, MLSL, and ISRES) start by generating some initial population of random points x. By default, this initial population size is chosen heuristically in some algorithm-specific way, but the initial population can by changed by setting a positive integer value for population. A population of zero implies that the heuristic default will be used."),
		c("ranseed",
		  "integer",
		  "ranseed is a positive integer",
		  "0",
		  FALSE,
		  "For stochastic optimization algorithms, pseudorandom numbers are generated. Set the random seed using ranseed if you want to use a 'deterministic' sequence of pseudorandom numbers, i.e. the same sequence from run to run. If ranseed is 0 (default), the seed for the random numbers is generated from the system time, so that you will get a different sequence of pseudorandom numbers each time you run your program.")
	),
	stringsAsFactors = FALSE )
    names( dat.opts ) <- c( "name", "type", "possible_values", "default", "is_termination_condition", "description" )

    return( dat.opts )
}