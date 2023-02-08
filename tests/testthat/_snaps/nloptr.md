# Complicated message output from nloptr derivative checks.

    Code
      nloptr(4, fn, gr, eval_g_ineq = hin, eval_jac_g_ineq = hinjac, eval_g_eq = heq,
        eval_jac_g_eq = heqjac, opts = ctlSQP)
    Output
      algorithm
      	possible values: NLOPT_GN_DIRECT, NLOPT_GN_DIRECT_L,
      	                 NLOPT_GN_DIRECT_L_RAND, NLOPT_GN_DIRECT_NOSCAL,
      	                 NLOPT_GN_DIRECT_L_NOSCAL,
      	                 NLOPT_GN_DIRECT_L_RAND_NOSCAL,
      	                 NLOPT_GN_ORIG_DIRECT, NLOPT_GN_ORIG_DIRECT_L,
      	                 NLOPT_GD_STOGO, NLOPT_GD_STOGO_RAND,
      	                 NLOPT_LD_SLSQP, NLOPT_LD_LBFGS_NOCEDAL,
      	                 NLOPT_LD_LBFGS, NLOPT_LN_PRAXIS, NLOPT_LD_VAR1,
      	                 NLOPT_LD_VAR2, NLOPT_LD_TNEWTON,
      	                 NLOPT_LD_TNEWTON_RESTART,
      	                 NLOPT_LD_TNEWTON_PRECOND,
      	                 NLOPT_LD_TNEWTON_PRECOND_RESTART,
      	                 NLOPT_GN_CRS2_LM, NLOPT_GN_MLSL, NLOPT_GD_MLSL,
      	                 NLOPT_GN_MLSL_LDS, NLOPT_GD_MLSL_LDS,
      	                 NLOPT_LD_MMA, NLOPT_LD_CCSAQ, NLOPT_LN_COBYLA,
      	                 NLOPT_LN_NEWUOA, NLOPT_LN_NEWUOA_BOUND,
      	                 NLOPT_LN_NELDERMEAD, NLOPT_LN_SBPLX,
      	                 NLOPT_LN_AUGLAG, NLOPT_LD_AUGLAG,
      	                 NLOPT_LN_AUGLAG_EQ, NLOPT_LD_AUGLAG_EQ,
      	                 NLOPT_LN_BOBYQA, NLOPT_GN_ISRES
      	default value:   none
      	current value:   NLOPT_LD_SLSQP
      
      	This option is required. Check the NLopt website for a description of
      	the algorithms.
      
      stopval
      	possible values: -Inf <= stopval <= Inf
      	default value:   -Inf
      	current value:   -Inf
      
      	Stop minimization when an objective value <= stopval is found.
      	Setting stopval to -Inf disables this stopping criterion (default).
      
      ftol_rel
      	possible values: ftol_rel > 0
      	default value:   0.0
      	current value:   0
      
      	Stop when an optimization step (or an estimate of the optimum)
      	changes the objective function value by less than ftol_rel multiplied
      	by the absolute value of the function value. If there is any chance
      	that your optimum function value is close to zero, you might want to
      	set an absolute tolerance with ftol_abs as well. Criterion is
      	disabled if ftol_rel is non-positive (default).
      
      ftol_abs
      	possible values: ftol_abs > 0
      	default value:   0.0
      	current value:   0
      
      	Stop when an optimization step (or an estimate of the optimum)
      	changes the function value by less than ftol_abs. Criterion is
      	disabled if ftol_abs is non-positive (default).
      
      xtol_rel
      	possible values: xtol_rel > 0
      	default value:   1.0e-04
      	current value:   1e-08
      
      	Stop when an optimization step (or an estimate of the optimum)
      	changes every parameter by less than xtol_rel multiplied by the
      	absolute value of the parameter. If there is any chance that an
      	optimal parameter is close to zero, you might want to set an absolute
      	tolerance with xtol_abs as well. Criterion is disabled if xtol_rel is
      	non-positive.
      
      xtol_abs
      	possible values: xtol_abs > 0
      	default value:   rep( 0.0, length(x0) )
      	current value:   0
      
      	xtol_abs is a vector of length n (the number of elements in x) giving
      	the tolerances: stop when an optimization step (or an estimate of the
      	optimum) changes every parameter x[i] by less than xtol_abs[i].
      	Criterion is disabled if all elements of xtol_abs are non-positive
      	(default).
      
      maxeval
      	possible values: maxeval is a positive integer
      	default value:   100
      	current value:   100
      
      	Stop when the number of function evaluations exceeds maxeval. This is
      	not a strict maximum: the number of function evaluations may exceed
      	maxeval slightly, depending upon the algorithm. Criterion is disabled
      	if maxeval is non-positive.
      
      maxtime
      	possible values: maxtime > 0
      	default value:   -1.0
      	current value:   -1
      
      	Stop when the optimization time (in seconds) exceeds maxtime. This is
      	not a strict maximum: the time may exceed maxtime slightly, depending
      	upon the algorithm and on how slow your function evaluation is.
      	Criterion is disabled if maxtime is non-positive (default).
      
      tol_constraints_ineq
      	possible values: tol_constraints_ineq > 0.0
      	default value:   rep( 1e-8, num_constraints_ineq )
      	current value:   1e-08
      
      	The parameter tol_constraints_ineq is a vector of tolerances. Each
      	tolerance corresponds to one of the inequality constraints. The
      	tolerance is used for the purpose of stopping criteria only: a point
      	x is considered feasible for judging whether to stop the optimization
      	if eval_g_ineq(x) <= tol. A tolerance of zero means that NLopt will
      	try not to consider any x to be converged unless eval_g_ineq(x) is
      	strictly non-positive; generally, at least a small positive tolerance
      	is advisable to reduce sensitivity to rounding errors. By default the
      	tolerances for all inequality constraints are set to 1e-8.
      
      tol_constraints_eq
      	possible values: tol_constraints_eq > 0.0
      	default value:   rep( 1e-8, num_constraints_eq )
      	current value:   1e-08
      
      	The parameter tol_constraints_eq is a vector of tolerances. Each
      	tolerance corresponds to one of the equality constraints. The
      	tolerance is used for the purpose of stopping criteria only: a point
      	x is considered feasible for judging whether to stop the optimization
      	if abs( eval_g_ineq(x) ) <= tol. For equality constraints, a small
      	positive tolerance is strongly advised in order to allow NLopt to
      	converge even if the equality constraint is slightly nonzero. By
      	default the tolerances for all equality constraints are set to 1e-8.
      
      print_level
      	possible values: 0, 1, 2, or 3
      	default value:   0
      	current value:   0
      
      	The option print_level controls how much output is shown during the
      	optimization process. Possible values: 0 (default): no output; 1:
      	show iteration number and value of objective function; 2: 1 + show
      	value of (in)equalities; 3: 2 + show value of controls.
      
      check_derivatives
      	possible values: TRUE or FALSE
      	default value:   FALSE
      	current value:   TRUE
      
      	The option check_derivatives can be activated to compare the
      	user-supplied analytic gradients with finite difference
      	approximations.
      
      check_derivatives_tol
      	possible values: check_derivatives_tol > 0.0
      	default value:   1e-04
      	current value:   1e-04
      
      	The option check_derivatives_tol determines when a difference between
      	an analytic gradient and its finite difference approximation is
      	flagged as an error.
      
      check_derivatives_print
      	possible values: 'none', 'all', 'errors',
      	default value:   all
      	current value:   all
      
      	The option check_derivatives_print controls the output of the
      	derivative checker (if check_derivatives==TRUE). All comparisons are
      	shown ('all'), only those comparisions that resulted in an error
      	('error'), or only the number of errors is shown ('none').
      
      print_options_doc
      	possible values: TRUE or FALSE
      	default value:   FALSE
      	current value:   TRUE
      
      	If TRUE, a description of all options and their current and default
      	values is printed to the screen.
      
      population
      	possible values: population is a positive integer
      	default value:   0
      	current value:   0
      
      	Several of the stochastic search algorithms (e.g., CRS, MLSL, and
      	ISRES) start by generating some initial population of random points
      	x. By default, this initial population size is chosen heuristically
      	in some algorithm-specific way, but the initial population can by
      	changed by setting a positive integer value for population. A
      	population of zero implies that the heuristic default will be used.
      
      vector_storage
      	possible values: vector_storage is a positive integer
      	default value:   20
      	current value:   20
      
      	Number of gradients to remember from previous optimization steps.
      
      ranseed
      	possible values: ranseed is a positive integer
      	default value:   0
      	current value:   0
      
      	For stochastic optimization algorithms, pseudorandom numbers are
      	generated. Set the random seed using ranseed if you want to use a
      	'deterministic' sequence of pseudorandom numbers, i.e. the same
      	sequence from run to run. If ranseed is 0 (default), the seed for the
      	random numbers is generated from the system time, so that you will
      	get a different sequence of pseudorandom numbers each time you run
      	your program.
      
    Message <simpleMessage>
      Checking gradients of objective function.
      Derivative checker results: 0 error(s) detected.
      
        eval_grad_f[ 1 ] = 4e+00 ~ 4e+00   [1.490116e-08]
      
      
      Checking gradients of inequality constraints.
      
      Derivative checker results: 0 error(s) detected.
      
        eval_jac_g_ineq[ 1 ] = -1e+00 ~ -1e+00   [0e+00]
      
      
      Checking gradients of equality constraints.
      
      Derivative checker results: 0 error(s) detected.
      
        eval_jac_g_eq[ 1 ] = 2.4e+01 ~ 2.4e+01   [9.934107e-09]
      
      
    Output
      
      Call:
      nloptr(x0 = 4, eval_f = fn, eval_grad_f = gr, eval_g_ineq = hin, 
          eval_jac_g_ineq = hinjac, eval_g_eq = heq, eval_jac_g_eq = heqjac, 
          opts = ctlSQP)
      
      
      Minimization using NLopt version 2.7.1 
      
      NLopt solver status: 4 ( NLOPT_XTOL_REACHED: Optimization stopped because 
      xtol_rel or xtol_abs (above) was reached. )
      
      Number of Iterations....: 6 
      Termination conditions:  xtol_rel: 1e-08 
      Number of inequality constraints:  1 
      Number of equality constraints:    1 
      Optimal value of objective function:  0.64 
      Optimal value of controls: 2.8
      
      

