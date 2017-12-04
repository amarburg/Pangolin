if (NOT FIPS_IMPORT)
  cmake_minimum_required(VERSION 3.5.0)

  get_filename_component(FIPS_ROOT_DIR "../fips" ABSOLUTE)
  include("${FIPS_ROOT_DIR}/cmake/fips.cmake")

  fips_setup(PROJECT pangolin)
endif()


set(PANGOLIN_VERSION_MAJOR 0)
set(PANGOLIN_VERSION_MINOR 5)
set(PANGOLIN_VERSION ${PANGOLIN_VERSION_MAJOR}.${PANGOLIN_VERSION_MINOR})

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/")

# Platform configuration vars
include(SetPlatformVars)

SET(CPACK_GENERATOR "DEB")
SET(CPACK_DEBIAN_PACKAGE_MAINTAINER "Steven Lovegrove")
SET(CPACK_PACKAGE_VERSION_MAJOR ${PANGOLIN_VERSION_MAJOR})
SET(CPACK_PACKAGE_VERSION_MINOR ${PANGOLIN_VERSION_MINOR})
SET(CPACK_PACKAGE_VERSION_PATCH "0")
include(CPack)

option( BUILD_EXAMPLES "Build Examples" OFF )

if(_WIN_)
    option( BUILD_SHARED_LIBS    "Build Shared Library" OFF)
    option( BUILD_EXTERN_GLEW    "Automatically download, build and compile GLEW" ON)
    option( BUILD_EXTERN_LIBPNG  "Automatically download, build and compile libpng" ON)
    option( BUILD_EXTERN_LIBJPEG "Automatically download, build and compile libjpeg" ON)
    option( MSVC_USE_STATIC_CRT  "Use static C Runtime with MSVC, /MT instead of /MD" ON)

    # Make sure there are no erroneous C Runtime flags
    list(APPEND FLAG_VARS
        CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_RELWITHDEBINFO
        CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE CMAKE_C_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO
    )
    if(MSVC_USE_STATIC_CRT)
        foreach(FLAG_VAR ${FLAG_VARS})
            string(REGEX REPLACE "/MD" "/MT" NEW_FLAGS "${${FLAG_VAR}}")
            set(${FLAG_VAR} "${NEW_FLAGS}" CACHE STRING "" FORCE)
        endforeach()
    else()
        foreach(FLAG_VAR ${FLAG_VARS})
            string(REGEX REPLACE "/MT" "/MD" NEW_FLAGS "${${FLAG_VAR}}")
            set(${FLAG_VAR} "${NEW_FLAGS}" CACHE STRING "" FORCE)
        endforeach()
    endif()
else()
    option( BUILD_SHARED_LIBS "Build Shared Library" ON)
endif()

if(NOT MSVC)
    set( CMAKE_CXX_FLAGS "-std=c++11 -Wall -Wextra ${CMAKE_CXX_FLAGS}" )
    if(_CLANG_)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++")
    endif()
endif()

if(ANDROID)
    set(ANDROID_PACKAGE_NAME "com.github.stevenlovegrove.pangolin")
    include(AndroidUtils)
endif()

if(ANDROID OR IOS)
    set(HAVE_GLES 1)
    option(BUILD_FOR_GLES_2 "Build for OpenGL ES 2 instead of ES 1" ON )
    if(BUILD_FOR_GLES_2)
        set(HAVE_GLES_2 1)
    endif()
endif()

#if(APPLE)
	# https://cmake.org/Wiki/CMake_RPATH_handling
	# CONAN GUIDE: All generated libraries should have the id and dependencies to other
	# dylibs without path, just the name, EX:
	# libMyLib1.dylib:
	#     libMyLib1.dylib (compatibility version 0.0.0, current version 0.0.0)
	#     libMyLib0.dylib (compatibility version 0.0.0, current version 0.0.0)
	#     /usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 120.0.0)
	#     /usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1197.1.1)
	#set(CMAKE_SKIP_RPATH 1)  # AVOID RPATH FOR *.dylib, ALL LIBS BETWEEN THEM AND THE EXE
	# SHOULD BE ON THE LINKER RESOLVER PATH (./ IS ONE OF THEM)
#endif()

# Overide with cmake -DCMAKE_BUILD_TYPE=Debug {dir}
if( NOT CMAKE_BUILD_TYPE AND NOT _WIN_ )
   message("Build type not set (defaults to release)")
   message("-DCMAKE_BUILD_TYPE=Debug for debug")
   set( CMAKE_BUILD_TYPE Release )
endif()

string(TOLOWER ${PROJECT_NAME} LIBRARY_NAME)

# make an uninstall target
configure_file(
 	"${CMAKE_CURRENT_SOURCE_DIR}/cmake_uninstall.cmake.in"
  	"${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
  	IMMEDIATE @ONLY
)

add_custom_target(uninstall
  "${CMAKE_COMMAND}" -P "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake")

fips_include_directories( "${FIPS_PROJECT_BUILD_DIR}/include/" )

fips_add_subdirectory("external")
fips_add_subdirectory("src")
fips_add_subdirectory("test")

if(BUILD_EXAMPLES)
  set(Pangolin_DIR ${Pangolin_BINARY_DIR}/src)
  add_subdirectory(examples)
  add_subdirectory(tools)
endif()

if( NOT FIPS_IMPORT )
  fips_finish()
endif()
