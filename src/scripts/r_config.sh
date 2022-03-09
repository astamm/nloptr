#### R CONFIGURATION ####

R_ARCH_BIN=$1

CC=`"${R_HOME}/bin${R_ARCH_BIN}/R" CMD config CC`
echo set CC=$CC
export CC

CPPFLAGS=`"${R_HOME}/bin${R_ARCH_BIN}/R" CMD config CPPFLAGS`
CFLAGS=`"${R_HOME}/bin${R_ARCH_BIN}/R" CMD config CFLAGS`
CPICFLAGS=`"${R_HOME}/bin${R_ARCH_BIN}/R" CMD config CPICFLAGS`

CFLAGS="$CPPFLAGS $CPICFLAGS $CFLAGS"
echo set CFLAGS=$CFLAGS
export CFLAGS

CXX=`"${R_HOME}/bin${R_ARCH_BIN}/R" CMD config CXX11`
echo set CXX=$CXX
export CXX

CXXSTD=`"${R_HOME}/bin${R_ARCH_BIN}/R" CMD config CXX11STD`
CXXFLAGS=`"${R_HOME}/bin${R_ARCH_BIN}/R" CMD config CXX11FLAGS`
CXXPICFLAGS=`"${R_HOME}/bin${R_ARCH_BIN}/R" CMD config CXX11PICFLAGS`

CXXFLAGS="$CXXSTD $CPPFLAGS $CXXPICFLAGS $CXXFLAGS"
echo set CXXFLAGS=$CXXFLAGS
export CXXFLAGS

LDFLAGS=`"${R_HOME}/bin${R_ARCH_BIN}/R" CMD config LDFLAGS`
echo set LDFLAGS=$LDFLAGS
export LDFLAGS

if test -z "$CXX"; then
    echo >&2 "Could not detect C++ compiler with R CMD config."
fi

${R_HOME}/bin${R_ARCH_BIN}/Rscript --vanilla -e 'getRversion() > "4.0.0"' | grep TRUE > /dev/null
if [ $? -eq 0 ]; then
 	AR=`"${R_HOME}/bin${R_ARCH_BIN}/R" CMD config AR`
 	AR=`which $AR`

 	RANLIB=`"${R_HOME}/bin${R_ARCH_BIN}/R" CMD config RANLIB`
 	RANLIB=`which $RANLIB`
fi
