# Microsoft specific config file 

SET (WORDS_BIGENDIAN )

SET (HAVE_LIMITS_H   1)

SET (HAVE_UNISTD_H   1)

SET (CMAKE_C_COMPILER cl CACHE FILEPATH
     "Name of C compiler used.")

SET (CMAKE_C_FLAGS "/W3 /Zm1000" CACHE STRING
     "Flags for C compiler.")

SET (CMAKE_C_OUTPUT_OBJECT_FILE_FLAG "/Fo" CACHE STRING
     "Flags used to specify output filename. No space will be appended.")

SET (CMAKE_C_OUTPUT_EXECUTABLE_FILE_FLAG "/Fe" CACHE STRING
     "Flags used to specify executable filename. No space will be appended.")

SET (CMAKE_C_LINK_EXECUTABLE_FLAG "/link" CACHE STRING
     "Flags used to create an executable.")

SET (CMAKE_C_LIBPATH_FLAG "-LIBPATH:" CACHE STRING
     "Flags used to specify a link path. No space will be appended.")

SET (CMAKE_LINKER link CACHE FILEPATH
     "Name of linker used.")

SET (CMAKE_LINKER_FLAGS "/nologo" CACHE STRING
     "Flags used by the linker.")

SET (CMAKE_LINKER_SHARED_LIBRARY_FLAG "/dll" CACHE STRING
     "Flags used to create a shared library.")

SET (CMAKE_LINKER_STATIC_LIBRARY_FLAG "-lib" CACHE STRING
     "Flags used to create a static library.")

SET (CMAKE_LINKER_OUTPUT_FILE_FLAG "/out:" CACHE STRING
     "Flags used to specify output filename. No space will be appended.")

SET (CMAKE_BUILD_TYPE Debug CACHE STRING 
     "Choose the type of build, options are: Debug Release RelWithDebInfo MinSizeRel.")

SET (CMAKE_CXX_COMPILER cl CACHE FILEPATH
     "Name of C++ compiler used.")

SET (CMAKE_CXX_FLAGS_RELEASE "/MD /O2" CACHE STRING
     "Flags used by the compiler during release builds (/MD /Ob1 /Oi /Ot /Oy /Gs will produce slightly less optimized but smaller files).")

SET (CMAKE_CXX_FLAGS_RELWITHDEBINFO "/MD /Zi /O2" CACHE STRING
     "Flags used by the compiler during Release with Debug Info builds.")

SET (CMAKE_CXX_FLAGS_MINSIZEREL "/MD /O1" CACHE STRING
     "Flags used by the compiler during release minsize builds.")

SET (CMAKE_CXX_FLAGS_DEBUG "/MDd /Zi /Od /GZ" CACHE STRING
     "Flags used by the compiler during debug builds.")

SET (CMAKE_CXX_FLAGS "/W3 /Zm1000 /GX /GR" CACHE STRING
     "Flags used by the compiler during all build types, /GX /GR are for exceptions and rtti in VC++, /Zm1000 increases the compiler's memory allocation to support ANSI C++/stdlib.")

SET (CMAKE_USE_WIN32_THREADS 1 CACHE BOOL 
     "Use the win32 thread library.")

SET (CMAKE_STANDARD_WINDOWS_LIBRARIES "kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib  kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib" CACHE STRING 
     "Libraries linked by defalut with all applications.")

SET (CMAKE_OBJECT_FILE_SUFFIX ".obj" CACHE STRING 
     "Object file suffix.")

SET (CMAKE_EXECUTABLE_SUFFIX ".exe" CACHE STRING 
     "Executable suffix.")

SET (CMAKE_STATICLIB_SUFFIX ".lib" CACHE STRING 
     "Static library suffix.")

SET (CMAKE_SHLIB_SUFFIX ".dll" CACHE STRING 
     "Shared library suffix.")

SET (CMAKE_MODULE_SUFFIX ".dll" CACHE STRING 
     "Module library suffix.")

SET (CMAKE_MAKE_PROGRAM "nmake" CACHE STRING 
     "Program used to build from makefiles.")

# The following variables are advanced 

MARK_AS_ADVANCED(
WORDS_BIGENDIAN
HAVE_LIMITS_H
HAVE_UNISTD_H
CMAKE_C_COMPILER
CMAKE_C_FLAGS
CMAKE_C_OUTPUT_OBJECT_FILE_FLAG
CMAKE_C_OUTPUT_EXECUTABLE_FILE_FLAG
CMAKE_C_LINK_EXECUTABLE_FLAG
CMAKE_C_LIBPATH_FLAG
CMAKE_LINKER
CMAKE_LINKER_FLAGS
CMAKE_LINKER_SHARED_LIBRARY_FLAG
CMAKE_LINKER_STATIC_LIBRARY_FLAG
CMAKE_LINKER_OUTPUT_FILE_FLAG
CMAKE_BUILD_TYPE
CMAKE_CXX_COMPILER
CMAKE_CXX_FLAGS_RELEASE
CMAKE_CXX_FLAGS_RELWITHDEBINFO
CMAKE_CXX_FLAGS_MINSIZEREL
CMAKE_CXX_FLAGS_DEBUG
CMAKE_CXX_FLAGSCMAKE_USE_WIN32_THREADS
CMAKE_STANDARD_WINDOWS_LIBRARIES
CMAKE_OBJECT_FILE_SUFFIX
CMAKE_EXECUTABLE_SUFFIX
CMAKE_STATICLIB_SUFFIX
CMAKE_SHLIB_SUFFIX
CMAKE_MODULE_SUFFIX
CMAKE_MAKE_PROGRAM
)
