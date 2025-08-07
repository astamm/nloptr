#ifndef __NLOPTR_H__
#define __NLOPTR_H__

#include <nlopt.h>

#include <R.h>
#include <Rinternals.h>

#define AS_INTEGER(x)	Rf_coerceVector(x, INTSXP)

// Extracts element with name 'str' from R object 'list' & returns that element.
SEXP getListElement(SEXP list, char *str);

// Convert the algorithm lookup from a nested if-else chain to a lookup table
// and switch statement. See https://stackoverflow.com/a/49215742/2726543
typedef struct {
  char *key;
  int value;
} ALGPAIR;

int getVal(char *key);

// Convert passed string to an nlopt_algorithm item.
nlopt_algorithm getAlgorithmCode(const char *algorithm_str);

// Define structure that contains data to pass to the objective function
typedef struct {
  SEXP R_eval_f;
  SEXP R_environment;
  size_t num_iterations;
  int print_level;
} func_objective_data;

// Define function that calls user-defined objective function in R
double func_objective(unsigned n, const double *x, double *grad, void *data);

// Define structure that contains data to pass to the constraint function.
typedef struct {
    SEXP R_eval_g;
    SEXP R_environment;
    int print_level;
} func_constraints_ineq_data;

/*
 * Define function that calls user-defined inequality constraints function in R
 *
 * m           : number of constraints
 * constraints : value of the constraints evaluated at x
 * n           : number of variables
 * x           : point where we want to evaluate the constraints
 * grad        : value of the gradient of the constraints, grad[i*n + j] = \frac{ \partial c_i }{ \partial x_j }
 * data        : additional data that we need to evaluate the function (e.g. the R function)
*/
void func_constraints_ineq(unsigned m, double* constraints, unsigned n, const double* x, double* grad, void* data);

// Define structure that contains data to pass to the constraint function.
typedef struct {
    SEXP R_eval_g;
    SEXP R_environment;
    int print_level;
} func_constraints_eq_data;

/*
 * Define function that calls user-defined equality constraints function in R
 *
 * m           : number of constraints
 * constraints : value of the constraints evaluated at x
 * n           : number of variables
 * x           : point where we want to evaluate the constraints
 * grad        : value of the gradient of the constraints, grad[i*n + j] = \frac{ \partial c_i }{ \partial x_j }
 * data        : additional data that we need to evaluate the function (e.g. the R function)
*/
void func_constraints_eq(unsigned m, double* constraints, unsigned n, const double* x, double* grad, void* data);

/*
 * double minf_max - stop if the objective function value drops below minf_max. (Set to -HUGE_VAL to ignore.)
 * double ftol_rel,
 * double ftol_abs - relative and absolute tolerances in the objective function value. (Set to zero to ignore.)
 * double xtol_rel, *xtol_abs - relative and absolute tolerances in the optimization parameter values. xtol_abs
 *                              should either be NULL, in which case it is ignored (equivalent to zero tolerance),
 *                              or a single value in which case it is applied to all parameters, or an array of
 *                              length n containing absolute tolerances in each parameter x[i]. Set any tolerance
 *                              value to zero for it to be ignored.
 * double *x_weights - weights on the optimization parameters. Can be a single value in which case it is applied to
 *                     all parameters, or an array of length n containing weights for each of the n parameters.
 *                     Set any weight value to zero for it to be ignored. (Set to NULL to ignore.)
 * int maxeval - stop if the objective function is evaluated at least maxeval times. Set to zero to ignore.
 * double maxtime - stop if the elapsed wall-clock time, in seconds, exceeds maxtime. Set to zero to ignore.
*/
nlopt_opt getOptions(SEXP R_options, int num_controls, int *flag_encountered_error);

SEXP convertStatusToMessage(nlopt_result status);

SEXP NLoptR_Optimize(SEXP args);

#endif /*__NLOPTR_H__*/
