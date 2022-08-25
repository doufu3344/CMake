set(CMAKE_STATIC_LIBRARY_PREFIX "lib")
set(CMAKE_STATIC_LIBRARY_SUFFIX ".a")
set(CMAKE_SHARED_LIBRARY_PREFIX "lib")
set(CMAKE_SHARED_LIBRARY_SUFFIX ".a")
set(CMAKE_SHARED_MODULE_PREFIX "lib")
set(CMAKE_SHARED_MODULE_SUFFIX ".so")
set(CMAKE_AIX_IMPORT_FILE_PREFIX "")
set(CMAKE_AIX_IMPORT_FILE_SUFFIX ".imp")
set(CMAKE_DL_LIBS "-lld")

set(CMAKE_MODULE_EXISTS 1)
set(CMAKE_FIND_LIBRARY_SUFFIXES ".a" ".so")

# RPATH support on AIX is called libpath.  By default the runtime
# libpath is paths specified by -L followed by /usr/lib and /lib.  In
# order to prevent the -L paths from being used we must force use of
# -Wl,-blibpath:/usr/lib:/lib whether RPATH support is on or not.
# When our own RPATH is to be added it may be inserted before the
# "always" paths.
if(NOT DEFINED CMAKE_PLATFORM_REQUIRED_RUNTIME_PATH)
  set(CMAKE_PLATFORM_REQUIRED_RUNTIME_PATH /usr/lib /lib)
endif()

# Files named "libfoo.a" may actually be shared libraries.
set_property(GLOBAL PROPERTY TARGET_ARCHIVES_MAY_BE_SHARED_LIBS 1)

include(Platform/UnixPaths)
