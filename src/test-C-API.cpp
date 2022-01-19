/*
 * This file uses the Catch unit testing library, alongside
 * testthat's simple bindings, to test a C++ function.
 *
 * For your own packages, ensure that your test files are
 * placed within the `src/` folder, and that you include
 * `LinkingTo: testthat` within your DESCRIPTION file.
 */

// All test files should include the <testthat.h>
// header file.
#include <testthat.h>
#include "test-C-API.h"
#include <nlopt.h>

std::vector<int> get_nlopt_version()
{
  // get version of NLopt
  int major, minor, bugfix;
  nlopt_version(&major, &minor, &bugfix);

  std::vector<int> retvec(3);
  retvec[0] = major;
  retvec[1] = minor;
  retvec[2] = bugfix;

  return retvec;
}

double myfunc(unsigned n, const double *x, double *grad, void *my_func_data)
{
  if (grad) {
    grad[0] = 0.0;
    grad[1] = 0.5 / sqrt(x[1]);
  }
  return sqrt(x[1]);
}

double myconstraint(unsigned n, const double *x, double *grad, void *data)
{
  my_constraint_data *d = (my_constraint_data *) data;
  double a = d->a, b = d->b;
  if (grad) {
    grad[0] = 3 * a * (a*x[0] + b) * (a*x[0] + b);
    grad[1] = -1.0;
  }
  return ((a*x[0] + b) * (a*x[0] + b) * (a*x[0] + b) - x[1]);
}

std::vector<double> solve_example()
{
  double lb[2] = { -HUGE_VAL, 0 }; // lower bounds
  nlopt_opt opt;

  opt = nlopt_create(NLOPT_LD_MMA, 2); // algorithm and dimensionality
  nlopt_set_lower_bounds(opt, lb);
  nlopt_set_min_objective(opt, myfunc, NULL);

  my_constraint_data data[2] = { {2,0}, {-1,1} };

  nlopt_add_inequality_constraint(opt, myconstraint, &data[0], 1e-8);
  nlopt_add_inequality_constraint(opt, myconstraint, &data[1], 1e-8);

  nlopt_set_xtol_rel(opt, 1e-4);

  // some initial guess
  std::vector<double> x(2);
  x[0] = 1.234;
  x[1] = 5.678;

  double minf; // the minimum objective value, upon return
  nlopt_optimize(opt, &(x[0]), &minf);
  nlopt_destroy(opt);

  return x;
}

// Initialize a unit test context. This is similar to how you
// might begin an R test file with 'context()', expect the
// associated context should be wrapped in braced.
context("Test C API")
{
  // The format for specifying tests is similar to that of
  // testthat's R functions. Use 'test_that()' to define a
  // unit test, and use 'expect_true()' and 'expect_false()'
  // to test the desired conditions.
  test_that("Test exposing NLopt C function nlopt_version")
  {
    // Get nlopt version, which consists of an integer vector:
    // (major, minor, bugfix)
    std::vector<int> res = get_nlopt_version();

    // Check return value
    expect_true(res.size() == 3);
    expect_true(res[0] >= 2);
    expect_true(res[1] >= 7);
    expect_true(res[2] >= 0);
  }

  test_that("Test exposed NLopt C code using example from NLopt tutorial")
  {
    // Get optimal x values.
    std::vector<double> res = solve_example();

    // Check return value.
    expect_true(res.size() == 2);
    expect_true(abs(res[0] - 1./ 3) < 1.0e-4);
    expect_true(abs(res[1] - 8./27) < 1.0e-4);
  }
}
