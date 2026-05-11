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
# bob_configure_static_analysis(<target>
#     [ENABLE_CLANG_TIDY <ON|OFF>]
#     [ENABLE_CPPCHECK <ON|OFF>])
#
# Enable and configure static analysis tools for the given `<target>`.
#
# Args:
#   target: The target to run static analysis on.
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
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "${parse_options}" "${parse_one_value_options}" "${parse_multi_value_options}"
    )

    set(enable_clang_tidy ${BOB_CLANG_TIDY})
    if (DEFINED arg_ENABLE_CLANG_TIDY)
        set(enable_clang_tidy ${arg_ENABLE_CLANG_TIDY})
    endif()
	bob_debug("ENABLE_CLANG_TIDY: ${enable_clang_tidy}")
	if (enable_clang_tidy)
		bob_configure_clang_tidy(${target})
	endif()

    set(enable_cppcheck ${BOB_CPPCHECK})
    if (DEFINED arg_ENABLE_CPPCHECK)
        set(enable_cppcheck ${arg_ENABLE_CPPCHECK})
    endif()
	bob_debug("ENABLE_CPPCHECK: ${enable_cppcheck}")
    if (enable_cppcheck)
		bob_configure_cppcheck(${target})
	endif()
endfunction()
