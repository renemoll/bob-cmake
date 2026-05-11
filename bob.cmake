#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-FileCopyrightText: 2025 René Moll
# SPDX-License-Identifier: MPL-2.0
#

#
# Meet Bob: my collection of build tools
#

cmake_minimum_required(VERSION 3.21 FATAL_ERROR)

#
# Options
#

option(BOB_VERBOSE "Enable verbose output" Off)

#
# bob_debug(<MESSAGE>)
#
# Prints the debug `<MESSAGE>` if BOB_VERBOSE is enabled.
#
function(bob_debug)
	if (BOB_VERBOSE)
		message(STATUS "[BOB] Debug: ${ARGN}")
	endif()
endfunction()

#
# bob_info(<MESSAGE>)
#
# Prints an informational `<MESSAGE>`.
#
function(bob_info)
	message(STATUS "[BOB] Info: ${ARGN}")
endfunction()

#
# bob_error(<MESSAGE>)
#
# Prints an error `<MESSAGE>` and stops the build.
#
function(bob_error)
	message(FATAL_ERROR "[BOB] Error: ${ARGN}")
endfunction()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/compiler")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/static_analysis")

#
# Ensure an out of source build folder.
#
function(ensure_out_of_source_build)
	get_filename_component(srcdir "${CMAKE_SOURCE_DIR}" REALPATH)
	get_filename_component(bindir "${CMAKE_BINARY_DIR}" REALPATH)

	if("${srcdir}" STREQUAL "${bindir}")
		bob_error("in-source build detected.")
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
	bob_info("no build type selected, defaulting to 'Release'.")
	set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build configuration" FORCE)
	set(CMAKE_CONFIGURATION_TYPES "Release" CACHE STRING "Available build configurations" FORCE)
endif()

bob_info("CMAKE_BUILD_TYPE is `${CMAKE_BUILD_TYPE}`, CMAKE_CONFIGURATION_TYPES is `${CMAKE_CONFIGURATION_TYPES}`.")

#
# Generate a version header
#

if(NOT BOB_USER_VERSION_HEADER)
	set(BOB_USER_VERSION_HEADER "${CMAKE_CURRENT_LIST_DIR}/templates/version.h.in")
endif()
bob_info("generating version header from template: ${BOB_USER_VERSION_HEADER}")
configure_file(${BOB_USER_VERSION_HEADER} version.h ESCAPE_QUOTES)

#
# Includes
#

include(bob_compiler)
include(bob_static_analysis)
# include(bob_coverage)
# include(bob_sanitizers)
# include(bob_tools)
# include(bob_firmware_image)

#
# bob_configure_target(<TARGET>
#     [ENABLE_STRICT_WARNINGS <ON|OFF>]
#     [ENABLE_CLANG_TIDY <ON|OFF>]
#     [ENABLE_CPPCHECK <ON|OFF>])
#
# Configure the given `<TARGET>` with the specified options.
#
# Args:
#   TARGET: The target to configure.
#   ENABLE_STRICT_WARNINGS: Enable strict compiler warnings for this target.
#   ENABLE_CLANG_TIDY: Enable `clang-tidy` for this target (if `BOB_CLANG_TIDY` is enabled).
#   ENABLE_CPPCHECK: Enable `cppcheck` for this target (if `BOB_CPPCHECK` is enabled).
#
function(bob_configure_target TARGET)
	set(parse_options)
	set(parse_one_value_options
		# Compiler options
		ENABLE_STRICT_WARNINGS
		# Static analysis options
		ENABLE_CLANG_TIDY
		ENABLE_CPPCHECK
	)
	set(parse_multi_value_options)
	cmake_parse_arguments(PARSE_ARGV 1 arg
		"${parse_options}" "${parse_one_value_options}" "${parse_multi_value_options}"
	)

	set(ENABLE_STRICT_WARNINGS "${BOB_STRICT_COMPILER_WARNINGS}")
	if(DEFINED arg_ENABLE_STRICT_WARNINGS)
		set(ENABLE_STRICT_WARNINGS "${arg_ENABLE_STRICT_WARNINGS}")
	endif()

	set(ENABLE_CLANG_TIDY "${BOB_CLANG_TIDY}")
	if(DEFINED arg_ENABLE_CLANG_TIDY)
		set(ENABLE_CLANG_TIDY "${arg_ENABLE_CLANG_TIDY}")
	endif()

	set(ENABLE_CPPCHECK "${BOB_CPPCHECK}")
	if(DEFINED arg_ENABLE_CPPCHECK)
		set(ENABLE_CPPCHECK "${arg_ENABLE_CPPCHECK}")
	endif()

	bob_configure_compiler(
		"${TARGET}"
		ENABLE_STRICT_WARNINGS "${ENABLE_STRICT_WARNINGS}"
	)

	bob_configure_static_analysis(
		"${TARGET}"
		ENABLE_CLANG_TIDY "${ENABLE_CLANG_TIDY}"
		ENABLE_CPPCHECK "${ENABLE_CPPCHECK}"
	)
endfunction()

#
# Generate a option header
#
if(NOT BOB_USER_CONFIG_HEADER)
	set(BOB_USER_CONFIG_HEADER "${CMAKE_CURRENT_SOURCE_DIR}/cmake/config_options.h.in")
endif()

if(EXISTS BOB_USER_CONFIG_HEADER)
	bob_info("generating config header from template: ${BOB_USER_CONFIG_HEADER}")
	configure_file(${BOB_USER_CONFIG_HEADER} config_options.h)
endif()
