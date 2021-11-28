#! /bin/sh

CMAKE_BIN=$1
NCORES=$2
ARCH=$3

"${CMAKE_BIN}" --build nlopt${ARCH}-build -j ${NCORES} --config Release
"${CMAKE_BIN}" --install nlopt${ARCH}-build --prefix nlopt${ARCH}
rm -fr nlopt${ARCH}-build
