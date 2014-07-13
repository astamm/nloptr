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

## use pkg-config to check for NLopt
##
if test x"${PKGCONFIG}" == x"yes"; then
    ## check via pkg-config for hiredis
    if pkg-config --exists nlopt; then
        ## obtain cflags and obtain libs
        nlopt_cflags=$(pkg-config --cflags nlopt)
        nlopt_libs=$(pkg-config --libs nlopt)
        nlopt_version=$(pkg-config --modversion nlopt)
        nlopt_good="yes"

        case ${nlopt_version} in
             1.*|2.0.*|2.1.*|2.2.*|2.3.*)
                AC_MSG_WARN([Only NLopt version 2.4.0 or greater can be used with nloptr.])
                nlopt_good="no"
             ;; 
        esac    
    else
        nlopt_cflags=""
        nlopt_libs=""
        nlopt_version=""
        nlopt_good="no"
    fi
fi

if test "${nlopt_good}" = no; then
   AC_MSG_NOTICE([Need to download and build NLopt])

   ## define NLopt version
   NLOPT_VERSION=2.4.2

   ## C Compiler options
   NLOPTR_CFLAGS= 

   ## additional C Compiler options for linking
   NLOPTR_CLINKFLAGS= 

   ## Libraries necessary to link with NLopt
   NLOPTR_LIBS="-lm $(pwd)/nlopt-${NLOPT_VERSION}/lib/libnlopt_cxx.a"

   ## Necessary Include dirs 
   NLOPTR_INCL="-I$(pwd)/nlopt-${NLOPT_VERSION}/include"

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

   ## Download NLopt source code
   ## curl -O http://ab-initio.mit.edu/nlopt/nlopt-${NLOPT_VERSION}.tar.gz
   $("${R_HOME}/bin/Rscript" --vanilla -e "download.file(url='http://ab-initio.mit.edu/nlopt/nlopt-${NLOPT_VERSION}.tar.gz', destfile='nlopt-${NLOPT_VERSION}.tar.gz')")

   ## Extract NLopt source code and remove .tar.gz
   ## tar -xzvf nlopt-${NLOPT_VERSION}.tar.gz
   $("${R_HOME}/bin/Rscript" --vanilla -e "untar(tarfile='nlopt-${NLOPT_VERSION}.tar.gz')")
   $(rm -rf nlopt-${NLOPT_VERSION}.tar.gz)

   ## Compile NLopt source code and clean up
   ## --prefix="`pwd`", which is the directory we want to
   ## install in, after we changed our current directory
   AC_MSG_NOTICE([Starting to install library to $(pwd)/nlopt-${NLOPT_VERSION}])
   $(cd nlopt-${NLOPT_VERSION}; \
        sed -i -e 's/sqrt(/sqrt((double) /g' isres/isres.c; \
        sed -i -e '1s/^/extern "C" {\n/' -e '$s/$/\n}/' util/qsort_r.c; \
        ./configure --prefix="$(pwd)" --enable-shared --enable-static --without-octave \
                    --without-matlab --without-guile --without-python --with-cxx \
                    CC="${NLOPT_CC}" CFLAGS="${NLOPT_CFLAGS}" CPP="${NLOPT_CPP}" \
                    CPPFLAGS="${NLOPT_CPPFLAGS}" CXX="${NLOPT_CXX}" \
                    CXXFLAGS="${NLOPT_CXXFLAGS}" CXXCPP="${NLOPT_CXXCPP}" > /dev/null 2>&1; \
        make > /dev/null 2>&1; \
        make install > /dev/null 2>&1; \
        ls | grep -v "^include$" | grep -v "^lib$" | xargs rm -rf; \
        rm -rf .libs;)
   AC_MSG_NOTICE([Done installing library to $(pwd)/nlopt-${NLOPT_VERSION}])

   ## Store compiler and linker flags
   nlopt_cflags="${NLOPTR_CFLAGS} ${NLOPTR_INCL}"
   nlopt_libs="${NLOPTR_CLINKFLAGS} ${NLOPTR_LIBS}"
   #echo "${NLOPTR_CFLAGS} | ${NLOPTR_INCL} | ${NLOPTR_CLINKFLAGS} | ${NLOPTR_LIBS}"

else
   AC_MSG_NOTICE([Suitable NLopt library found.])
fi

## And make sure these flags are used for the test below.
CPPFLAGS="${nlopt_cflags} ${CPPFLAGS}"
CXXFLAGS="${nlopt_cflags} ${CXXFLAGS}"

## check for headers Debian has in libhiredis-dev
AC_MSG_NOTICE([Testing for NLopt header.])
nlopt_header=nlopt.h
nlopt_header_cache_var=AS_TR_SH([ac_cv_header_$nlopt_header])
AC_CHECK_HEADER([$nlopt_header],,
                [       
		# If it didn't work, try adding /usr/local directly then trying again
		AC_MSG_WARN([NLopt headers not found with via default CXXFLAGS and CPPFLAGS, trying /usr/local/include])
		CPPFLAGS="${nlopt_cxxflags} ${CPPFLAGS} -I/usr/local/include"
		CXXFLAGS="${nlopt_cxxflags} ${CXXFLAGS} -I/usr/local/include -L/usr/local/lib"
		# unset the cache variable for this particular header check
		# so we can check again with different defaults specified.
		AC_MSG_WARN([Unsetting $nlopt_header_cache_var])
		AS_UNSET([$nlopt_header_cache_var])
		AC_CHECK_HEADER([$nlopt_header],,
		[AC_MSG_ERROR([ERROR: NLopt headers required; use '-Iincludedir' in CXXFLAGS for unusual locations.])])
		])

## could add a test of building a three-liner here

## now use all these
AC_SUBST([PKG_CFLAGS],["${PKG_CFLAGS} $nlopt_cflags"])
AC_SUBST([PKG_LIBS],["${PKG_LIBS} $nlopt_libs"])
AC_CONFIG_FILES([src/Makevars])
AC_OUTPUT
echo "Completed configuration and ready to build."

