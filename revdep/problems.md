# missSBM

<details>

* Version: 1.0.1
* GitHub: https://github.com/grossSBM/missSBM
* Source code: https://github.com/cran/missSBM
* Date/Publication: 2021-06-04 13:10:02 UTC
* Number of recursive dependencies: 102

Run `revdep_details(, "missSBM")` for more info

</details>

## Newly broken

*   checking whether package ‘missSBM’ can be installed ... ERROR
    ```
    Installation failed.
    See ‘/Users/stamm-a/Softs/nloptr/revdep/checks.noindex/missSBM/new/missSBM.Rcheck/00install.out’ for details.
    ```

## Installation

### Devel

```
* installing *source* package ‘missSBM’ ...
** package ‘missSBM’ successfully unpacked and MD5 sums checked
** using staged installation
** libs
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/missSBM/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/missSBM/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/new/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c RcppExports.cpp -o RcppExports.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/missSBM/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/missSBM/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/new/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c SBM_bernoulli.cpp -o SBM_bernoulli.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/missSBM/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/missSBM/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/new/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c kmeans.cpp -o kmeans.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/missSBM/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/missSBM/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/new/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c nlopt_wrapper.cpp -o nlopt_wrapper.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/missSBM/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/missSBM/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/new/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c packing.cpp -o packing.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/missSBM/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/missSBM/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/new/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c roundProduct.cpp -o roundProduct.o
...
** building package indices
** installing vignettes
** testing if installed package can be loaded from temporary location
Error: le chargement du package ou de l'espace de noms a échoué pour ‘missSBM’ in dyn.load(file, DLLpath = DLLpath, ...) :
impossible de charger l'objet partagé '/Users/stamm-a/Softs/nloptr/revdep/checks.noindex/missSBM/new/missSBM.Rcheck/00LOCK-missSBM/00new/missSBM/libs/missSBM.so':
  dlopen(/Users/stamm-a/Softs/nloptr/revdep/checks.noindex/missSBM/new/missSBM.Rcheck/00LOCK-missSBM/00new/missSBM/libs/missSBM.so, 0x0006): symbol not found in flat namespace '_nlopt_destroy'
Erreur : loading failed
Exécution arrêtée
ERROR: loading failed
* removing ‘/Users/stamm-a/Softs/nloptr/revdep/checks.noindex/missSBM/new/missSBM.Rcheck/missSBM’


```
### CRAN

```
* installing *source* package ‘missSBM’ ...
** package ‘missSBM’ successfully unpacked and MD5 sums checked
** using staged installation
** libs
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/missSBM/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/missSBM/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/old/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c RcppExports.cpp -o RcppExports.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/missSBM/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/missSBM/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/old/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c SBM_bernoulli.cpp -o SBM_bernoulli.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/missSBM/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/missSBM/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/old/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c kmeans.cpp -o kmeans.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/missSBM/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/missSBM/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/old/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c nlopt_wrapper.cpp -o nlopt_wrapper.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/missSBM/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/missSBM/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/old/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c packing.cpp -o packing.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/missSBM/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/missSBM/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/old/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c roundProduct.cpp -o roundProduct.o
...
** byte-compile and prepare package for lazy loading
** help
*** installing help indices
** building package indices
** installing vignettes
** testing if installed package can be loaded from temporary location
** checking absolute paths in shared objects and dynamic libraries
** testing if installed package can be loaded from final location
** testing if installed package keeps a record of temporary installation path
* DONE (missSBM)


```
# mssm

<details>

* Version: 0.1.5
* GitHub: https://github.com/boennecd/mssm
* Source code: https://github.com/cran/mssm
* Date/Publication: 2021-10-05 07:10:09 UTC
* Number of recursive dependencies: 93

Run `revdep_details(, "mssm")` for more info

</details>

## Newly broken

*   checking whether package ‘mssm’ can be installed ... ERROR
    ```
    Installation failed.
    See ‘/Users/stamm-a/Softs/nloptr/revdep/checks.noindex/mssm/new/mssm.Rcheck/00install.out’ for details.
    ```

## Installation

### Devel

```
* installing *source* package ‘mssm’ ...
** package ‘mssm’ successfully unpacked and MD5 sums checked
** using staged installation
** libs
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG -DUSE_THREAD_LOCAL -DUSE_FC_LEN_T -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/new/testthat/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/new/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c PF.cpp -o PF.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG -DUSE_THREAD_LOCAL -DUSE_FC_LEN_T -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/new/testthat/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/new/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c RcppExports.cpp -o RcppExports.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG -DUSE_THREAD_LOCAL -DUSE_FC_LEN_T -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/new/testthat/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/new/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c blas-lapack.cpp -o blas-lapack.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG -DUSE_THREAD_LOCAL -DUSE_FC_LEN_T -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/new/testthat/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/new/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c cloud.cpp -o cloud.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG -DUSE_THREAD_LOCAL -DUSE_FC_LEN_T -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/new/testthat/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/new/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c cpp_to_R.cpp -o cpp_to_R.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG -DUSE_THREAD_LOCAL -DUSE_FC_LEN_T -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/new/testthat/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/new/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c dists.cpp -o dists.o
...
*** copying figures
** building package indices
** testing if installed package can be loaded from temporary location
Error: le chargement du package ou de l'espace de noms a échoué pour ‘mssm’ in dyn.load(file, DLLpath = DLLpath, ...) :
impossible de charger l'objet partagé '/Users/stamm-a/Softs/nloptr/revdep/checks.noindex/mssm/new/mssm.Rcheck/00LOCK-mssm/00new/mssm/libs/mssm.so':
  dlopen(/Users/stamm-a/Softs/nloptr/revdep/checks.noindex/mssm/new/mssm.Rcheck/00LOCK-mssm/00new/mssm/libs/mssm.so, 0x0006): symbol not found in flat namespace '_nlopt_add_inequality_mconstraint'
Erreur : loading failed
Exécution arrêtée
ERROR: loading failed
* removing ‘/Users/stamm-a/Softs/nloptr/revdep/checks.noindex/mssm/new/mssm.Rcheck/mssm’


```
### CRAN

```
* installing *source* package ‘mssm’ ...
** package ‘mssm’ successfully unpacked and MD5 sums checked
** using staged installation
** libs
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG -DUSE_THREAD_LOCAL -DUSE_FC_LEN_T -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/testthat/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/old/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c PF.cpp -o PF.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG -DUSE_THREAD_LOCAL -DUSE_FC_LEN_T -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/testthat/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/old/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c RcppExports.cpp -o RcppExports.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG -DUSE_THREAD_LOCAL -DUSE_FC_LEN_T -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/testthat/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/old/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c blas-lapack.cpp -o blas-lapack.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG -DUSE_THREAD_LOCAL -DUSE_FC_LEN_T -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/testthat/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/old/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c cloud.cpp -o cloud.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG -DUSE_THREAD_LOCAL -DUSE_FC_LEN_T -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/testthat/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/old/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c cpp_to_R.cpp -o cpp_to_R.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG -DUSE_THREAD_LOCAL -DUSE_FC_LEN_T -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/mssm/testthat/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/old/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c dists.cpp -o dists.o
...
** byte-compile and prepare package for lazy loading
** help
*** installing help indices
*** copying figures
** building package indices
** testing if installed package can be loaded from temporary location
** checking absolute paths in shared objects and dynamic libraries
** testing if installed package can be loaded from final location
** testing if installed package keeps a record of temporary installation path
* DONE (mssm)


```
# PLNmodels

<details>

* Version: 0.11.4
* GitHub: https://github.com/pln-team/PLNmodels
* Source code: https://github.com/cran/PLNmodels
* Date/Publication: 2021-03-16 16:10:02 UTC
* Number of recursive dependencies: 191

Run `revdep_details(, "PLNmodels")` for more info

</details>

## Newly broken

*   checking whether package ‘PLNmodels’ can be installed ... ERROR
    ```
    Installation failed.
    See ‘/Users/stamm-a/Softs/nloptr/revdep/checks.noindex/PLNmodels/new/PLNmodels.Rcheck/00install.out’ for details.
    ```

## Newly fixed

*   checking examples ... ERROR
    ```
    Running examples in ‘PLNmodels-Ex.R’ failed
    The error most likely occurred in:
    
    > ### Name: plot.PLNmixturefit
    > ### Title: Mixture visualization of a 'PLNmixturefit' object
    > ### Aliases: plot.PLNmixturefit
    > 
    > ### ** Examples
    > 
    > data(trichoptera)
    ...
     Smoothing PLN mixture models.
    
     Post-treatments
     DONE!
    > plot(myPLN, "pca")
    > plot(myPLN, "matrix")
    Warning: Transformation introduced infinite values in discrete y-axis
    Error in seq.default(min, max, by = by) : 'from' must be a finite number
    Calls: plot ... <Anonymous> -> f -> <Anonymous> -> seq -> seq.default
    Execution halted
    ```

*   checking Rd cross-references ... WARNING
    ```
    Package non disponible pour vérifier les xrefs Rd : ‘DESeq2’
    ```

## Installation

### Devel

```
* installing *source* package ‘PLNmodels’ ...
** package ‘PLNmodels’ successfully unpacked and MD5 sums checked
** using staged installation
** libs
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/PLNmodels/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/PLNmodels/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/new/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c RcppExports.cpp -o RcppExports.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/PLNmodels/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/PLNmodels/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/new/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c nlopt_wrapper.cpp -o nlopt_wrapper.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/PLNmodels/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/PLNmodels/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/new/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c optimize.cpp -o optimize.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/PLNmodels/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/PLNmodels/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/new/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c optimize_ve.cpp -o optimize_ve.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/PLNmodels/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/PLNmodels/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/new/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c packing.cpp -o packing.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11 -dynamiclib -Wl,-headerpad_max_install_names -undefined dynamic_lookup -single_module -multiply_defined suppress -L/Library/Frameworks/R.framework/Resources/lib -L/usr/local/clang8/lib -L/usr/local/lib -o PLNmodels.so RcppExports.o nlopt_wrapper.o optimize.o optimize_ve.o packing.o -L/Library/Frameworks/R.framework/Resources/lib -lRlapack -L/Library/Frameworks/R.framework/Resources/lib -lRblas -L/usr/local/gfortran/lib/gcc/x86_64-apple-darwin18/8.2.0 -L/usr/local/gfortran/lib -lgfortran -lquadmath -lm -F/Library/Frameworks/R.framework/.. -framework R -Wl,-framework -Wl,CoreFoundation
...
** building package indices
** installing vignettes
** testing if installed package can be loaded from temporary location
Error: le chargement du package ou de l'espace de noms a échoué pour ‘PLNmodels’ in dyn.load(file, DLLpath = DLLpath, ...) :
impossible de charger l'objet partagé '/Users/stamm-a/Softs/nloptr/revdep/checks.noindex/PLNmodels/new/PLNmodels.Rcheck/00LOCK-PLNmodels/00new/PLNmodels/libs/PLNmodels.so':
  dlopen(/Users/stamm-a/Softs/nloptr/revdep/checks.noindex/PLNmodels/new/PLNmodels.Rcheck/00LOCK-PLNmodels/00new/PLNmodels/libs/PLNmodels.so, 0x0006): symbol not found in flat namespace '_nlopt_destroy'
Erreur : loading failed
Exécution arrêtée
ERROR: loading failed
* removing ‘/Users/stamm-a/Softs/nloptr/revdep/checks.noindex/PLNmodels/new/PLNmodels.Rcheck/PLNmodels’


```
### CRAN

```
* installing *source* package ‘PLNmodels’ ...
** package ‘PLNmodels’ successfully unpacked and MD5 sums checked
** using staged installation
** libs
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/PLNmodels/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/PLNmodels/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/old/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c RcppExports.cpp -o RcppExports.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/PLNmodels/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/PLNmodels/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/old/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c nlopt_wrapper.cpp -o nlopt_wrapper.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/PLNmodels/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/PLNmodels/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/old/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c optimize.cpp -o optimize.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/PLNmodels/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/PLNmodels/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/old/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c optimize_ve.cpp -o optimize_ve.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/PLNmodels/Rcpp/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/PLNmodels/RcppArmadillo/include' -I'/Users/stamm-a/Softs/nloptr/revdep/library.noindex/nloptr/old/nloptr/include' -I/usr/local/include   -fPIC  -g -O2  -c packing.cpp -o packing.o
/usr/local/clang8/bin/clang++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -std=c++11 -dynamiclib -Wl,-headerpad_max_install_names -undefined dynamic_lookup -single_module -multiply_defined suppress -L/Library/Frameworks/R.framework/Resources/lib -L/usr/local/clang8/lib -L/usr/local/lib -o PLNmodels.so RcppExports.o nlopt_wrapper.o optimize.o optimize_ve.o packing.o -L/Library/Frameworks/R.framework/Resources/lib -lRlapack -L/Library/Frameworks/R.framework/Resources/lib -lRblas -L/usr/local/gfortran/lib/gcc/x86_64-apple-darwin18/8.2.0 -L/usr/local/gfortran/lib -lgfortran -lquadmath -lm -F/Library/Frameworks/R.framework/.. -framework R -Wl,-framework -Wl,CoreFoundation
...
** help
*** installing help indices
*** copying figures
** building package indices
** installing vignettes
** testing if installed package can be loaded from temporary location
** checking absolute paths in shared objects and dynamic libraries
** testing if installed package can be loaded from final location
** testing if installed package keeps a record of temporary installation path
* DONE (PLNmodels)


```
