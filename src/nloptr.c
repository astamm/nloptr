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
 * 2011-01-13: added print_level option
 * 2011-07-24: added checks on return value when setting equality constraints
 *  etc.
 * 2013-11-05: Moved declaration of ineq_constr_data and eq_constr_data outside
 *  if-statement to solve segfault on Ubuntu.
 * 2024-07-02: Updated old include which is no longer maintained and other
 *  minor code tweaks and efficiency enhancements (Avraham Adler).
 */

// TODO: add minimize/maximize option (objective = "maximize")
// nlopt_result nlopt_set_min_objective(nlopt_opt opt, nlopt_func f, void*
// f_data); nlopt_result nlopt_set_max_objective(nlopt_opt opt, nlopt_func f,
// void* f_data);

#include "nloptr.h"
#include <stdbool.h>

SEXP getListElement(SEXP list, char *str) {
  SEXP elmt = R_NilValue, names = getAttrib(list, R_NamesSymbol);
  PROTECT(names);
  for (size_t i = 0; i < length(list); i++) {
    if (strcmp(CHAR(STRING_ELT(names, i)), str) == 0) {
      elmt = VECTOR_ELT(list, i);
      break;
    }
  }
  UNPROTECT(1);
  return elmt;
}

// The algtable table must be in sorted order for bsearch to work properly.
ALGPAIR algtable[] = {
    {"NLOPT_GD_MLSL", 1},
    {"NLOPT_GD_MLSL_LDS", 2},
    {"NLOPT_GD_STOGO", 3},
    {"NLOPT_GD_STOGO_RAND", 4},
    {"NLOPT_GN_CRS2_LM", 5},
    {"NLOPT_GN_DIRECT", 6},
    {"NLOPT_GN_DIRECT_L", 7},
    {"NLOPT_GN_DIRECT_L_NOSCAL", 8},
    {"NLOPT_GN_DIRECT_L_RAND", 9},
    {"NLOPT_GN_DIRECT_L_RAND_NOSCAL", 10},
    {"NLOPT_GN_DIRECT_NOSCAL", 11},
    {"NLOPT_GN_ESCH", 12},
    {"NLOPT_GN_ISRES", 13},
    {"NLOPT_GN_MLSL", 14},
    {"NLOPT_GN_MLSL_LDS", 15},
    {"NLOPT_GN_ORIG_DIRECT", 16},
    {"NLOPT_GN_ORIG_DIRECT_L", 17},
    {"NLOPT_LD_AUGLAG", 18},
    {"NLOPT_LD_AUGLAG_EQ", 19},
    {"NLOPT_LD_CCSAQ", 20},
    {"NLOPT_LD_LBFGS", 21},
    {"NLOPT_LD_LBFGS_NOCEDAL", 22},
    {"NLOPT_LD_MMA", 23},
    {"NLOPT_LD_SLSQP", 24},
    {"NLOPT_LD_TNEWTON", 25},
    {"NLOPT_LD_TNEWTON_PRECOND", 26},
    {"NLOPT_LD_TNEWTON_PRECOND_RESTART", 27},
    {"NLOPT_LD_TNEWTON_RESTART", 28},
    {"NLOPT_LD_VAR1", 29},
    {"NLOPT_LD_VAR2", 30},
    {"NLOPT_LN_AUGLAG", 31},
    {"NLOPT_LN_AUGLAG_EQ", 32},
    {"NLOPT_LN_BOBYQA", 33},
    {"NLOPT_LN_COBYLA", 34},
    {"NLOPT_LN_NELDERMEAD", 35},
    {"NLOPT_LN_NEWUOA", 36},
    {"NLOPT_LN_NEWUOA_BOUND", 37},
    {"NLOPT_LN_PRAXIS", 38},
    {"NLOPT_LN_SBPLX", 39},
};

static int compAlg(const void *va, const void *vb) {
  const ALGPAIR *a = va, *b = vb;
  return strcmp(a->key, b->key);
}

int getVal(char *key) {
  ALGPAIR key_pair[1] = {{key}};
  ALGPAIR *pair =
      bsearch(key_pair, algtable, sizeof algtable / sizeof algtable[0],
              sizeof algtable[0], compAlg);
  return pair ? pair->value : -1;
}

nlopt_algorithm getAlgorithmCode(const char *algorithm_str) {

  nlopt_algorithm algorithm;

  switch (getVal((char *)algorithm_str)) {
  case 1:
    algorithm = NLOPT_GD_MLSL;
    break;
  case 2:
    algorithm = NLOPT_GD_MLSL_LDS;
    break;
  case 3:
    algorithm = NLOPT_GD_STOGO;
    break;
  case 4:
    algorithm = NLOPT_GD_STOGO_RAND;
    break;
  case 5:
    algorithm = NLOPT_GN_CRS2_LM;
    break;
  case 6:
    algorithm = NLOPT_GN_DIRECT;
    break;
  case 7:
    algorithm = NLOPT_GN_DIRECT_L;
    break;
  case 8:
    algorithm = NLOPT_GN_DIRECT_L_NOSCAL;
    break;
  case 9:
    algorithm = NLOPT_GN_DIRECT_L_RAND;
    break;
  case 10:
    algorithm = NLOPT_GN_DIRECT_L_RAND_NOSCAL;
    break;
  case 11:
    algorithm = NLOPT_GN_DIRECT_NOSCAL;
    break;
  case 12:
    algorithm = NLOPT_GN_ESCH;
    break;
  case 13:
    algorithm = NLOPT_GN_ISRES;
    break;
  case 14:
    algorithm = NLOPT_GN_MLSL;
    break;
  case 15:
    algorithm = NLOPT_GN_MLSL_LDS;
    break;
  case 16:
    algorithm = NLOPT_GN_ORIG_DIRECT;
    break;
  case 17:
    algorithm = NLOPT_GN_ORIG_DIRECT_L;
    break;
  case 18:
    algorithm = NLOPT_LD_AUGLAG;
    break;
  case 19:
    algorithm = NLOPT_LD_AUGLAG_EQ;
    break;
  case 20:
    algorithm = NLOPT_LD_CCSAQ;
    break;
  case 21:
    algorithm = NLOPT_LD_LBFGS;
    break;
  case 22: // #nocov start
#ifdef HAVE_NLOPT_LD_LBFGS_NOCEDAL
    algorithm = NLOPT_LD_LBFGS_NOCEDAL;
#else
    algorithm = NLOPT_LD_LBFGS;
#endif
    break; // #nocov end
  case 23:
    algorithm = NLOPT_LD_MMA;
    break;
  case 24:
    algorithm = NLOPT_LD_SLSQP;
    break;
  case 25:
    algorithm = NLOPT_LD_TNEWTON;
    break;
  case 26:
    algorithm = NLOPT_LD_TNEWTON_PRECOND;
    break;
  case 27:
    algorithm = NLOPT_LD_TNEWTON_PRECOND_RESTART;
    break;
  case 28:
    algorithm = NLOPT_LD_TNEWTON_RESTART;
    break;
  case 29:
    algorithm = NLOPT_LD_VAR1;
    break;
  case 30:
    algorithm = NLOPT_LD_VAR2;
    break;
  case 31:
    algorithm = NLOPT_LN_AUGLAG;
    break;
  case 32:
    algorithm = NLOPT_LN_AUGLAG_EQ;
    break;
  case 33:
    algorithm = NLOPT_LN_BOBYQA;
    break;
  case 34:
    algorithm = NLOPT_LN_COBYLA;
    break;
  case 35:
    algorithm = NLOPT_LN_NELDERMEAD;
    break;
  case 36:
    algorithm = NLOPT_LN_NEWUOA;
    break;
  case 37:
    algorithm = NLOPT_LN_NEWUOA_BOUND;
    break;
  case 38:
    algorithm = NLOPT_LN_PRAXIS;
    break;
  case 39:
    algorithm = NLOPT_LN_SBPLX;
    break;
  // # nocov start (Guarded against by is.nloptr lines 81–85.)
  default:
    // unknown algorithm code
    Rprintf("Error: unknown algorithm %s.\n", algorithm_str);
    // Not an algorithm, so this should result in a runtime error.
    algorithm = NLOPT_NUM_ALGORITHMS;
    // # nocov end
  }

  return algorithm;
}

double func_objective(unsigned n, const double *x, double *grad, void *data) {
  // Return the value, and the gradient if necessary, of the objective function.

  // Check for user interruption from R.
  R_CheckUserInterrupt();

  func_objective_data *d = (func_objective_data *)data;

  // Increase number of function evaluations.
  d->num_iterations++;

  // Print status.
  if (d->print_level >= 1) {
    Rprintf("iteration: %zu\n", d->num_iterations);
  }

  // Print values of x.
  if (d->print_level >= 3) {
    if (n == 1) {
      Rprintf("\tx = %f\n", x[0]);
    } else {
      Rprintf("\tx = (%f", x[0]);
      for (size_t i = 1; i < n; i++) {
        Rprintf(", %f", x[i]);
      }
      Rprintf(")\n");
    }
  }

  // Allocate memory for a vector of reals. This vector will contain the
  // elements of x, where x is the argument to the R function R_eval_f.
  SEXP rargs = allocVector(REALSXP, n);
  double *prargs = REAL(rargs);
  for (size_t i = 0; i < n; i++) {
    prargs[i] = x[i];
  }

  // Evaluate R function R_eval_f with the control x as an argument.
  SEXP Rcall = PROTECT(lang2(d->R_eval_f, rargs));
  SEXP result = PROTECT(eval(Rcall, d->R_environment));

  // Recode the return value from SEXP to double.
  double obj_value;
  if (isNumeric(result)) {
    // Objective value is the only element of "result".
    obj_value = asReal(result);
  } else {
    // Objective value needs to be extracted from the list of return values.
    SEXP R_obj_value = PROTECT(getListElement(result, "objective"));

    // Recode the return value from SEXP to double.
    obj_value = asReal(R_obj_value);

    UNPROTECT(1);
  }

  // Print objective value.
  if (d->print_level >= 1) {
    Rprintf("\tf(x) = %f\n", obj_value);
  }

  // Handle gradient.
  if (grad) {
    // result needs to be a list in this case
    SEXP R_gradient = PROTECT(getListElement(result, "gradient"));

    // Recode the return value from SEXP to double.
    double *pRgrad = REAL(R_gradient);
    for (size_t i = 0; i < n; i++) {
      grad[i] = pRgrad[i];
    }

    UNPROTECT(1);
  }

  UNPROTECT(2);

  return obj_value;
}

void func_constraints_ineq(unsigned m, double *constraints, unsigned n,
                           const double *x, double *grad, void *data) {
  // Return the value (and the Jacobian) of the constraints.

  // Check for user interruption from R.
  R_CheckUserInterrupt();

  func_constraints_ineq_data *d = (func_constraints_ineq_data *)data;

  // Allocate memory for a vector of reals. This vector will contain the
  // elements of x, where x is the argument to the R function R_eval_f.
  SEXP rargs_x = allocVector(REALSXP, n);
  double *prargsx = REAL(rargs_x);
  for (size_t i = 0; i < n; i++) {
    prargsx[i] = x[i];
  }

  // Evaluate R function R_eval_g with the control x as an argument.
  SEXP Rcall = PROTECT(lang2(d->R_eval_g, rargs_x));
  SEXP result = PROTECT(eval(Rcall, d->R_environment));

  // Get the value of the constraint from the result.
  if (isNumeric(result)) {
    // Constraint values are the only element of result. so recode the return
    // value from SEXP to double*, by looping over constraints.
    double *presult = REAL(result);
    for (size_t i = 0; i < m; i++) {
      constraints[i] = presult[i];
    }
  } else {
    // Constraint value should be extracted from the list of return values.
    SEXP R_constraints = PROTECT(getListElement(result, "constraints"));

    // Recode the return value from SEXP to double by looping over constraints.
    double *pRconst = REAL(R_constraints);
    for (size_t i = 0; i < m; i++) {
      constraints[i] = pRconst[i];
    }

    UNPROTECT(1);
  }

  // Prsize_t inequality constraints.
  if (d->print_level >= 2) {
    if (m == 1) {
      Rprintf("\tg(x) = %f\n", constraints[0]);
    } else {
      Rprintf("\tg(x) = (%f", constraints[0]);
      for (size_t i = 1; i < m; i++) {
        Rprintf(", %f", constraints[i]);
      }
      Rprintf(")\n");
    }
  }

  // Get the value of the gradient if needed.
  if (grad) {
    // Result needs to be a list in this case.
    SEXP R_gradient = PROTECT(getListElement(result, "jacobian"));

    /*
     * recode the return value from SEXP to double*, by looping over variables
     * and constraints We get a matrix from R with the Jacobian of the
     * constraints
     *  / dc_1/dx_1   dc_1/dx_2  ...  dc_1/dx_n \
     * |  dc_2/dx_1   dc_2/dx_2  ...  dc_2/dx_n  |
     * |     ...         ...             ...     |
     *  \ dc_m/dx_1   dc_m/dx_2  ...  dc_m/dx_n /
     * Matrices are stored column-wise, so basically we get a vector
     * [dc_1/dx_1, dc_2/dx_1, ..., dc_m/dx_1, dc_1/dx_2, dc_2/dx_2, ...,
     * dc_m/dx_2, ..., dc_1/dx_n, dc_2/dx_n, ..., dc_m/dx_n] which we have to
     * convert to a row-wise format for NLopt.
     */

    double *pRgrad = REAL(R_gradient);
    for (size_t i = 0; i < m; i++) {
      size_t ni = i * n;
      for (size_t j = 0; j < n; j++) {
        grad[ni + j] = pRgrad[j * m + i];
      }
    }

    UNPROTECT(1);
  }

  UNPROTECT(2);
}

void func_constraints_eq(unsigned m, double *constraints, unsigned n,
                         const double *x, double *grad, void *data) {
  // Return the value (and the Jacobian) of the constraints.

  // Check for user interruption from R.
  R_CheckUserInterrupt();

  func_constraints_eq_data *d = (func_constraints_eq_data *)data;

  // Allocate memory for a vector of reals. This vector will contain the
  // elements of x, where x is the argument to the R function R_eval_f.
  SEXP rargs_x = allocVector(REALSXP, n);
  double *prargsx = REAL(rargs_x);
  for (size_t i = 0; i < n; i++) {
    prargsx[i] = x[i];
  }

  // Evaluate R function R_eval_g with the control x as an argument.
  SEXP Rcall = PROTECT(lang2(d->R_eval_g, rargs_x));
  SEXP result = PROTECT(eval(Rcall, d->R_environment));

  // Get the value of the constraint from the result.
  if (isNumeric(result)) {
    // Constraint values are the only element of result, so recode the return
    // value from SEXP to double*, by looping over constraints.
    double *presult = REAL(result);
    for (size_t i = 0; i < m; i++) {
      constraints[i] = presult[i];
    }
  } else {
    // Constraint value should be extracted from the list of return values.
    SEXP R_constraints = PROTECT(getListElement(result, "constraints"));

    // Recode the return value from SEXP to double by looping over constraints.
    double *pRconst = REAL(R_constraints);
    for (size_t i = 0; i < m; i++) {
      constraints[i] = pRconst[i];
    }

    UNPROTECT(1);
  }

  // Print equality constraints.
  if (d->print_level >= 2) {
    if (m == 1) {
      Rprintf("\th(x) = %f\n", constraints[0]);
    } else {
      Rprintf("\th(x) = (%f", constraints[0]);
      for (size_t i = 1; i < m; i++) {
        Rprintf(", %f", constraints[i]);
      }

      Rprintf(")\n");
    }
  }

  // Get the value of the gradient if needed.
  if (grad) {
    // Result needs to be a list in this case.
    SEXP R_gradient = PROTECT(getListElement(result, "jacobian"));

    /*
     * recode the return value from SEXP to double*, by looping over variables
     * and constraints We get a matrix from R with the Jacobian of the
     * constraints
     *  / dc_1/dx_1   dc_1/dx_2  ...  dc_1/dx_n \
     * |  dc_2/dx_1   dc_2/dx_2  ...  dc_2/dx_n  |
     * |     ...         ...             ...     |
     *  \ dc_m/dx_1   dc_m/dx_2  ...  dc_m/dx_n /
     * Matrices are stored column-wise, so basically we get a vector
     * [dc_1/dx_1, dc_2/dx_1, ..., dc_m/dx_1, dc_1/dx_2, dc_2/dx_2, ...,
     * dc_m/dx_2, ..., dc_1/dx_n, dc_2/dx_n, ..., dc_m/dx_n] which we have to
     * convert to a row-wise format for NLopt.
     */

    double *pRgrad = REAL(R_gradient);
    for (size_t i = 0; i < m; i++) {
      size_t ni = i * n;
      for (size_t j = 0; j < n; j++) {
        grad[ni + j] = pRgrad[j * m + i];
      }
    }

    UNPROTECT(1);
  }

  UNPROTECT(2);
}

int parse_integer_option(SEXP R_options, char *name) {
  SEXP R_value = PROTECT(getListElement(R_options, name));
  int value = asInteger(R_value);
  UNPROTECT(1);
  return value;
}

double parse_real_option(SEXP R_options, char *name) {
  SEXP R_value = PROTECT(getListElement(R_options, name));
  double value = asReal(R_value);
  UNPROTECT(1);
  return value;
}

unsigned int parse_vector_length_option(SEXP R_options, char *name) {
  SEXP R_value = PROTECT(getListElement(R_options, name));
  unsigned int n = length(R_value);
  UNPROTECT(1);
  return n;
}

double *parse_real_vector_option(SEXP R_options, char *name) {
  SEXP R_value = PROTECT(getListElement(R_options, name));
  unsigned int n = length(R_value);
  double *value = REAL(R_value);
  UNPROTECT(1);
  return value;
}

nlopt_opt getOptions(SEXP R_options, int num_controls,
                     int *flag_encountered_error) {
  // Declare nlopt_result to capture error codes from setting options.
  nlopt_result res;

  // Get the algorithm from options.
  SEXP R_algorithm = PROTECT(getListElement(R_options, "algorithm"));

  // R_algorithm_str will contain the first (should be the only one) element of
  // the list.
  SEXP R_algorithm_str = PROTECT(STRING_ELT(R_algorithm, 0));
  const char *algorithm_str = CHAR(R_algorithm_str);
  nlopt_algorithm algorithm = getAlgorithmCode(algorithm_str);

  UNPROTECT(2);

  // Declare options.
  nlopt_opt opts =
      nlopt_create(algorithm, num_controls); // algorithm and dimensionality

  // Get other options.
  // Stop when f(x) <= stopval for minimizing or >= stopval for maximizing.
  double stopval = parse_real_option(R_options, "stopval");
  res = nlopt_set_stopval(opts, stopval);
  if (res == NLOPT_INVALID_ARGS) {
    *flag_encountered_error = 1;
    Rprintf("Error: nlopt_set_stopval returned NLOPT_INVALID_ARGS.\n");
  }

  double ftol_rel = parse_real_option(R_options, "ftol_rel");
  res = nlopt_set_ftol_rel(opts, ftol_rel);
  if (res == NLOPT_INVALID_ARGS) {
    *flag_encountered_error = 1;
    Rprintf("Error: nlopt_set_ftol_rel returned NLOPT_INVALID_ARGS.\n");
  }

  double ftol_abs = parse_real_option(R_options, "ftol_abs");
  res = nlopt_set_ftol_abs(opts, ftol_abs);
  if (res == NLOPT_INVALID_ARGS) {
    *flag_encountered_error = 1;
    Rprintf("Error: nlopt_set_ftol_abs returned NLOPT_INVALID_ARGS.\n");
  }

  double xtol_rel = parse_real_option(R_options, "xtol_rel");
  res = nlopt_set_xtol_rel(opts, xtol_rel);
  if (res == NLOPT_INVALID_ARGS) {
    *flag_encountered_error = 1;
    Rprintf("Error: nlopt_set_xtol_rel returned NLOPT_INVALID_ARGS.\n");
  }

  unsigned int num_x_weights =
      parse_vector_length_option(R_options, "x_weights");
  if (num_x_weights == 0) {
    *flag_encountered_error = 1;
    Rprintf("Error: x_weights must have either length 1 or length equal to the "
            "number of controls.\n");
  } else if (num_x_weights == 1) {
    double x_weights = parse_real_option(R_options, "x_weights");
    res = nlopt_set_x_weights1(opts, x_weights);
  } else {
    if (num_x_weights != num_controls) {
      *flag_encountered_error = 1;
      Rprintf("Error: x_weights must have either length 1 or length equal to "
              "the number of controls.\n");
    }
    double *x_weights = parse_real_vector_option(R_options, "x_weights");
    res = nlopt_set_x_weights(opts, x_weights);
  }
  if (res == NLOPT_INVALID_ARGS) {
    *flag_encountered_error = 1;
    Rprintf("Error: nlopt_set_x_weights returned NLOPT_INVALID_ARGS.\n");
  }

  unsigned int num_xtol_abs = parse_vector_length_option(R_options, "xtol_abs");
  if (num_xtol_abs == 0) {
    *flag_encountered_error = 1;
    Rprintf("Error: xtol_abs must have either length 1 or length equal to the "
            "number of controls.\n");
  } else if (num_xtol_abs == 1) {
    double xtol_abs = parse_real_option(R_options, "xtol_abs");
    res = nlopt_set_xtol_abs1(opts, xtol_abs);
  } else {
    if (num_xtol_abs != num_controls) {
      *flag_encountered_error = 1;
      Rprintf("Error: xtol_abs must have either length 1 or length equal to "
              "the number of controls.\n");
    }
    double *xtol_abs = parse_real_vector_option(R_options, "xtol_abs");
    res = nlopt_set_xtol_abs(opts, xtol_abs);
  }
  if (res == NLOPT_INVALID_ARGS) {
    *flag_encountered_error = 1;
    Rprintf("Error: nlopt_set_xtol_abs returned NLOPT_INVALID_ARGS.\n");
  }

  int maxeval = parse_integer_option(R_options, "maxeval");
  res = nlopt_set_maxeval(opts, maxeval);
  if (res == NLOPT_INVALID_ARGS) {
    *flag_encountered_error = 1;
    Rprintf("Error: nlopt_set_maxeval returned NLOPT_INVALID_ARGS.\n");
  }

  double maxtime = parse_real_option(R_options, "maxtime");
  res = nlopt_set_maxtime(opts, maxtime);
  if (res == NLOPT_INVALID_ARGS) {
    *flag_encountered_error = 1;
    Rprintf("Error: nlopt_set_maxtime returned NLOPT_INVALID_ARGS.\n");
  }

  unsigned int population = parse_integer_option(R_options, "population");
  res = nlopt_set_population(opts, population);
  if (res == NLOPT_INVALID_ARGS) {
    *flag_encountered_error = 1;
    Rprintf("Error: nlopt_set_population returned NLOPT_INVALID_ARGS.\n");
  }

  unsigned int vector_storage =
      parse_integer_option(R_options, "vector_storage");
  res = nlopt_set_vector_storage(opts, vector_storage);
  if (res == NLOPT_INVALID_ARGS) {
    *flag_encountered_error = 1;
    Rprintf("Error: nlopt_set_vector_storage returned NLOPT_INVALID_ARGS.\n");
  }

  unsigned long ranseed = parse_integer_option(R_options, "ranseed");
  // Set random seed if ranseed > 0. By default a random seed is generated from
  // system time.
  if (ranseed > 0) {
    nlopt_srand(ranseed);
  }

  return opts;
}

SEXP convertStatusToMessage(nlopt_result status) {
  // Convert message to an R object.
  SEXP R_status_message = PROTECT(allocVector(STRSXP, 1));
  switch (status) {
  // Successful termination (positive return values):

  // (= +1)
  case NLOPT_SUCCESS:
    SET_STRING_ELT(R_status_message, 0,
                   mkChar("NLOPT_SUCCESS: Generic success return value."));
    break;
  // (= +2)
  case NLOPT_STOPVAL_REACHED:
    SET_STRING_ELT(R_status_message, 0,
                   mkChar("NLOPT_STOPVAL_REACHED: Optimization stopped because "
                          "stopval (above) was reached."));
    break;
  // (= +3)
  case NLOPT_FTOL_REACHED:
    SET_STRING_ELT(R_status_message, 0,
                   mkChar("NLOPT_FTOL_REACHED: Optimization stopped because "
                          "ftol_rel or ftol_abs (above) was reached."));
    break;
  // (= +4)
  case NLOPT_XTOL_REACHED:
    SET_STRING_ELT(R_status_message, 0,
                   mkChar("NLOPT_XTOL_REACHED: Optimization stopped because "
                          "xtol_rel or xtol_abs (above) was reached."));
    break;
  // (= +5)
  case NLOPT_MAXEVAL_REACHED:
    SET_STRING_ELT(R_status_message, 0,
                   mkChar("NLOPT_MAXEVAL_REACHED: Optimization stopped because "
                          "maxeval (above) was reached."));
    break;
  // (= +6)
  case NLOPT_MAXTIME_REACHED:
    SET_STRING_ELT(R_status_message, 0,
                   mkChar("NLOPT_MAXTIME_REACHED: Optimization stopped because "
                          "maxtime (above) was reached."));
    break;
  // Error codes (negative return values):

  // (= -1)
  case NLOPT_FAILURE:
    SET_STRING_ELT(R_status_message, 0,
                   mkChar("NLOPT_FAILURE: Generic failure code."));
    break;
  // (= -2)
  case NLOPT_INVALID_ARGS:
    SET_STRING_ELT(R_status_message, 0,
                   mkChar("NLOPT_INVALID_ARGS: Invalid arguments (e.g. lower "
                          "bounds are bigger than upper bounds, an unknown "
                          "algorithm was specified, etcetera)."));
    break;
  // (= -3)
  case NLOPT_OUT_OF_MEMORY:
    SET_STRING_ELT(R_status_message, 0,
                   mkChar("NLOPT_OUT_OF_MEMORY: Ran out of memory."));
    break;
  // (= -4)
  case NLOPT_ROUNDOFF_LIMITED:
    SET_STRING_ELT(
        R_status_message, 0,
        mkChar(
            "NLOPT_ROUNDOFF_LIMITED: Roundoff errors led to a breakdown of the "
            "optimization algorithm. In this case, the returned minimum may "
            "still be useful. (e.g. this error occurs in NEWUOA if one tries "
            "to achieve a tolerance too close to machine precision.)"));
    break;
  // # nocov start  - Cannot test as the nlopt_force_stop() function is not
  // exposed to nloptr.
  case NLOPT_FORCED_STOP:
    SET_STRING_ELT(
        R_status_message, 0,
        mkChar("Halted because of a forced termination: the user called "
               "nlopt_force_stop(opt) on the optimization's nlopt_opt object "
               "opt from the user's objective function."));
    // # nocov end
  default:
    SET_STRING_ELT(R_status_message, 0,
                   mkChar("Return status not recognized."));
  }

  UNPROTECT(1);
  return R_status_message;
}

// Constrained minimization: main package function.
SEXP NLoptR_Optimize(SEXP args) {

  // Declare nlopt_result to capture error codes from setting options.
  nlopt_result res;
  int flag_encountered_error = 0;

  // Get initial values.
  SEXP R_init_values = PROTECT(getListElement(args, "x0"));

  // Number of control variables.
  unsigned int num_controls = length(R_init_values);

  // Set initial values of the controls.
  double x0[num_controls];
  double *pRinit = REAL(R_init_values);
  for (size_t i = 0; i < num_controls; i++) {
    x0[i] = pRinit[i];
  }
  UNPROTECT(1);

  // Get options.
  SEXP R_options = PROTECT(getListElement(args, "options"));
  nlopt_opt opts = getOptions(R_options, num_controls, &flag_encountered_error);

  // Get local options.
  SEXP R_local_options = PROTECT(getListElement(args, "local_options"));
  bool use_local_optimizer = R_local_options != R_NilValue;
  nlopt_opt local_opts = NULL;
  if (use_local_optimizer) {
    // Parse list with options.
    local_opts =
        getOptions(R_local_options, num_controls, &flag_encountered_error);

    // Add local optimizer options to global options.
    nlopt_set_local_optimizer(opts, local_opts);
  }
  UNPROTECT(1);

  // Get print_level from options.
  SEXP R_opts_print_level =
      PROTECT(AS_INTEGER(getListElement(R_options, "print_level")));
  int print_level = asInteger(R_opts_print_level);
  UNPROTECT(1);

  // Get lower and upper bounds.
  SEXP R_lower_bounds = PROTECT(getListElement(args, "lower_bounds"));
  SEXP R_upper_bounds = PROTECT(getListElement(args, "upper_bounds"));

  // Set the upper and lower bounds of the controls.
  double lb[num_controls];
  double ub[num_controls];
  double *pRlb = REAL(R_lower_bounds);
  double *pRub = REAL(R_upper_bounds);
  for (size_t i = 0; i < num_controls; i++) {
    lb[i] = pRlb[i]; // lower bound
    ub[i] = pRub[i]; // upper bound
  }
  UNPROTECT(2);

  // Add upper and lower bounds to options.
  res = nlopt_set_lower_bounds(opts, lb);
  if (res == NLOPT_INVALID_ARGS) {
    flag_encountered_error = 1;
    Rprintf("Error: nlopt_set_lower_bounds returned NLOPT_INVALID_ARGS.\n");
  }
  res = nlopt_set_upper_bounds(opts, ub);
  if (res == NLOPT_INVALID_ARGS) {
    flag_encountered_error = 1;
    Rprintf("Error: nlopt_set_upper_bounds returned NLOPT_INVALID_ARGS.\n");
  }

  // Get number of inequality constraints.
  SEXP R_num_constraints_ineq =
      PROTECT(AS_INTEGER(getListElement(args, "num_constraints_ineq")));
  unsigned num_constraints_ineq = asInteger(R_num_constraints_ineq);
  UNPROTECT(1);

  // Get number of equality constraints.
  SEXP R_num_constraints_eq =
      PROTECT(AS_INTEGER(getListElement(args, "num_constraints_eq")));
  unsigned num_constraints_eq = asInteger(R_num_constraints_eq);
  UNPROTECT(1);

  // Get evaluation functions and environment.
  SEXP R_eval_f = PROTECT(getListElement(args, "eval_f")); // objective
  SEXP R_eval_g_ineq =
      PROTECT(getListElement(args, "eval_g_ineq")); // inequality constraints
  SEXP R_eval_g_eq =
      PROTECT(getListElement(args, "eval_g_eq")); // equality constraints
  SEXP R_environment = PROTECT(getListElement(args, "nloptr_environment"));

  // Define data to pass to objective function.
  func_objective_data objfunc_data;
  objfunc_data.R_eval_f = R_eval_f;
  objfunc_data.R_environment = R_environment;
  objfunc_data.num_iterations = 0;
  objfunc_data.print_level = print_level;

  // Add objective to options.
  res = nlopt_set_min_objective(opts, func_objective, &objfunc_data);
  if (res == NLOPT_INVALID_ARGS) {
    flag_encountered_error = 1;
    Rprintf("Error: nlopt_set_min_objective returned NLOPT_INVALID_ARGS.\n");
  }

  // Inequality constraints

  // Declare data outside if-statement to prevent data corruption.
  func_constraints_ineq_data ineq_constr_data;
  if (num_constraints_ineq > 0) {
    // Get tolerances from R_options.
    double tol_constraints_ineq[num_constraints_ineq];
    SEXP R_tol_constraints_ineq =
        PROTECT(getListElement(R_options, "tol_constraints_ineq"));
    double *pRtolineqc = REAL(R_tol_constraints_ineq);
    for (size_t i = 0; i < num_constraints_ineq; i++) {
      tol_constraints_ineq[i] = pRtolineqc[i];
    }
    UNPROTECT(1);

    // Define data to pass to constraint function.
    ineq_constr_data.R_eval_g = R_eval_g_ineq;
    ineq_constr_data.R_environment = R_environment;
    ineq_constr_data.print_level = print_level;

    // Add vector-valued inequality constraint.
    res = nlopt_add_inequality_mconstraint(
        opts, num_constraints_ineq, func_constraints_ineq, &ineq_constr_data,
        tol_constraints_ineq);
    if (res == NLOPT_INVALID_ARGS) {
      flag_encountered_error = 1;
      Rprintf("Error: nlopt_add_inequality_mconstraint returned "
              "NLOPT_INVALID_ARGS.\n");
    }
  }

  // Equality constraints

  // Declare data outside if-statement to prevent data corruption.
  func_constraints_eq_data eq_constr_data;
  if (num_constraints_eq > 0) {
    // Get tolerances from R_options.
    double tol_constraints_eq[num_constraints_eq];
    SEXP R_tol_constraints_eq =
        PROTECT(getListElement(R_options, "tol_constraints_eq"));
    double *pRtoleqc = REAL(R_tol_constraints_eq);
    for (size_t i = 0; i < num_constraints_eq; i++) {
      tol_constraints_eq[i] = pRtoleqc[i];
    }
    UNPROTECT(1);

    // Define data to pass to constraint function.
    eq_constr_data.R_eval_g = R_eval_g_eq;
    eq_constr_data.R_environment = R_environment;
    eq_constr_data.print_level = print_level;

    // Add vector-valued equality constraint.
    res = nlopt_add_equality_mconstraint(opts, num_constraints_eq,
                                         func_constraints_eq, &eq_constr_data,
                                         tol_constraints_eq);
    if (res == NLOPT_INVALID_ARGS) {
      flag_encountered_error = 1;
      Rprintf("Error: nlopt_add_equality_mconstraint returned "
              "NLOPT_INVALID_ARGS.\n");
    }
  }

  // Now we can unprotect R_options
  UNPROTECT(1);

  // Optimal value of objective value upon return.
  double obj_value = HUGE_VAL;

  // Do optimization if no error occurred during initialization of the problem.
  nlopt_result status;
  if (flag_encountered_error == 0) {
    status = nlopt_optimize(opts, x0, &obj_value);
  } else {
    status = NLOPT_INVALID_ARGS;
  }

  // Dispose of the nlopt_opt object.
  nlopt_destroy(opts);
  if (use_local_optimizer) {
    nlopt_destroy(local_opts);
  }

  // After minimizing we can unprotect eval_f, eval_g_ineq, eval_g_eq, and the
  // environment.
  UNPROTECT(4);

  // Get version of NLopt.
  int major, minor, bugfix;
  nlopt_version(&major, &minor, &bugfix);

  // Create list to return results to R.
  int num_return_elements = 8;
  SEXP R_result_list = PROTECT(allocVector(VECSXP, num_return_elements));

  // Attach names to the return list.
  SEXP names = PROTECT(allocVector(STRSXP, num_return_elements));

  SET_STRING_ELT(names, 0, mkChar("status"));
  SET_STRING_ELT(names, 1, mkChar("message"));
  SET_STRING_ELT(names, 2, mkChar("iterations"));
  SET_STRING_ELT(names, 3, mkChar("objective"));
  SET_STRING_ELT(names, 4, mkChar("solution"));
  SET_STRING_ELT(names, 5, mkChar("version_major"));
  SET_STRING_ELT(names, 6, mkChar("version_minor"));
  SET_STRING_ELT(names, 7, mkChar("version_bugfix"));
  setAttrib(R_result_list, R_NamesSymbol, names);

  // Convert status to an R object.
  SEXP R_status = PROTECT(allocVector(INTSXP, 1));
  INTEGER(R_status)[0] = (int)status;

  // Convert message to an R object.
  SEXP R_status_message = PROTECT(convertStatusToMessage(status));

  // Convert number of iterations to an R object.
  SEXP R_num_iterations = PROTECT(allocVector(INTSXP, 1));
  INTEGER(R_num_iterations)[0] = objfunc_data.num_iterations;

  // Convert value of objective function to an R object.
  SEXP R_objective = PROTECT(allocVector(REALSXP, 1));
  REAL(R_objective)[0] = obj_value;

  // Convert the value of the controls to an R object.
  SEXP R_solution = PROTECT(allocVector(REALSXP, num_controls));
  double *pRsol = REAL(R_solution);
  for (size_t i = 0; i < num_controls; i++) {
    pRsol[i] = x0[i];
  }

  // Convert the major version number to an R object.
  SEXP R_version_major = PROTECT(allocVector(INTSXP, 1));
  INTEGER(R_version_major)[0] = major;

  // Convert the minor version number to an R object.
  SEXP R_version_minor = PROTECT(allocVector(INTSXP, 1));
  INTEGER(R_version_minor)[0] = minor;

  // Convert the bugfix version number to an R object.
  SEXP R_version_bugfix = PROTECT(allocVector(INTSXP, 1));
  INTEGER(R_version_bugfix)[0] = bugfix;

  // Add elements to the list.
  SET_VECTOR_ELT(R_result_list, 0, R_status);
  SET_VECTOR_ELT(R_result_list, 1, R_status_message);
  SET_VECTOR_ELT(R_result_list, 2, R_num_iterations);
  SET_VECTOR_ELT(R_result_list, 3, R_objective);
  SET_VECTOR_ELT(R_result_list, 4, R_solution);
  SET_VECTOR_ELT(R_result_list, 5, R_version_major);
  SET_VECTOR_ELT(R_result_list, 6, R_version_minor);
  SET_VECTOR_ELT(R_result_list, 7, R_version_bugfix);

  UNPROTECT(num_return_elements + 2);

  return (R_result_list);
}
