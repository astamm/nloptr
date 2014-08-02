/*
 * Copyright (C) 2010 Jelmer Ypma. All Rights Reserved.
 * This code is published under the L-GPL.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published 
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *   
 * File:   nloptr.cpp
 * Author: Jelmer Ypma
 * Date:   9 June 2010
 *
 * This file defines the main function NLoptR_Minimize, which
 * provides an interface to NLopt from R.
 *
 * The function takes an R object containing objective function,
 * constraints, options, etc. as argument, solve the problem 
 * using NLopt and return the results.
 *
 * Financial support of the UK Economic and Social Research Council 
 * through a grant (RES-589-28-0001) to the ESRC Centre for Microdata 
 * Methods and Practice (CeMMAP) is gratefully acknowledged.
 *
 * 13/01/2011: added print_level option
 * 24/07/2011: added checks on return value when setting equality constraints etc.
 * 05/11/2013: Moved declaration of ineq_constr_data and eq_constr_data outside if-statement to solve segfault on Ubuntu.
 */

 // TODO: add minimize/maximize option (objective = "maximize")
 // nlopt_result nlopt_set_min_objective(nlopt_opt opt, nlopt_func f, void* f_data);
// nlopt_result nlopt_set_max_objective(nlopt_opt opt, nlopt_func f, void* f_data);

#include "nlopt.h"

#include <R.h>
#include <Rdefines.h>
// Rdefines.h is somewhat more higher level then Rinternal.h, and is preferred if the code might be shared with S at any stage.

// #include <string>


/*
 * Extracts element with name 'str' from R object 'list'
 * and returns that element.
 */
SEXP
getListElement (SEXP list, char *str)
{
    SEXP elmt = R_NilValue, names = getAttrib(list, R_NamesSymbol);
    int i;
    
    for (i = 0; i < length(list); i++) {
        if(strcmp(CHAR(STRING_ELT(names, i)), str) == 0) {
            elmt = VECTOR_ELT(list, i);
            break;
        }
    }        
    return elmt;
}

// convert string to nlopt_alogirthm
nlopt_algorithm getAlgorithmCode( const char *algorithm_str ) {
    
    nlopt_algorithm algorithm;
    
    if ( strcmp( algorithm_str, "NLOPT_GN_DIRECT" ) == 0 ) {
        algorithm = NLOPT_GN_DIRECT;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_GN_DIRECT_L" ) == 0 ) {
        algorithm = NLOPT_GN_DIRECT_L;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_GN_DIRECT_L_RAND" ) == 0 ) {
        algorithm = NLOPT_GN_DIRECT_L_RAND;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_GN_DIRECT_NOSCAL" ) == 0 ) {
        algorithm = NLOPT_GN_DIRECT_NOSCAL;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_GN_DIRECT_L_NOSCAL" ) == 0 ) {
        algorithm = NLOPT_GN_DIRECT_L_NOSCAL;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_GN_DIRECT_L_RAND_NOSCAL" ) == 0 ) {
        algorithm = NLOPT_GN_DIRECT_L_RAND_NOSCAL;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_GN_ORIG_DIRECT" ) == 0 ) {
        algorithm = NLOPT_GN_ORIG_DIRECT;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_GN_ORIG_DIRECT_L" ) == 0 ) {
        algorithm = NLOPT_GN_ORIG_DIRECT_L;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_GD_STOGO" ) == 0 ) {
        algorithm = NLOPT_GD_STOGO;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_GD_STOGO_RAND" ) == 0 ) {
        algorithm = NLOPT_GD_STOGO_RAND;
    }
    else if ( strcmp( algorithm_str, "NLOPT_LD_SLSQP" ) == 0 ) {
        algorithm = NLOPT_LD_SLSQP;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_LD_LBFGS_NOCEDAL" ) == 0 ) {
        algorithm = NLOPT_LD_LBFGS_NOCEDAL;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_LD_LBFGS" ) == 0 ) {
        algorithm = NLOPT_LD_LBFGS;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_LN_PRAXIS" ) == 0 ) {
        algorithm = NLOPT_LN_PRAXIS;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_LD_VAR1" ) == 0 ) {
        algorithm = NLOPT_LD_VAR1;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_LD_VAR2" ) == 0 ) {
        algorithm = NLOPT_LD_VAR2;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_LD_TNEWTON" ) == 0 ) {
        algorithm = NLOPT_LD_TNEWTON;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_LD_TNEWTON_RESTART" ) == 0 ) {
        algorithm = NLOPT_LD_TNEWTON_RESTART;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_LD_TNEWTON_PRECOND" ) == 0 ) {
        algorithm = NLOPT_LD_TNEWTON_PRECOND;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_LD_TNEWTON_PRECOND_RESTART" ) == 0 ) {
        algorithm = NLOPT_LD_TNEWTON_PRECOND_RESTART;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_GN_CRS2_LM" ) == 0 ) {
        algorithm = NLOPT_GN_CRS2_LM;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_GN_MLSL" ) == 0 ) {
        algorithm = NLOPT_GN_MLSL;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_GD_MLSL" ) == 0 ) {
        algorithm = NLOPT_GD_MLSL;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_GN_MLSL_LDS" ) == 0 ) {
        algorithm = NLOPT_GN_MLSL_LDS;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_GD_MLSL_LDS" ) == 0 ) {
        algorithm = NLOPT_GD_MLSL_LDS;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_LD_MMA" ) == 0 ) {
        algorithm = NLOPT_LD_MMA;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_LN_COBYLA" ) == 0 ) {
        algorithm = NLOPT_LN_COBYLA;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_LN_NEWUOA" ) == 0 ) {
        algorithm = NLOPT_LN_NEWUOA;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_LN_NEWUOA_BOUND" ) == 0 ) {
        algorithm = NLOPT_LN_NEWUOA_BOUND;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_LN_NELDERMEAD" ) == 0 ) {
        algorithm = NLOPT_LN_NELDERMEAD;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_LN_SBPLX" ) == 0 ) {
        algorithm = NLOPT_LN_SBPLX;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_LN_AUGLAG" ) == 0 ) {
        algorithm = NLOPT_LN_AUGLAG;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_LD_AUGLAG" ) == 0 ) {
        algorithm = NLOPT_LD_AUGLAG;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_LN_AUGLAG_EQ" ) == 0 ) {
        algorithm = NLOPT_LN_AUGLAG_EQ;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_LD_AUGLAG_EQ" ) == 0 ) {
        algorithm = NLOPT_LD_AUGLAG_EQ;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_LN_BOBYQA" ) == 0 ) {
        algorithm = NLOPT_LN_BOBYQA;
    } 
    else if ( strcmp( algorithm_str, "NLOPT_GN_ISRES" ) == 0 ) {
        algorithm = NLOPT_GN_ISRES;
    } 
    else {
        // unknown algorithm code
        Rprintf("Error: unknown algorithm %s.\n", algorithm_str);
        algorithm = NLOPT_NUM_ALGORITHMS;       // Not an algorithm, so this should result in a runtime error.
    }
    
    return algorithm;
}


/*
 * Define structure that contains data to pass to the objective function
 */
typedef struct {
    SEXP R_eval_f;
    SEXP R_environment;
    int  num_iterations;
    int  print_level;
} func_objective_data;

/*
 * Define function that calls user-defined objective function in R
 */
double func_objective(unsigned n, const double *x, double *grad, void *data)
{
    // return the value (and the gradient) of the objective function
  
    // Check for user interruption from R
    R_CheckUserInterrupt();
    
    // declare counter
    unsigned i;
    
    func_objective_data *d = (func_objective_data *) data;
  
    // increase number of function evaluations
    d->num_iterations++;
  
    // print status
    if ( d->print_level >= 1 ) {
        Rprintf( "iteration: %d\n", d->num_iterations );
    }
    
    // print values of x
    if ( d->print_level >= 3 ) {
        if ( n == 1 ) {
            Rprintf( "\tx = %f\n", x[ 0 ] );
        }
        else {
            Rprintf( "\tx = ( %f", x[ 0 ] );
            for (i=1;i<n;i++) {
                Rprintf( ", %f", x[ i ] );
            }
            Rprintf( " )\n" );
        }
    }
    
    // Allocate memory for a vector of reals.
    // This vector will contain the elements of x,
    // x is the argument to the R function R_eval_f
    SEXP rargs = allocVector(REALSXP,n);
    for (i=0;i<n;i++) {
        REAL(rargs)[i] = x[i];
    }
  
    // evaluate R function R_eval_f with the control x as an argument
    SEXP Rcall,result;
    PROTECT(Rcall = lang2(d->R_eval_f,rargs));
    PROTECT(result = eval(Rcall,d->R_environment));
  
    // recode the return value from SEXP to double
    double obj_value;
    if ( isNumeric( result ) ) {
        // objective value is only element of result
        obj_value = REAL(result)[0];
    }
    else {
        // objective value should be parsed from the list of return values
        SEXP R_obj_value;
        PROTECT( R_obj_value = getListElement( result, "objective" ) );
    
        // recode the return value from SEXP to double
        obj_value = REAL( R_obj_value )[0];
        
        UNPROTECT( 1 );
    }
  
    // print objective value
    if ( d->print_level >= 1 ) {
        Rprintf( "\tf(x) = %f\n", obj_value );
    }
    
    // gradient
    if (grad) {
        // result needs to be a list in this case
        SEXP R_gradient;
        PROTECT( R_gradient = getListElement( result, "gradient" ) );
        
        // recode the return value from SEXP to double
        for (i=0;i<n;i++) {
            grad[i] = REAL( R_gradient )[i];
        }
        
        UNPROTECT( 1 );
    }
  
    UNPROTECT( 2 );
  
    return obj_value;
}

/*
 * Define structure that contains data to pass to the constraint function
 */
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
void func_constraints_ineq(unsigned m, double* constraints, unsigned n, const double* x, double* grad, void* data) {
    
    // return the value (and the jacobian) of the constraints
  
    // Check for user interruption from R
    R_CheckUserInterrupt();
    
    // declare counter
    unsigned i,j;
  
    func_constraints_ineq_data *d = (func_constraints_ineq_data *) data;
  
    // Allocate memory for a vector of reals.
    // This vector will contain the elements of x,
    // x is the argument to the R function R_eval_f
    SEXP rargs_x = allocVector( REALSXP, n );
    for (i=0;i<n;i++) {
        REAL( rargs_x )[i] = x[i];
    }
  
    // evaluate R function R_eval_g with the control x as an argument
    SEXP Rcall, result;
    PROTECT( Rcall = lang2( d->R_eval_g, rargs_x ) );
    PROTECT( result = eval( Rcall, d->R_environment ) );
  
    // get the value of the constraint from the result
    if ( isNumeric( result ) ) {
    
        // constraint values are the only element of result
        // recode the return value from SEXP to double*, by looping over constraints
        for (i=0;i<m;i++) {
            constraints[ i ] = REAL( result )[ i ];
        }
    }
    else {
        // constraint value should be parsed from the list of return values
        SEXP R_constraints;
        PROTECT( R_constraints = getListElement( result, "constraints" ) );
    
        // recode the return value from SEXP to double*, by looping over constraints 
        for (i=0;i<m;i++) {
            constraints[ i ] = REAL( R_constraints )[ i ];
        }
        
        UNPROTECT( 1 );
    }
    
    // print inequality constraints
    if ( d->print_level >= 2 ) {
        if ( m == 1 ) {
            Rprintf( "\tg(x) = %f\n", constraints[ 0 ] );
        }
        else {
            Rprintf( "\tg(x) = ( %f", constraints[ 0 ] );
            for (i=1;i<m;i++) {
                Rprintf( ", %f", constraints[ i ] );
            }
            Rprintf( " )\n" );
        }
    }
    
    // get the value of the gradient if needed
    if (grad) {
        // result needs to be a list in this case
        SEXP R_gradient;
        PROTECT( R_gradient = getListElement( result, "jacobian" ) );
        
        /*
           * recode the return value from SEXP to double*, by looping over variables and constraints
         * We get a matrix from R with the jacobian of the constraints
         *  / dc_1/dx_1   dc_1/dx_2  ...  dc_1/dx_n \
         * |  dc_2/dx_1   dc_2/dx_2  ...  dc_2/dx_n  |
         * |     ...         ...             ...     |
         *  \ dc_m/dx_1   dc_m/dx_2  ...  dc_m/dx_n /
         * Matrices are stored column-wise, so basically we get a vector
         * [ dc_1/dx_1, dc_2/dx_1, ..., dc_m/dx_1, dc_1/dx_2, dc_2/dx_2, ..., dc_m/dx_2, ..., dc_1/dx_n, dc_2/dx_n, ..., dc_m/dx_n ]
         * which we have to convert to a row-wise format for NLopt.
         */
         
        for (i=0;i<m;i++) {
            for (j=0;j<n;j++) {
                grad[i*n + j] = REAL( R_gradient )[j*m + i];
            }
        }
        
        UNPROTECT( 1 );
    }
    
    UNPROTECT( 2 );
}


/*
 * Define structure that contains data to pass to the constraint function
 */
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
void func_constraints_eq(unsigned m, double* constraints, unsigned n, const double* x, double* grad, void* data) {
    
    // return the value (and the jacobian) of the constraints
  
    // Check for user interruption from R
    R_CheckUserInterrupt();
    
    // declare counter
    unsigned i,j;
  
    func_constraints_eq_data *d = (func_constraints_eq_data *) data;
  
    // Allocate memory for a vector of reals.
    // This vector will contain the elements of x,
    // x is the argument to the R function R_eval_f
    SEXP rargs_x = allocVector( REALSXP, n );
    for (i=0;i<n;i++) {
        REAL( rargs_x )[i] = x[i];
    }
  
    // evaluate R function R_eval_g with the control x as an argument
    SEXP Rcall, result;
    PROTECT( Rcall = lang2( d->R_eval_g, rargs_x ) );
    PROTECT( result = eval( Rcall, d->R_environment ) );
  
    // get the value of the constraint from the result
    if ( isNumeric( result ) ) {
    
        // constraint values are the only element of result
        // recode the return value from SEXP to double*, by looping over constraints
        for (i=0;i<m;i++) {
            constraints[ i ] = REAL( result )[ i ];
        }
    }
    else {
        // constraint value should be parsed from the list of return values
        SEXP R_constraints;
        PROTECT( R_constraints = getListElement( result, "constraints" ) );
    
        // recode the return value from SEXP to double*, by looping over constraints 
        for (i=0;i<m;i++) {
            constraints[ i ] = REAL( R_constraints )[ i ];
        }
        
        UNPROTECT( 1 );
    }
    
    // print equality constraints
    if ( d->print_level >= 2 ) {
        if ( m == 1 ) {
            Rprintf( "\th(x) = %f\n", constraints[ 0 ] );
        }
        else {
            Rprintf( "\th(x) = ( %f", constraints[ 0 ] );
            for (i=1;i<m;i++) {
                Rprintf( ", %f", constraints[ i ] );
            }
            Rprintf( " )\n" );
        }
    }
    
    // get the value of the gradient if needed
    if (grad) {
        // result needs to be a list in this case
        SEXP R_gradient;
        PROTECT( R_gradient = getListElement( result, "jacobian" ) );
        
        /* 
         * recode the return value from SEXP to double*, by looping over variables and constraints
         * We get a matrix from R with the jacobian of the constraints
         *  / dc_1/dx_1   dc_1/dx_2  ...  dc_1/dx_n \
         * |  dc_2/dx_1   dc_2/dx_2  ...  dc_2/dx_n  |
         * |     ...         ...             ...     |
         *  \ dc_m/dx_1   dc_m/dx_2  ...  dc_m/dx_n /
         * Matrices are stored column-wise, so basically we get a vector
         * [ dc_1/dx_1, dc_2/dx_1, ..., dc_m/dx_1, dc_1/dx_2, dc_2/dx_2, ..., dc_m/dx_2, ..., dc_1/dx_n, dc_2/dx_n, ..., dc_m/dx_n ]
         * which we have to convert to a row-wise format for NLopt.
         */
         
        for (i=0;i<m;i++) {
            for (j=0;j<n;j++) {
                grad[i*n + j] = REAL( R_gradient )[j*m + i];
            }
        }
        
        UNPROTECT( 1 );
    }
    
    UNPROTECT( 2 );
}

nlopt_opt getOptions( SEXP R_options, int num_controls, int *flag_encountered_error ) {

    /*
     * double minf_max - stop if the objective function value drops below minf_max. (Set to -HUGE_VAL to ignore.)
     * double ftol_rel, 
     * double ftol_abs - relative and absolute tolerances in the objective function value. (Set to zero to ignore.)
     * double xtol_rel, xtol_abs - relative and absolute tolerances in the optimization parameter values. xtol_abs 
     *                             should either be NULL, in which case it is ignored (equivalent to zero tolerance), 
     *                             or otherwise it should point to an array of length n containing absolute tolerances 
     *                             in each parameter x[i]. Set any tolerance to zero for it to be ignored.
     * int maxeval - stop if the objective function is evaluated at least maxeval times. Set to zero to ignore.
     * double maxtime - stop if the elapsed wall-clock time, in seconds, exceeds maxtime. Set to zero to ignore. 
     */

    // declare nlopt_result, to capture error codes from setting options
    nlopt_result res;
    
    // get algorithm from options
    SEXP R_algorithm;
    PROTECT( R_algorithm = getListElement( R_options, "algorithm" ) );
  
    // R_algorithm_str will contain the first (should be the only one) element of the list
    SEXP R_algorithm_str;
    PROTECT( R_algorithm_str = STRING_ELT( R_algorithm, 0 ) );
    const char* algorithm_str = CHAR( R_algorithm_str );
    nlopt_algorithm algorithm = getAlgorithmCode( algorithm_str );
 
    // declare options 
    nlopt_opt opts;     
    opts = nlopt_create(algorithm, num_controls); // algorithm and dimensionality
    
    // get other options
    SEXP R_opts_stopval;        // stop when f(x) <= stopval for minimizing or >= stopval for maximizing
    PROTECT( R_opts_stopval = getListElement( R_options, "stopval" ) );
    double stopval = REAL( R_opts_stopval )[0];
    res = nlopt_set_stopval(opts, stopval);
    if ( res == NLOPT_INVALID_ARGS ) {
        *flag_encountered_error = 1;
        Rprintf("Error: nlopt_set_stopval returned NLOPT_INVALID_ARGS.\n");
    }

    SEXP R_opts_ftol_rel;
    PROTECT( R_opts_ftol_rel = getListElement( R_options, "ftol_rel" ) );
    double ftol_rel = REAL( R_opts_ftol_rel )[0];
    res = nlopt_set_ftol_rel(opts, ftol_rel);
    if ( res == NLOPT_INVALID_ARGS ) {
        *flag_encountered_error = 1;
        Rprintf("Error: nlopt_set_ftol_rel returned NLOPT_INVALID_ARGS.\n");
    }
    
    SEXP R_opts_ftol_abs;
    PROTECT( R_opts_ftol_abs = getListElement( R_options, "ftol_abs" ) );
    double ftol_abs = REAL( R_opts_ftol_abs )[0];
    res = nlopt_set_ftol_abs(opts, ftol_abs);
    if ( res == NLOPT_INVALID_ARGS ) {
        *flag_encountered_error = 1;
        Rprintf("Error: nlopt_set_ftol_abs returned NLOPT_INVALID_ARGS.\n");
    }
    
    SEXP R_opts_xtol_rel;
    PROTECT( R_opts_xtol_rel = getListElement( R_options, "xtol_rel" ) );
    double xtol_rel = REAL( R_opts_xtol_rel )[0];
    res = nlopt_set_xtol_rel(opts, xtol_rel);
    if ( res == NLOPT_INVALID_ARGS ) {
        *flag_encountered_error = 1;
        Rprintf("Error: nlopt_set_xtol_rel returned NLOPT_INVALID_ARGS.\n");
    }
    
    SEXP R_opts_xtol_abs;
    PROTECT( R_opts_xtol_abs = getListElement( R_options, "xtol_abs" ) );
    double xtol_abs[ num_controls ];
    int i;    
    for (i=0;i<num_controls;i++) {
        xtol_abs[ i ] = REAL( R_opts_xtol_abs )[0];
    }
    res = nlopt_set_xtol_abs(opts, xtol_abs);
    if ( res == NLOPT_INVALID_ARGS ) {
        *flag_encountered_error = 1;
        Rprintf("Error: nlopt_set_xtol_abs returned NLOPT_INVALID_ARGS.\n");
    }
    
    SEXP R_opts_maxeval;
    PROTECT( R_opts_maxeval = AS_INTEGER( getListElement( R_options, "maxeval" ) ) );
    int maxeval = INTEGER( R_opts_maxeval )[0];
    res = nlopt_set_maxeval(opts, maxeval);
    if ( res == NLOPT_INVALID_ARGS ) {
        *flag_encountered_error = 1;
        Rprintf("Error: nlopt_set_maxeval returned NLOPT_INVALID_ARGS.\n");
    }
    
    SEXP R_opts_maxtime;
    PROTECT( R_opts_maxtime = getListElement( R_options, "maxtime" ) );
    double maxtime = REAL( R_opts_maxtime )[0];
    res = nlopt_set_maxtime(opts, maxtime);
    if ( res == NLOPT_INVALID_ARGS ) {
        *flag_encountered_error = 1;
        Rprintf("Error: nlopt_set_maxtime returned NLOPT_INVALID_ARGS.\n");
    }
    
    SEXP R_opts_population;
    PROTECT( R_opts_population = AS_INTEGER( getListElement( R_options, "population" ) ) );
    unsigned int population = INTEGER( R_opts_population )[0];
    res = nlopt_set_population(opts, population);
    if ( res == NLOPT_INVALID_ARGS ) {
        *flag_encountered_error = 1;
        Rprintf("Error: nlopt_set_population returned NLOPT_INVALID_ARGS.\n");
    }
    
    SEXP R_opts_ranseed;
    PROTECT( R_opts_ranseed = AS_INTEGER( getListElement( R_options, "ranseed" ) ) );
    unsigned long ranseed = INTEGER( R_opts_ranseed )[0];
    // set random seed if ranseed > 0.
    // by default a random seed is generated from system time.
    if ( ranseed > 0 ) {
        nlopt_srand(ranseed);
    }
    UNPROTECT( 11 );

    return opts;
}
 
 SEXP convertStatusToMessage( nlopt_result status ) {
    // convert message to an R object
    SEXP R_status_message;
    PROTECT(R_status_message = allocVector(STRSXP, 1));
    switch ( status )
    {
        // Successful termination (positive return values):
        
        // (= +1)
        case NLOPT_SUCCESS:
            SET_STRING_ELT(R_status_message, 0, mkChar("NLOPT_SUCCESS: Generic success return value."));
            break;
        // (= +2)   
        case NLOPT_STOPVAL_REACHED:
            SET_STRING_ELT(R_status_message, 0, mkChar("NLOPT_STOPVAL_REACHED: Optimization stopped because stopval (above) was reached."));
            break;
        // (= +3)
        case NLOPT_FTOL_REACHED:
            SET_STRING_ELT(R_status_message, 0, mkChar("NLOPT_FTOL_REACHED: Optimization stopped because ftol_rel or ftol_abs (above) was reached."));
            break;
        // (= +4)
        case NLOPT_XTOL_REACHED:
            SET_STRING_ELT(R_status_message, 0, mkChar("NLOPT_XTOL_REACHED: Optimization stopped because xtol_rel or xtol_abs (above) was reached."));
            break;
        // (= +5)
        case NLOPT_MAXEVAL_REACHED:
            SET_STRING_ELT(R_status_message, 0, mkChar("NLOPT_MAXEVAL_REACHED: Optimization stopped because maxeval (above) was reached."));
            break;
        // (= +6)
        case NLOPT_MAXTIME_REACHED:
            SET_STRING_ELT(R_status_message, 0, mkChar("NLOPT_MAXTIME_REACHED: Optimization stopped because maxtime (above) was reached."));
            break;

        // Error codes (negative return values):

        // (= -1)
        case NLOPT_FAILURE:
            SET_STRING_ELT(R_status_message, 0, mkChar("NLOPT_FAILURE: Generic failure code."));
            break;
        // (= -2)
        case NLOPT_INVALID_ARGS:
            SET_STRING_ELT(R_status_message, 0, mkChar("NLOPT_INVALID_ARGS: Invalid arguments (e.g. lower bounds are bigger than upper bounds, an unknown algorithm was specified, etcetera)."));
            break;
        // (= -3)
        case NLOPT_OUT_OF_MEMORY:
            SET_STRING_ELT(R_status_message, 0, mkChar("NLOPT_OUT_OF_MEMORY: Ran out of memory."));
            break;
        // (= -4)
        case NLOPT_ROUNDOFF_LIMITED:
            SET_STRING_ELT(R_status_message, 0, mkChar("NLOPT_ROUNDOFF_LIMITED: Roundoff errors led to a breakdown of the optimization algorithm. In this case, the returned minimum may still be useful. (e.g. this error occurs in NEWUOA if one tries to achieve a tolerance too close to machine precision.)"));
            break;
        case NLOPT_FORCED_STOP:
            SET_STRING_ELT(R_status_message, 0, mkChar("Halted because of a forced termination: the user called nlopt_force_stop(opt) on the optimization's nlopt_opt object opt from the user's objective function."));
        default:
            SET_STRING_ELT(R_status_message, 0, mkChar("Return status not recognized."));
    }
    
    UNPROTECT( 1 );
    return R_status_message;
} 


//
// Constrained minimization
//
SEXP NLoptR_Optimize( SEXP args )
{
    // declare counter
    unsigned i;

    // declare nlopt_result, to capture error codes from setting options
    nlopt_result res;
    int flag_encountered_error = 0;
    
    // get initial values
    SEXP R_init_values;
    PROTECT( R_init_values = getListElement( args, "x0" ) );
    
    // number of control variables
    unsigned num_controls = length( R_init_values );
    
    // set initial values of the controls
    double x0[ num_controls ];
    for (i=0;i<num_controls;i++) {
        x0[i] = REAL( R_init_values )[i];
    }
    UNPROTECT( 1 );
    
    // get options
    SEXP R_options;
    PROTECT( R_options = getListElement( args, "options" ) );
    nlopt_opt opts = getOptions( R_options, num_controls, &flag_encountered_error );
    UNPROTECT( 1 );
    
    // get local options
    SEXP R_local_options;
    PROTECT( R_local_options = getListElement( args, "local_options" ) );
    if ( R_local_options != R_NilValue ) {
        // parse list with options
        nlopt_opt local_opts = getOptions( R_local_options, num_controls, &flag_encountered_error );
        
        // add local optimizer options to global options
        nlopt_set_local_optimizer(opts, local_opts);
    }
    UNPROTECT( 1 );
    
    // get print_level from options
    SEXP R_opts_print_level;
    PROTECT( R_opts_print_level = AS_INTEGER( getListElement( R_options, "print_level" ) ) );
    int print_level = INTEGER( R_opts_print_level )[0];
    UNPROTECT( 1 );
    
    // get lower and upper bounds
    SEXP R_lower_bounds, R_upper_bounds;
    PROTECT( R_lower_bounds = getListElement( args, "lower_bounds" ) );
    PROTECT( R_upper_bounds = getListElement( args, "upper_bounds" ) );
    
    // set the upper and lower bounds of the controls
    double lb[ num_controls ];
    double ub[ num_controls ];
    for (i=0;i<num_controls;i++) {
        lb[i] = REAL( R_lower_bounds )[i];                // lower bound
        ub[i] = REAL( R_upper_bounds )[i];                // upper bound
    }
    UNPROTECT( 2 );
    
    // add upper and lower bounds to options
    res = nlopt_set_lower_bounds(opts, lb);
    if ( res == NLOPT_INVALID_ARGS ) {
        flag_encountered_error = 1;
        Rprintf("Error: nlopt_set_lower_bounds returned NLOPT_INVALID_ARGS.\n");
    }
    res = nlopt_set_upper_bounds(opts, ub);
    if ( res == NLOPT_INVALID_ARGS ) {
        flag_encountered_error = 1;
        Rprintf("Error: nlopt_set_upper_bounds returned NLOPT_INVALID_ARGS.\n");
    }
    
    // get number of inequality constraints
    SEXP R_num_constraints_ineq;
    PROTECT( R_num_constraints_ineq = AS_INTEGER( getListElement( args, "num_constraints_ineq" ) ) );
    unsigned num_constraints_ineq = INTEGER( R_num_constraints_ineq )[0];
    UNPROTECT( 1 );
    
    // get number of equality constraints
    SEXP R_num_constraints_eq;
    PROTECT( R_num_constraints_eq = AS_INTEGER( getListElement( args, "num_constraints_eq" ) ) );
    unsigned num_constraints_eq = INTEGER( R_num_constraints_eq )[0];
    UNPROTECT( 1 );
    
    // get evaluation functions and environment
    SEXP R_eval_f, R_eval_g_ineq, R_eval_g_eq, R_environment;
    PROTECT( R_eval_f      = getListElement( args, "eval_f" ) );            // objective
    PROTECT( R_eval_g_ineq = getListElement( args, "eval_g_ineq" ) );       // inequality constraints
    PROTECT( R_eval_g_eq   = getListElement( args, "eval_g_eq" ) );         // equality constraints
    PROTECT( R_environment = getListElement( args, "nloptr_environment" ) );
    
    
    // define data to pass to objective function
    func_objective_data objfunc_data;
    objfunc_data.R_eval_f        = R_eval_f;
    objfunc_data.R_environment   = R_environment;
    objfunc_data.num_iterations  = 0;
    objfunc_data.print_level     = print_level;
    
    // add objective to options
    res = nlopt_set_min_objective(opts, func_objective, &objfunc_data);
    if ( res == NLOPT_INVALID_ARGS ) {
        flag_encountered_error = 1;
        Rprintf("Error: nlopt_set_min_objective returned NLOPT_INVALID_ARGS.\n");
    }
    
    //
    // inequality constraints
    //
    
    // Declare data outside if-statement to prevent data corruption.
    func_constraints_ineq_data ineq_constr_data;
    if ( num_constraints_ineq > 0 ) {
    
        // get tolerances from R_options
        double tol_constraints_ineq[ num_constraints_ineq ];
        SEXP R_tol_constraints_ineq;
        PROTECT( R_tol_constraints_ineq = getListElement( R_options, "tol_constraints_ineq" ) );
        for (i=0;i<num_constraints_ineq;i++) {
            tol_constraints_ineq[ i ] = REAL( R_tol_constraints_ineq )[ i ];
        }
        UNPROTECT( 1 );
        
        // define data to pass to constraint function    
        ineq_constr_data.R_eval_g       = R_eval_g_ineq;
        ineq_constr_data.R_environment  = R_environment;
        ineq_constr_data.print_level    = print_level;
        
        // add vector-valued inequality constraint
        res = nlopt_add_inequality_mconstraint(opts, num_constraints_ineq, func_constraints_ineq, &ineq_constr_data, tol_constraints_ineq);
        if ( res == NLOPT_INVALID_ARGS ) {
            flag_encountered_error = 1;
            Rprintf("Error: nlopt_add_inequality_mconstraint returned NLOPT_INVALID_ARGS.\n");
        }
    }
    
    //
    // equality constraints
    //
    
    // Declare data outside if-statement to prevent data corruption.
    func_constraints_eq_data eq_constr_data;
    if ( num_constraints_eq > 0 ) {
    
        // get tolerances from R_options
        double tol_constraints_eq[ num_constraints_eq ];
        SEXP R_tol_constraints_eq;
        PROTECT( R_tol_constraints_eq = getListElement( R_options, "tol_constraints_eq" ) );
        for (i=0;i<num_constraints_eq;i++) {
            tol_constraints_eq[ i ] = REAL( R_tol_constraints_eq )[ i ];
        }
        UNPROTECT( 1 );
    
        // define data to pass to constraint function    
        eq_constr_data.R_eval_g       = R_eval_g_eq;
        eq_constr_data.R_environment  = R_environment;
        eq_constr_data.print_level    = print_level;
        
        // add vector-valued equality constraint
        res = nlopt_add_equality_mconstraint(opts, num_constraints_eq, func_constraints_eq, &eq_constr_data, tol_constraints_eq);
        if ( res == NLOPT_INVALID_ARGS ) {
            flag_encountered_error = 1;
            Rprintf("Error: nlopt_add_equality_mconstraint returned NLOPT_INVALID_ARGS.\n");
        }
    }
    
    // optimal value of objective value, upon return
    double obj_value = HUGE_VAL; 

    // do optimization, if no error occurred during initialization of the problem
    nlopt_result status;
    if ( flag_encountered_error==0 ) {
        status = nlopt_optimize( opts, x0, &obj_value );
    }
    else {
        status = NLOPT_INVALID_ARGS;
    }
    
    // dispose of the nlopt_opt object
    nlopt_destroy( opts );
    
    // after minimizing we can unprotect eval_f, eval_g_ineq, eval_g_eq, and the environment
    UNPROTECT( 4 );
    
    // get version of NLopt
    int major, minor, bugfix;
    nlopt_version(&major, &minor, &bugfix);

    // create list to return results to R
    int num_return_elements = 8;
    SEXP R_result_list;
    PROTECT(R_result_list = allocVector(VECSXP, num_return_elements));
        
    // attach names to the return list
    SEXP names;
    PROTECT(names = allocVector(STRSXP, num_return_elements));
    
    SET_STRING_ELT(names, 0, mkChar("status"));
    SET_STRING_ELT(names, 1, mkChar("message"));
    SET_STRING_ELT(names, 2, mkChar("iterations"));
    SET_STRING_ELT(names, 3, mkChar("objective"));
    SET_STRING_ELT(names, 4, mkChar("solution"));
    SET_STRING_ELT(names, 5, mkChar("version_major"));
    SET_STRING_ELT(names, 6, mkChar("version_minor"));
    SET_STRING_ELT(names, 7, mkChar("version_bugfix"));
    setAttrib(R_result_list, R_NamesSymbol, names);
    
    // convert status to an R object
    SEXP R_status;
    PROTECT(R_status = allocVector(INTSXP,1));
    INTEGER(R_status)[0] = (int) status;
    
    // convert message to an R object
    SEXP R_status_message;
    PROTECT( R_status_message = convertStatusToMessage( status ) );
    
    // convert number of iterations to an R object
    SEXP R_num_iterations;
    PROTECT(R_num_iterations = allocVector(INTSXP,1));
    INTEGER(R_num_iterations)[0] = objfunc_data.num_iterations;
    
    // convert value of objective function to an R object
    SEXP R_objective;
    PROTECT(R_objective = allocVector(REALSXP,1));
    REAL(R_objective)[0] = obj_value;
    
    // convert the value of the controls to an R object
    SEXP R_solution;
    PROTECT(R_solution = allocVector(REALSXP,num_controls));
    for (i=0;i<num_controls;i++) {
        REAL(R_solution)[i] = x0[i];
    }
    
    // convert the major version number to an R object
    SEXP R_version_major;
    PROTECT(R_version_major = allocVector(INTSXP,1));
    INTEGER(R_version_major)[0] = major;
    
    // convert the minor version number to an R object
    SEXP R_version_minor;
    PROTECT(R_version_minor = allocVector(INTSXP,1));
    INTEGER(R_version_minor)[0] = minor;
    
    // convert the bugfix version number to an R object
    SEXP R_version_bugfix;
    PROTECT(R_version_bugfix = allocVector(INTSXP,1));
    INTEGER(R_version_bugfix)[0] = bugfix;
    
    // add elements to the list
    SET_VECTOR_ELT(R_result_list, 0, R_status);
    SET_VECTOR_ELT(R_result_list, 1, R_status_message);
    SET_VECTOR_ELT(R_result_list, 2, R_num_iterations);
    SET_VECTOR_ELT(R_result_list, 3, R_objective);
    SET_VECTOR_ELT(R_result_list, 4, R_solution);
    SET_VECTOR_ELT(R_result_list, 5, R_version_major);
    SET_VECTOR_ELT(R_result_list, 6, R_version_minor);
    SET_VECTOR_ELT(R_result_list, 7, R_version_bugfix);
    
    UNPROTECT( num_return_elements + 2 );

    return(R_result_list);
}
