if(WIN32 OR CYGWIN OR NO_NAMELINK)
  set(_check_files)
else()
  set(_check_files
    [[lib]]
    [[lib/libnamelink-none\.(so|dylib|a)]]
    [[lib/libnamelink-only\.(so|dylib|a)]]
    [[lib/libnamelink-sep\.(so|dylib|a)]]
    [[lib/libnamelink-uns-dev\.(so|dylib|a)]]
  )
endif()
check_installed("^${_check_files}$")
