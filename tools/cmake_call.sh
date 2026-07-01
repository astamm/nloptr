#! /bin/sh

CMAKE_BIN=$1

: ${R_HOME=$(R RHOME)}
RSCRIPT_BIN=${R_HOME}/bin/Rscript
NCORES=`${RSCRIPT_BIN} -e "cat(min(2, parallel::detectCores(logical = FALSE), na.rm=TRUE))"`

${RSCRIPT_BIN} --vanilla -e 'Sys.info()["sysname"] == "Darwin"' | grep TRUE > /dev/null
if [ $? -eq 0 ]; then
  SDK_PATH=`xcrun --sdk macosx --show-sdk-path`
 	AR=`which "$AR"`
  CMAKE_ADD_OSX_SYSROOT="-D CMAKE_OSX_SYSROOT=${SDK_PATH}"
else
  CMAKE_ADD_OSX_SYSROOT=""
fi

cd src

# Compile NLOpt from source
sh ./scripts/nlopt_download.sh ${RSCRIPT_BIN}
# Apply patches
patch -p1 -d nlopt-src < ../tools/patches/nlopt.patch
dot() { file=$1; shift; . "$file"; }
dot ./scripts/r_config.sh ""
${RSCRIPT_BIN} --vanilla -e 'getRversion() > "4.0.0"' | grep TRUE > /dev/null
if [ $? -eq 0 ]; then
  CMAKE_ADD_AR="-D CMAKE_AR=${AR}"
  CMAKE_ADD_RANLIB="-D CMAKE_RANLIB=${RANLIB}"
else
  CMAKE_ADD_AR=""
  CMAKE_ADD_RANLIB=""
fi
mkdir nlopt-build
mkdir nlopt
cd nlopt-build
${CMAKE_BIN} \
  -D BUILD_SHARED_LIBS=OFF \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_INSTALL_PREFIX=../nlopt \
  -D NLOPT_CXX=ON \
  -D NLOPT_GUILE=OFF \
  -D NLOPT_MATLAB=OFF \
  -D NLOPT_OCTAVE=OFF \
  -D NLOPT_PYTHON=OFF \
  -D NLOPT_SWIG=OFF \
  -D NLOPT_TESTS=OFF \
  ${CMAKE_ADD_AR} ${CMAKE_ADD_RANLIB} ${CMAKE_ADD_OSX_SYSROOT} ../nlopt-src

# Append R support to generated nlopt_config.h
cat >> nlopt_config.h <<EOF
#ifdef NLOPTR_R
#  include <stdio.h>
#  undef stderr
#  define stderr ((void*)2)
#  undef stdout
#  define stdout ((void*)1)

#  ifdef __cplusplus
     extern "C" {
#  endif
     void nlopt_abort(void) __attribute__((noreturn));
     void nlopt_exit(int status) __attribute__((noreturn));
     int nlopt_printf(const char *format, ...) __attribute__((format(printf, 1, 2)));
     int nlopt_fprintf(void *stream, const char *format, ...) __attribute__((format(printf, 2, 3)));
     int nlopt_putchar(int c);
     int nlopt_puts(const char *s);
#  ifdef __cplusplus
     }
#  endif

#  define abort nlopt_abort
#  define exit nlopt_exit
#  define printf nlopt_printf
#  define fprintf nlopt_fprintf
#  define putchar nlopt_putchar
#  define puts nlopt_puts

#  ifdef __cplusplus
#    include <ostream>
     class NullOStream : public std::ostream {
     public:
         NullOStream() : std::ostream(nullptr) {}
     };
     extern NullOStream null_ostream;
#    define cout null_ostream
#    define cerr null_ostream
#  endif
#endif
EOF

make -j${NCORES}
make install
cd ..

lib_folder=`ls -d nlopt/lib*`
echo "Moving ${lib_folder} to nlopt/lib"
if [ ${lib_folder} != "nlopt/lib" ]; then
  mv ${lib_folder} nlopt/lib
fi

# Cleanup
sh ./scripts/nlopt_cleanup.sh
