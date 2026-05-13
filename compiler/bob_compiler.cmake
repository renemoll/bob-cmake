#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-FileCopyrightText: 2025 René Moll
# SPDX-License-Identifier: MPL-2.0
#

#
# Compiler identification
#

if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
	set(BOB_COMPILER_CLANG On)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
	set(BOB_COMPILER_GCC On)
elseif(MSVC)
	set(BOB_COMPILER_MSVC On)
else()
	bob_error("unsupported compiler.")
endif()

#
# Compiler configuration
#

# Generate colourized diagnostic warnings.
if(BOB_COMPILER_CLANG)
	add_compile_options(
		-fcolor-diagnostics
	)
elseif(BOB_COMPILER_GCC)
	add_compile_options(
		-fdiagnostics-color=always
	)
else()
	bob_error("unsupported compiler.")
endif()

#
# Includes
#

include(bob_compiler_warnings)
include(bob_firmware_image)

#
# bob_configure_compiler(<TARGET>
#     [ENABLE_STRICT_WARNINGS <ON|OFF>])
#
# Configure the compiler for the given `<TARGET>`.
#
# Args:
#   TARGET: The target to configure the compiler for.
#   ENABLE_STRICT_WARNINGS: Enable strict compiler warnings for this target.
#
function(bob_configure_compiler TARGET)
	set(PARSE_OPTIONS)
	set(PARSE_ONE_VALUE_OPTIONS
		ENABLE_STRICT_WARNINGS
	)
	set(PARSE_MULTI_VALUE_OPTIONS)
	cmake_parse_arguments(PARSE_ARGV 1 arg
		"${PARSE_OPTIONS}" "${PARSE_ONE_VALUE_OPTIONS}" "${PARSE_MULTI_VALUE_OPTIONS}"
	)

	bob_debug("ENABLE_STRICT_WARNINGS: ${arg_ENABLE_STRICT_WARNINGS}")
	if (arg_ENABLE_STRICT_WARNINGS)
		bob_configure_compiler_warnings(${TARGET})
	endif()
endfunction()
