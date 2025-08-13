#ifndef __PARSERS_H__
#define __PARSERS_H__

#include <Rinternals.h>

// Extracts element with name 'str' from R object 'list' & returns that element.
SEXP getListElement(SEXP list, char *str);

int parse_integer_option(SEXP R_options, char *name);
double parse_real_option(SEXP R_options, char *name);
unsigned int parse_vector_length_option(SEXP R_options, char *name);
double *parse_real_vector_option(SEXP R_options, char *name);

#endif /*__PARSERS_H__*/
