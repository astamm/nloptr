#! /bin/sh

: ${R_HOME=$(R RHOME)}
RSCRIPT_BIN=${R_HOME}/bin/Rscript
NCORES=`${RSCRIPT_BIN} -e "cat(min(2, parallel::detectCores(logical = FALSE)))"`

cd src

#### CMAKE CONFIGURATION ####
. ./scripts/cmake_config.sh

# Compile NLOpt from source
sh ./scripts/nlopt_download.sh ${RSCRIPT_BIN}
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
${CMAKE_BIN} \
  -D BUILD_SHARED_LIBS=OFF \
  -D CMAKE_BUILD_TYPE=Release \
  -D INSTALL_LIB_DIR=nlopt/lib \
  -D NLOPT_CXX=ON \
  -D NLOPT_GUILE=OFF \
  -D NLOPT_MATLAB=OFF \
  -D NLOPT_OCTAVE=OFF \
  -D NLOPT_PYTHON=OFF \
  -D NLOPT_SWIG=OFF \
  -D NLOPT_TESTS=OFF \
  -S nlopt-src \
  -B nlopt-build ${CMAKE_ADD_AR} ${CMAKE_ADD_RANLIB}
sh ./scripts/nlopt_install.sh ${CMAKE_BIN} ${NCORES} ""

# Cleanup
sh ./scripts/nlopt_cleanup.sh
