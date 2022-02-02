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

# Only R > 4 will have the variables
$RSCRIPT_BIN --vanilla -e "getRversion() > 4" | grep TRUE > /dev/null
if [ $? -eq 0 ]; then
	NEW_R="-D CMAKE_AR=${AR} -D CMAKE_RANLIB=${RANLIB} "
else
	NEW_R=""
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
  -B nlopt-build ${NEW_R}
sh ./scripts/nlopt_install.sh ${CMAKE_BIN} ${NCORES} ""

# Cleanup
sh ./scripts/nlopt_cleanup.sh
