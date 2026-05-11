#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-FileCopyrightText: 2026 René Moll
# SPDX-License-Identifier: MPL-2.0
#

#
# Includes
#

include(bob_clang_tidy)
include(bob_cppcheck)

#
# bob_configure_static_analysis(<TARGET>
#     [ENABLE_CLANG_TIDY <ON|OFF>]
#     [ENABLE_CPPCHECK <ON|OFF>])
#
# Enable and configure static analysis tools for the given `<TARGET>`.
#
# Args:
#   TARGET: The target to run static analysis on.
#   ENABLE_CLANG_TIDY: Enable `clang-tidy` for this target (if `BOB_CLANG_TIDY` is enabled).
#   ENABLE_CPPCHECK: Enable `cppcheck` for this target (if `BOB_CPPCHECK` is enabled).
#
function(bob_configure_static_analysis TARGET)
	set(parse_options)
	set(parse_one_value_options
		ENABLE_CLANG_TIDY
		ENABLE_CPPCHECK
	)
	set(parse_multi_value_options)
	cmake_parse_arguments(PARSE_ARGV 1 arg
		"${parse_options}" "${parse_one_value_options}" "${parse_multi_value_options}"
	)

	bob_debug("ENABLE_CLANG_TIDY: ${arg_ENABLE_CLANG_TIDY}")
	if (arg_ENABLE_CLANG_TIDY)
		bob_configure_clang_tidy(${TARGET})
	endif()

	bob_debug("ENABLE_CPPCHECK: ${arg_ENABLE_CPPCHECK}")
	if (arg_ENABLE_CPPCHECK)
		bob_configure_cppcheck(${TARGET})
	endif()
endfunction()
