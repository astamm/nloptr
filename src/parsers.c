#include "parsers.h"
#include <R.h>

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
  double *value = REAL(R_value);
  UNPROTECT(1);
  return value;
}
