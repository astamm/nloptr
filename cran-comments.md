## Test environments
* local macOS R installation, R 4.4.3
* continuous integration via GH actions:
  * macOS latest release
  * windows latest release
  * windows latest release with Rtools42
  * Ubuntu 24.04.2 LTS latest release and devel using the *building nlopt from source*
  strategy
  * Ubuntu 24.04.2 LTS latest release using the *reuse existing build of nlopt*
  strategy
  * Ubuntu 24.04.2 LTS against all versions of nlopt since `2.7.0`.
* [win-builder](https://win-builder.r-project.org/) (release and devel) NOTHING TO DO
* [macOS-builder](https://mac.r-project.org/macbuilder/submit.html) CHECKER BROKEN
* [R-hub](https://builder.r-hub.io)
  - All R versions on GitHub Actions ubuntu-latest
  - All R versions on GitHub Actions macos-13
  - All R versions on GitHub Actions macos-latest
  - All R versions on GitHub Actions windows-latest
  - R Under development (unstable) (2024-06-14 r86747) on Ubuntu 22.04.4 LTS
   ghcr.io/r-hub/containers/clang-asan:latest

## R CMD check results
There was no ERROR, no WARNING and no NOTE.

## Downstream dependencies

We checked 160 reverse dependencies (151 from CRAN + 9 from Bioconductor), comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 1 new problem (**smooth**): 
 
    - we filed an issue [here](https://github.com/astamm/nloptr/issues/182) to
    keep track of it, 
    - we investigated the issue and found it comes from **smooth**,
    - we informed the author of **smooth** by filing an issue in his repo
    [here](https://github.com/config-i1/smooth/issues/242),
    - he replied back and we are working on a solution.
 
 * We failed to check 3 packages

Issues with CRAN packages are summarised below.

### Failed to check

* smam      (NA)
* spaMM     (NA)
* surveyvoi (NA)
