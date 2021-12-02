#ifndef TEST_C_API_H
#define TEST_C_API_H

#include <vector>

std::vector<int> get_nlopt_version();

double myfunc(unsigned n, const double *x, double *grad, void *my_func_data);

typedef struct {
  double a, b;
} my_constraint_data;

double myconstraint(unsigned n, const double *x, double *grad, void *data);

std::vector<double> solve_example();

#endif /* TEST_C_API_H */
