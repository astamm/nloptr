
require( 'inline' )
context( "Inline-Module" )

## Body of C++ function
includes <- '#include <vector>
    #include <math.h>
    double eval_rosenbrock_f (const std::vector<double>& x)
    {
         double value = 100.0 * std::pow(x[1] - x[0] * x[0], 2.0)
             + std::pow(1.0 - x[0], 2.0);
         return value;
    }
    std::vector<double> eval_grad_rosenbrock_f (const std::vector<double>& x)
    {
         std::vector<double> grad(2);
         grad[0] = -400.0 * x[0] * (x[1] - x[0] * x[0]) - 2.0 
             * (1.0 - x[0]);
         grad[1] = 200.0 * (x[1] - x[0] * x[0]);
         return grad;
     }
     double objective_f (const std::vector<double>& x, std::vector<double>& grad,
         void* f_data)
     {
         grad = eval_grad_rosenbrock_f(x);
         return eval_rosenbrock_f(x);
     }'
body <- 'Rcpp::NumericVector startpar(start);
    std::vector<double> x(2);
    x[0] = startpar(0);
    x[1] = startpar(1);
    nlopt::opt opt(nlopt::LD_LBFGS, 2);
    opt.set_min_objective(objective_f, NULL);
    opt.set_xtol_rel(1e-8);
    double minf;
    nlopt::result result = opt.optimize(x, minf);
    return Rcpp::wrap(x);'

test_that( "Test 'inline'-module with Rosenbrock Banana function.", {
    optfunc <- cxxfunction( signature( start = "vector" ), body = body, includes = includes, plugin = c( 'nloptr' ) )
    res <- optfunc( c( -1.2, 1.0 ) )

    ## Check results
    expect_that( res[1], equals( 1.0, tolerance = 1e-2 ) )
    expect_that( res[2], equals( 1.0, tolerance = 1e-2 ) )

} )

