#
# Meet Bob: my collection of build tools
#

cmake_minimum_required(VERSION 3.10 FATAL_ERROR)

#
# Ensure an out of source build folder.
#
function(ensure_out_of_source_build)
  get_filename_component(srcdir "${CMAKE_SOURCE_DIR}" REALPATH)
  get_filename_component(bindir "${CMAKE_BINARY_DIR}" REALPATH)

  if("${srcdir}" STREQUAL "${bindir}")
	message(FATAL_ERROR "\n
		In-source build detected!\
		Generate an out of source build with:\
		\
			cmake -S . -B build")
  endif()
endfunction()
ensure_out_of_source_build()

#
# Generate compile_commands.json for Clang based tools.
# Note: this does not require a clang based toolchain.
#
set(CMAKE_EXPORT_COMPILE_COMMANDS On)

#
# Ensure a build configuration.
#
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
	message(STATUS "Defaulting build type to 'RelWithDebInfo'.")
	set(CMAKE_BUILD_TYPE "RelWithDebInfo" CACHE STRING "Build configuration" FORCE)
endif()

message(STATUS "CMAKE_BUILD_TYPE is ${CMAKE_BUILD_TYPE}")

include(bob_compiler)

include(bob_clang_tidy)
include(bob_cppcheck)


function(bob_enable_static_analyzers TARGET)
	bob_configure_cppcheck(${TARGET})
	bob_configure_clang_tidy(${TARGET})
endfunction()
