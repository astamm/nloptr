## -*- mode: autoconf; autoconf-indentation: 4; -*-
##
##  nloptr configure.ac
##
##  nloptr -- R interface to NLopt
##
##  Copyright (C) 2014  Dirk Eddelbuettel 
##
## This file is licensed under the GPL-2 or later just like most of my
## Open Source code, and is granted an exemption (should it be needed) 
## for inclusion into nloptr 

# require at least autoconf 2.61
AC_PREREQ(2.61)

# Process this file with autoconf to produce a configure script.
AC_INIT([nloptr], [1.0.1])

# We are using C++
AC_LANG(C++)
AC_REQUIRE_CPP
AC_PROG_CXX

## check for pkg-config
AC_DEFUN([AC_PROG_PKGCONFIG], [AC_CHECK_PROG(PKGCONFIG,pkg-config,yes)])
AC_PROG_PKGCONFIG

## default to assuming no sufficient NLopt library has been found
nlopt_good="no"
nlopt_cflags=""
nlopt_libs=""
r_args=""

## consider command-line options if given
##
AC_ARG_WITH([nlopt-cflags],
            AC_HELP_STRING([--with-nlopt-cflags=CFLAGS],
                           [Supply compiler flags such as the location of NLopt header files]),
            [nlopt_cflags=$withval],
            [nlopt_cflags=""])
AC_ARG_WITH([nlopt-libs],
            AC_HELP_STRING([--with-nlopt-libs=LIBS],
                           [Supply the linker flags such as the location and name of NLopt libraries]),
            [nlopt_libs=$withval],
            [nlopt_libs=""])
AC_ARG_WITH([r-args],
            AC_HELP_STRING([--with-r-args=ARGUMENTS],
                           [Supply the arguments that should be passed to Rscript. Default: --vanilla]),
            [r_args=$withval],
            [r_args="--vanilla"])


## also use pkg-config to check for NLopt
##
if test x"${nlopt_libs}" == x""; then
    if test x"${PKGCONFIG}" == x"yes"; then
        ## check via pkg-config for nlopt
        if pkg-config --exists nlopt; then
            ## obtain cflags and obtain libs
            nlopt_cflags=$(pkg-config --cflags nlopt)
            nlopt_libs=$(pkg-config --libs nlopt)
            nlopt_good="yes"
        fi
    fi
fi


## And make sure these flags are used for the test below.
CPPFLAGS="${nlopt_cflags} ${CPPFLAGS}"
CXXFLAGS="${nlopt_cflags} ${CXXFLAGS}"

## check for headers Debian has in libhiredis-dev
AC_MSG_NOTICE([Now testing for NLopt header file.])
nlopt_header=nlopt.h
AC_CHECK_HEADER([$nlopt_header],
                [nlopt_good="yes"],  # may want to check for minimal version here too
                [nlopt_good="no"],
                [])       

## Check for NLopt version number using pkg-config.
# Perform this check after the header check,
# because the correct header with the wrong
# version, does not work.
if test x"${nlopt_good}" = x"yes"; then
    AC_MSG_NOTICE([Now testing for NLopt versison number.])
    if test x"${PKGCONFIG}" == x"yes"; then
        ## check via pkg-config for version number of nlopt
        if pkg-config --exists nlopt; then
            ## obtain version number
            nlopt_version=$(pkg-config --modversion nlopt)
        
            case ${nlopt_version} in
                 1.*|2.0.*|2.1.*|2.2.*|2.3.*)
                    AC_MSG_WARN([Only NLopt version 2.4.0 or greater can be used with nloptr.])
                    nlopt_good="no"
                ;; 
            esac    
        fi
    else
        AC_MSG_WARN([Could not test version of NLopt because pkg-config is not installed. Make sure the version number of NLopt is 2.4.0 or greater. Otherwise nloptr can not be used.])
    fi
fi

## in case neither of the two methods above worked, download NLopt and build it locally
if test x"${nlopt_good}" = x"no"; then
   AC_MSG_NOTICE([Need to configure and build NLopt])

   ## C Compiler options    
   NLOPTR_CFLAGS= 

   ## additional C Compiler options for linking
   NLOPTR_CLINKFLAGS= 

   ## Libraries necessary to link with NLopt
   NLOPTR_LIBS="-lm $(pwd)/src/nlopt_src/lib/libnlopt_cxx.a"

   ## Necessary Include dirs 
   NLOPTR_INCL="-I$(pwd)/src/nlopt_src/include"

   ## Set R_HOME, respecting an environment variable if set 
   : ${R_HOME=$(R RHOME)}
   if test -z "${R_HOME}"; then
       AC_MSG_ERROR([Could not determine R_HOME.])   
   fi

   ## Get R compilers and flags
   NLOPT_CC=$("${R_HOME}/bin/R" CMD config CC)
   NLOPT_CFLAGS=$("${R_HOME}/bin/R" CMD config CFLAGS)
   NLOPT_CPP=$("${R_HOME}/bin/R" CMD config CPP)
   NLOPT_CPPFLAGS=$("${R_HOME}/bin/R" CMD config CPPFLAGS)
   NLOPT_CXX=$("${R_HOME}/bin/R" CMD config CXX)
   NLOPT_CXXFLAGS=$("${R_HOME}/bin/R" CMD config CXXFLAGS)
   NLOPT_CXXCPP=$("${R_HOME}/bin/R" CMD config CXXCPP)

   ## report values
   #echo "${NLOPT_CC} | ${NLOPT_CFLAGS} | ${NLOPT_CPPFLAGS} | ${NLOPT_CPPFLAGS} | ${NLOPT_CXX} | ${NLOPT_CXXFLAGS} | ${NLOPT_CXXCPP}"

   ## Compile NLopt source code and clean up
   ## --prefix="`pwd`", which is the directory we want to
   ## install in, after we changed our current directory
   AC_MSG_NOTICE([Starting to install library to $(pwd)/src/nlopt_src])
   $(cd src/nlopt_src; \
        ./configure --prefix="$(pwd)" --enable-shared --enable-static --without-octave \
                    --without-matlab --without-guile --without-python --with-cxx \
                    CC="${NLOPT_CC}" CFLAGS="${NLOPT_CFLAGS}" CPP="${NLOPT_CPP}" \
                    CPPFLAGS="${NLOPT_CPPFLAGS}" CXX="${NLOPT_CXX}" \
                    CXXFLAGS="${NLOPT_CXXFLAGS}" CXXCPP="${NLOPT_CXXCPP}"; \
        make; \
        make install; \
        ls | grep -v "^include$" | grep -v "^lib$" | xargs rm -rf; \
        rm -rf .libs;)
   AC_MSG_NOTICE([Done installing library to $(pwd)/src/nlopt_src])

   ## Copy header files to inst/include such that they are available from R.
   cp src/nlopt_src/include inst/include

   ## Store compiler and linker flags
   nlopt_cflags="${NLOPTR_CFLAGS} ${NLOPTR_INCL}"
   nlopt_libs="${NLOPTR_CLINKFLAGS} ${NLOPTR_LIBS}"
   #echo "${NLOPTR_CFLAGS} | ${NLOPTR_INCL} | ${NLOPTR_CLINKFLAGS} | ${NLOPTR_LIBS}"

else
   AC_MSG_NOTICE([Suitable NLopt library found.])
fi

## could add a test of building a three-liner here

## now use all these
AC_SUBST([PKG_CFLAGS],["${PKG_CFLAGS} $nlopt_cflags"])
AC_SUBST([PKG_LIBS],["${PKG_LIBS} $nlopt_libs"])
AC_CONFIG_FILES([src/Makevars R/PkgFlags.R])
AC_OUTPUT
