# Install from Source on Windows (64bit)
These instructions describe how to install `nloptr` from source for Windows.
They theoretically only work for NLOPT version **2.50** and later, and have only
been tested on version **2.6.1**. Compiling `nloptr` for Windows consists of two
steps:

  1. Configure and compile NLopt from source or download and unpack a
  pre-compiled binary (None Exist Yet)
  2. Compile the R interface

# Compilation of NLOPT
These instructions assume that a working version of
[**MSYS2**](https://www.msys2.org/) has been installed and updated, and that
[Rtools 3.5]() has also been installed. These instructions may not work once
[Rtools 4.0]() is officially released.

 1. Download the [latest source of NLopt](https://nlopt.readthedocs.io/en/latest/#download-and-installation)
 1. Untar it
 1. Edit CMakeLists.txt:
   * Before the line `project (nlopt)` (Line 21 in 2.6.1) add the following:
     * `set(CMAKE_C_COMPILER "/YOUR/PATH/TO/Rtools/x86_64-w64-mingw32-gcc.exe")`
     * `set(CMAKE_CXX_COMPILER "/YOUR/PATH/TO/Rtools/x86_64-w64-mingw32-g++.exe")`
     * This is necessary, otherwise the gcc installation of MSYS2 will compile
     the library, which *will* result in headaches trying to use Rtools to
     compile `nloptr`.
   * If you want to add additional optimization flags like `O2`, `march`, or
   `mtune` you would add the following two lines underneath:
     * `set(CMAKE_C_FLAGS "ADD FLAGS HERE ${CMAKE_C_FLAGS}")`
     * `set(CMAKE_CXX_FLAGS "ADD FLAGS HERE ${CMAKE_CXX_FLAGS}")`
     
   4. Since the only need for the library is for R, only a static library with
   no other bindings needs to be built. Therefore, for the options, make sure
   that NLOPT_CXX is set to ON (it is by default), and that everything else is
   set to OFF, including BUILD_SHARED_LIBS. This last is necessary for without
   it, a `.dll` is built and not a `.a`. If you want those bindings, leave them
   set to ON, but this has not been tested.
 1. At the MSYS/MinGW64 command line, change directory into the newly expanded
 nlopt directory.
 1. At the prompt type:
   * `mkdir build`
   * `cd build`
   * `cmake -G"MSYS Makefiles" -DCMAKE_INSTALL_PREFIX=/YOUR/PATH/TO/NLOPT/INSTALL ..`
     * The `-G` is required otherwise MSYS tries to use `nmake`. The install
     prefix option isn't necessary, but it makes it easier to find and link in
     the `nloptr` build step. You will see a slew of notices. If you the first
     notice is  `The C compiler identification is GNU 4.9.3`, that is a good
     sign!
 7. After the `cmake` completes run `make` and then `make install`. There may
 be a lot of warnings, but they can be ignored.
 1. When the compilation and installation is complete, there should be two
 directories in the INSTALL location: `lib` and `include`.

# Installation of `nloptr` from source
 1. Either clone `nloptr` into your IDE (like RStudio) or download the source
 of `nloptr` (from [GitHub](https://github.com/jyypma/nloptr) or
 [CRAN](http://cran.r-project.org/web/packages/nloptr/index.html) and expand it
 somewhere.
 1. Before building from the DOS prompt, add
 `NLOPT_HOME = /YOUR/PATH/TO/NLOPT/INSTALL` to your Makevars[.win].
 1. Compile the R interface
   * **If the version of `nloptr` is still 1.2.1 or similar**:
     1. Edit the file `/nloptr/src/Makevars.win` to read:
     `PKG_CFLAGS = -I"$(NLOPT_HOME)/include"`
     `PKG_LIBS = -L"$(NLOPT_HOME)/lib" -lnlopt -lm -lstdc++`
   * Otherwise, this may have been brought into the main package
   1. Using an IDE: Build the package
   1. Using the command line (untested): `R CMD build nloptr`
