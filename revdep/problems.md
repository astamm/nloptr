# garma

<details>

* Version: 0.9.23
* GitHub: https://github.com/rlph50/garma
* Source code: https://github.com/cran/garma
* Date/Publication: 2024-09-13 03:40:02 UTC
* Number of recursive dependencies: 92

Run `revdepcheck::revdep_details(, "garma")` for more info

</details>

## Newly broken

*   checking tests ...
    ```
      Running ‘testthat.R’
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
       5.         └─Rsolnp:::.subnp(...)
      ── Error ('test_garma.R:241:3'): garma xreg ────────────────────────────────────
      <subscriptOutOfBoundsError/error/condition>
      Error in `gap[, 1]`: subscript out of bounds
      Backtrace:
          ▆
       1. └─garma::garma(x, xreg = m) at test_garma.R:241:3
       2.   └─garma:::internal_generic_optim_list(...)
       3.     └─garma:::internal_generic_optim(...)
       4.       └─Rsolnp::solnp(...)
       5.         └─Rsolnp:::.subnp(...)
      
      [ FAIL 3 | WARN 0 | SKIP 1 | PASS 55 ]
      Error: Test failures
      Execution halted
    ```

