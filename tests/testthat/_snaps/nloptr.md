# Message output for multivariate print levels and deriv checks.

    Code
      nloptr(x0, fn, gr, lb, ub, hin, hinjac, heq, heqjac, opts = list(algorithm = "NLOPT_LD_SLSQP",
        xtol_rel = 1e-08, print_level = 3, check_derivatives = TRUE))
    Message <simpleMessage>
      Checking gradients of objective function.
      Derivative checker results: 0 error(s) detected.
      
        eval_grad_f[1] = 2e+00 ~ 2e+00   [1.490116e-08]
        eval_grad_f[2] = 2e+00 ~ 2e+00   [1.490116e-08]
      
      
      Checking gradients of inequality constraints.
      
      Derivative checker results: 0 error(s) detected.
      
        eval_jac_g_ineq[1, 1] = -4.0e+00 ~ -4.0e+00   [7.450581e-09]
        eval_jac_g_ineq[2, 1] =  0.0e+00 ~  0.0e+00   [0.000000e+00]
        eval_jac_g_ineq[1, 2] =  0.0e+00 ~  0.0e+00   [0.000000e+00]
        eval_jac_g_ineq[2, 2] = -1.2e+01 ~ -1.2e+01   [1.490116e-08]
      
      
      Checking gradients of equality constraints.
      
      Derivative checker results: 0 error(s) detected.
      
        eval_jac_g_eq[1, 1] =  2e+00 ~  2e+00   [0e+00]
        eval_jac_g_eq[2, 1] =  1e+00 ~  1e+00   [0e+00]
        eval_jac_g_eq[1, 2] =  2e+00 ~  2e+00   [0e+00]
        eval_jac_g_eq[2, 2] = -1e+00 ~ -1e+00   [0e+00]
      
      
    Output
      iteration: 1
      	x = (2.000000, 2.000000)
      	f(x) = 3.000000
      	h(x) = (1.450000, -0.200000)
      	g(x) = (-2.560000, -5.803000)
      iteration: 2
      	x = (1.737500, 1.537500)
      	f(x) = 1.832812
      	h(x) = (0.121406, -0.000000)
      	g(x) = (-1.578906, -1.437506)
      iteration: 3
      	x = (1.700429, 1.500429)
      	f(x) = 1.741031
      	h(x) = (0.001374, -0.000000)
      	g(x) = (-1.451460, -1.180899)
      iteration: 4
      	x = (1.700000, 1.500000)
      	f(x) = 1.740000
      	h(x) = (0.000000, 0.000000)
      	g(x) = (-1.450000, -1.178000)
      iteration: 5
      	x = (1.700000, 1.500000)
      	f(x) = 1.740000
      	h(x) = (0.000000, 0.000000)
      	g(x) = (-1.450000, -1.178000)
      iteration: 6
      	x = (1.700000, 1.500000)
      	f(x) = 1.740000
      	h(x) = (0.000000, -0.000000)
      	g(x) = (-1.450000, -1.178000)
      
      Call:
      nloptr(x0 = x0, eval_f = fn, eval_grad_f = gr, lb = lb, ub = ub, 
          eval_g_ineq = hin, eval_jac_g_ineq = hinjac, eval_g_eq = heq, 
          eval_jac_g_eq = heqjac, opts = list(algorithm = "NLOPT_LD_SLSQP", 
              xtol_rel = 1e-08, print_level = 3, check_derivatives = TRUE))
      
      
      Minimization using NLopt version 2.7.1 
      
      NLopt solver status: 4 ( NLOPT_XTOL_REACHED: Optimization stopped because 
      xtol_rel or xtol_abs (above) was reached. )
      
      Number of Iterations....: 6 
      Termination conditions:  xtol_rel: 1e-08 
      Number of inequality constraints:  2 
      Number of equality constraints:    2 
      Optimal value of objective function:  1.74 
      Optimal value of controls: 1.7 1.5
      
      

# Message output for univariate print levels and deriv checks.

    Code
      nloptr(x0, fn, gr, lb, ub, hin, hinjac, heq, heqjac, opts = list(algorithm = "NLOPT_LD_SLSQP",
        xtol_rel = 1e-08, print_level = 3, check_derivatives = TRUE))
    Message <simpleMessage>
      Checking gradients of objective function.
      Derivative checker results: 0 error(s) detected.
      
        eval_grad_f[1] = 6e+00 ~ 6e+00   [1.589457e-08]
      
      
      Checking gradients of inequality constraints.
      
      Derivative checker results: 0 error(s) detected.
      
        eval_jac_g_ineq[1] = -1e+01 ~ -1e+01   [9.536743e-09]
      
      
      Checking gradients of equality constraints.
      
      Derivative checker results: 0 error(s) detected.
      
        eval_jac_g_eq[1] = 1e+01 ~ 1e+01   [0e+00]
      
      
    Output
      iteration: 1
      	x = 5.000000
      	f(x) = 9.000000
      	h(x) = 23.000000
      	g(x) = -19.710000
      iteration: 2
      	x = 2.700000
      	f(x) = 0.490000
      	h(x) = 0.000000
      	g(x) = -2.000000
      
      Call:
      nloptr(x0 = x0, eval_f = fn, eval_grad_f = gr, lb = lb, ub = ub, 
          eval_g_ineq = hin, eval_jac_g_ineq = hinjac, eval_g_eq = heq, 
          eval_jac_g_eq = heqjac, opts = list(algorithm = "NLOPT_LD_SLSQP", 
              xtol_rel = 1e-08, print_level = 3, check_derivatives = TRUE))
      
      
      Minimization using NLopt version 2.7.1 
      
      NLopt solver status: 4 ( NLOPT_XTOL_REACHED: Optimization stopped because 
      xtol_rel or xtol_abs (above) was reached. )
      
      Number of Iterations....: 2 
      Termination conditions:  xtol_rel: 1e-08 
      Number of inequality constraints:  1 
      Number of equality constraints:    1 
      Optimal value of objective function:  0.49 
      Optimal value of controls: 2.7
      
      

# NLOPT_ROUNDOFF_LIMITED

    Code
      nloptr(x0, fn, gr, opts = list(algorithm = "NLOPT_LD_SLSQP", xtol_rel = -Inf))
    Output
      
      Call:
      
      nloptr(x0 = x0, eval_f = fn, eval_grad_f = gr, opts = list(algorithm = "NLOPT_LD_SLSQP", 
          xtol_rel = -Inf))
      
      
      Minimization using NLopt version 2.7.1 
      
      NLopt solver status: -4 ( NLOPT_ROUNDOFF_LIMITED: Roundoff errors led to a 
      breakdown of the optimization algorithm. In this case, the returned minimum may 
      still be useful. (e.g. this error occurs in NEWUOA if one tries to achieve a 
      tolerance too close to machine precision.) )
      
      Number of Iterations....: 4 
      Termination conditions:  xtol_rel: -Inf 
      Number of inequality constraints:  0 
      Number of equality constraints:    0 
      Current value of objective function:  0 
      Current value of controls: 2
      
      

# stopval triggered

    Code
      nloptr(c(4, 4), fn, opts = list(algorithm = "NLOPT_LN_SBPLX", stopval = 20))
    Output
      
      Call:
      
      nloptr(x0 = c(4, 4), eval_f = fn, opts = list(algorithm = "NLOPT_LN_SBPLX", 
          stopval = 20))
      
      
      Minimization using NLopt version 2.7.1 
      
      NLopt solver status: 2 ( NLOPT_STOPVAL_REACHED: Optimization stopped because 
      stopval (above) was reached. )
      
      Number of Iterations....: 1 
      Termination conditions:  stopval: 20 
      Number of inequality constraints:  0 
      Number of equality constraints:    0 
      Optimal value of objective function:  4 
      Optimal value of controls: 4 4
      
      

