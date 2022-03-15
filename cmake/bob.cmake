#
# Meet Bob: my collection of build tools
#

#
# Ensure an out of source build folder.
#
function(ensure_out_of_source_build)
  get_filename_component(srcdir "${CMAKE_SOURCE_DIR}" REALPATH)
  get_filename_component(bindir "${CMAKE_BINARY_DIR}" REALPATH)

  if(${srcdir} STREQUAL ${bindir})
    message(FATAL_ERROR "In-source build detected!\
            Generate an out of source build with:\
            \
                cmake -S . -B build")
  endif()
endfunction()
ensure_out_of_source_build()

#
# Ensure a build configuration.
#
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to 'RelWithDebInfo' as none was specified.")
  set(CMAKE_BUILD_TYPE "RelWithDebInfo" CACHE STRING "Build configuration" FORCE)
endif()

message(STATUS "CMAKE_BUILD_TYPE is ${CMAKE_BUILD_TYPE}")

#
# Generate compile_commands.json for Clang based tools.
#
set(CMAKE_EXPORT_COMPILE_COMMANDS On)

include("${CMAKE_CURRENT_LIST_DIR}/bob_compiler.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/bob_clang_tidy.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/bob_cppcheck.cmake")

#
# Generate a single library with all options.
#
add_library(bob_interface INTERFACE)

bob_configure_compiler(bob_interface)

bob_configure_clang_tidy(bob_interface)
bob_configure_cppcheck(bob_interface)
