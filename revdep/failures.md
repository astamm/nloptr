# smam

<details>

* Version: 0.7.2
* GitHub: https://github.com/ChaoranHu/smam
* Source code: https://github.com/cran/smam
* Date/Publication: 2024-01-10 21:30:02 UTC
* Number of recursive dependencies: 47

Run `revdepcheck::revdep_details(, "smam")` for more info

</details>

## In both

*   checking whether package ‘smam’ can be installed ... ERROR
    ```
    Installation failed.
    See ‘/Users/stamm-a/Softs/nloptr/revdep/checks.noindex/smam/new/smam.Rcheck/00install.out’ for details.
    ```

## Installation

### Devel

```
* installing *source* package ‘smam’ ...
** package ‘smam’ successfully unpacked and MD5 sums checked
** using staged installation
checking for gsl-config... no
configure: error: gsl-config not found, is GSL installed?
ERROR: configuration failed for package ‘smam’
* removing ‘/Users/stamm-a/Softs/nloptr/revdep/checks.noindex/smam/new/smam.Rcheck/smam’


```
### CRAN

```
* installing *source* package ‘smam’ ...
** package ‘smam’ successfully unpacked and MD5 sums checked
** using staged installation
checking for gsl-config... no
configure: error: gsl-config not found, is GSL installed?
ERROR: configuration failed for package ‘smam’
* removing ‘/Users/stamm-a/Softs/nloptr/revdep/checks.noindex/smam/old/smam.Rcheck/smam’


```
# spaMM

<details>

* Version: 4.5.0
* GitHub: NA
* Source code: https://github.com/cran/spaMM
* Date/Publication: 2024-06-09 22:20:02 UTC
* Number of recursive dependencies: 88

Run `revdepcheck::revdep_details(, "spaMM")` for more info

</details>

## In both

*   checking whether package ‘spaMM’ can be installed ... ERROR
    ```
    Installation failed.
    See ‘/Users/stamm-a/Softs/nloptr/revdep/checks.noindex/spaMM/new/spaMM.Rcheck/00install.out’ for details.
    ```

*   checking package dependencies ... NOTE
    ```
    Package which this enhances but not available for checking: ‘RLRsim’
    ```

## Installation

### Devel

```
* installing *source* package ‘spaMM’ ...
** package ‘spaMM’ successfully unpacked and MD5 sums checked
** using staged installation
** libs
using C++ compiler: ‘Apple clang version 16.0.0 (clang-1600.0.26.6)’
using SDK: ‘MacOSX15.2.sdk’
clang++ -arch arm64 -std=gnu++17 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/spaMM/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/spaMM/RcppEigen/include' -I/opt/R/arm64/include    -fPIC  -falign-functions=64 -Wall -g -O2   -c COMPoisson.cpp -o COMPoisson.o
clang++ -arch arm64 -std=gnu++17 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/spaMM/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/spaMM/RcppEigen/include' -I/opt/R/arm64/include    -fPIC  -falign-functions=64 -Wall -g -O2   -c PLS.cpp -o PLS.o
In file included from PLS.cpp:1:
In file included from ./spaMM_linear.h:4:
...
      |       ^
5 warnings generated.
clang++ -arch arm64 -std=gnu++17 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/spaMM/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/spaMM/RcppEigen/include' -I/opt/R/arm64/include    -fPIC  -falign-functions=64 -Wall -g -O2   -c newBessel.cpp -o newBessel.o
newBessel.cpp:2:10: fatal error: 'gsl/gsl_sf_bessel.h' file not found
    2 | #include <gsl/gsl_sf_bessel.h>
      |          ^~~~~~~~~~~~~~~~~~~~~
1 error generated.
make: *** [newBessel.o] Error 1
ERROR: compilation failed for package ‘spaMM’
* removing ‘/Users/stamm-a/Softs/nloptr/revdep/checks.noindex/spaMM/new/spaMM.Rcheck/spaMM’


```
### CRAN

```
* installing *source* package ‘spaMM’ ...
** package ‘spaMM’ successfully unpacked and MD5 sums checked
** using staged installation
** libs
using C++ compiler: ‘Apple clang version 16.0.0 (clang-1600.0.26.6)’
using SDK: ‘MacOSX15.2.sdk’
clang++ -arch arm64 -std=gnu++17 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/spaMM/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/spaMM/RcppEigen/include' -I/opt/R/arm64/include    -fPIC  -falign-functions=64 -Wall -g -O2   -c COMPoisson.cpp -o COMPoisson.o
clang++ -arch arm64 -std=gnu++17 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/spaMM/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/spaMM/RcppEigen/include' -I/opt/R/arm64/include    -fPIC  -falign-functions=64 -Wall -g -O2   -c PLS.cpp -o PLS.o
In file included from PLS.cpp:1:
In file included from ./spaMM_linear.h:4:
...
      |       ^
5 warnings generated.
clang++ -arch arm64 -std=gnu++17 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/spaMM/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/spaMM/RcppEigen/include' -I/opt/R/arm64/include    -fPIC  -falign-functions=64 -Wall -g -O2   -c newBessel.cpp -o newBessel.o
newBessel.cpp:2:10: fatal error: 'gsl/gsl_sf_bessel.h' file not found
    2 | #include <gsl/gsl_sf_bessel.h>
      |          ^~~~~~~~~~~~~~~~~~~~~
1 error generated.
make: *** [newBessel.o] Error 1
ERROR: compilation failed for package ‘spaMM’
* removing ‘/Users/stamm-a/Softs/nloptr/revdep/checks.noindex/spaMM/old/spaMM.Rcheck/spaMM’


```
# surveyvoi

<details>

* Version: 1.0.6
* GitHub: https://github.com/prioritizr/surveyvoi
* Source code: https://github.com/cran/surveyvoi
* Date/Publication: 2024-02-16 23:10:06 UTC
* Number of recursive dependencies: 116

Run `revdepcheck::revdep_details(, "surveyvoi")` for more info

</details>

## In both

*   checking whether package ‘surveyvoi’ can be installed ... ERROR
    ```
    Installation failed.
    See ‘/Users/stamm-a/Softs/nloptr/revdep/checks.noindex/surveyvoi/new/surveyvoi.Rcheck/00install.out’ for details.
    ```

*   checking package dependencies ... NOTE
    ```
    Package suggested but not available for checking: ‘gurobi’
    ```

## Installation

### Devel

```
* installing *source* package ‘surveyvoi’ ...
** package ‘surveyvoi’ successfully unpacked and MD5 sums checked
** using staged installation
checking if R found... yes
configure: R version: 4.4.3
checking for pkg-config... no
configure: Package PKG_CPPFLAGS: -I/opt/R/arm64/include  
configure: Package PKG_LIBS:      -lgmpxx -lgmp -lmpfr -lgmp
checking if gmp compiles... no
configure: Configuration failed because gmp was not found. Try installing:
...
configure:   * deb:  libgmp3-dev (Debian, Ubuntu)
configure:   * rpm:  gmp-devel (Fedora, EPEL)
configure:   * brew: gmp (Mac OSX)
configure: 
configure: If gmp is already installed, check that 'pkg-config' is in
configure: your PATH and PKG_CONFIG_PATH contains a gmpxx.pc file.
configure: 
configure: error: ERROR: Installation failed
ERROR: configuration failed for package ‘surveyvoi’
* removing ‘/Users/stamm-a/Softs/nloptr/revdep/checks.noindex/surveyvoi/new/surveyvoi.Rcheck/surveyvoi’


```
### CRAN

```
* installing *source* package ‘surveyvoi’ ...
** package ‘surveyvoi’ successfully unpacked and MD5 sums checked
** using staged installation
checking if R found... yes
configure: R version: 4.4.3
checking for pkg-config... no
configure: Package PKG_CPPFLAGS: -I/opt/R/arm64/include  
configure: Package PKG_LIBS:      -lgmpxx -lgmp -lmpfr -lgmp
checking if gmp compiles... no
configure: Configuration failed because gmp was not found. Try installing:
...
configure:   * deb:  libgmp3-dev (Debian, Ubuntu)
configure:   * rpm:  gmp-devel (Fedora, EPEL)
configure:   * brew: gmp (Mac OSX)
configure: 
configure: If gmp is already installed, check that 'pkg-config' is in
configure: your PATH and PKG_CONFIG_PATH contains a gmpxx.pc file.
configure: 
configure: error: ERROR: Installation failed
ERROR: configuration failed for package ‘surveyvoi’
* removing ‘/Users/stamm-a/Softs/nloptr/revdep/checks.noindex/surveyvoi/old/surveyvoi.Rcheck/surveyvoi’


```
