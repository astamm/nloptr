# Build against mingw-w64 build of nlopt
download.file(
  url = "https://github.com/rwinlib/nlopt/archive/refs/tags/v2.7.1.zip",
  destfile = "lib.zip",
  quiet = TRUE
)
unzip("lib.zip", exdir = "../src")
unlink("lib.zip")
