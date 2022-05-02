#### CMAKE CONFIGURATION ####

if test -z "$CMAKE_BIN"; then
  # Look for a cmake3 binary in the current path
  CMAKE_BIN=`which cmake3 2>/dev/null`
fi

if test -z "$CMAKE_BIN"; then
  # Look for a cmake binary in the current path
  CMAKE_BIN=`which cmake 2>/dev/null`
fi

if test -z "$CMAKE_BIN"; then
  # Check for a MacOS specific path
  CMAKE_BIN=`which /Applications/CMake.app/Contents/bin/cmake 2>/dev/null`
fi

if test -z "$CMAKE_BIN"; then
  echo ""
  echo "------------------ CMAKE NOT FOUND --------------------"
  echo ""
  echo "CMake was not found on the PATH. Please install CMake:"
  echo ""
  echo " - sudo yum install cmake          (Fedora/CentOS; inside a terminal)"
  echo " - sudo apt install cmake          (Debian/Ubuntu; inside a terminal)."
  echo " - sudo pacman -S cmake            (Arch Linux; inside a terminal)."
  echo " - sudo brew install cmake         (MacOS; inside a terminal with Homebrew)"
  echo " - sudo port install cmake         (MacOS; inside a terminal with MacPorts)"
  echo ""
  echo "Alternatively install CMake from: <https://cmake.org/>"
  echo ""
  echo "-------------------------------------------------------"
  echo ""

  exit 1
fi

echo set CMAKE_BIN=$CMAKE_BIN
