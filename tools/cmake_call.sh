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
