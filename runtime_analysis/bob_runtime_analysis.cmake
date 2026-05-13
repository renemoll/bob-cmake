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

include(bob_sanitizers)

#
# bob_configure_runtime_analysis(<TARGET>
#     [ENABLE_ADDRESS_SANITIZER <ON|OFF>]
#     [ENABLE_LEAK_SANITIZER <ON|OFF>]
#     [ENABLE_UNDEFINED_BEHAVIOR_SANITIZER <ON|OFF>]
#     [ENABLE_THREAD_SANITIZER <ON|OFF>])
#
# Enable and configure runtime analysis tools for the given `<TARGET>`.
#
# Args:
#   TARGET: The target to run runtime analysis on.
#   ENABLE_ADDRESS_SANITIZER: Enable address sanitizer for this target.
#   ENABLE_LEAK_SANITIZER: Enable leak sanitizer for this target.
#   ENABLE_UNDEFINED_BEHAVIOUR_SANITIZER: Enable undefined behaviour sanitizer for this target.
#   ENABLE_THREAD_SANITIZER: Enable thread sanitizer for this target.
#
function(bob_configure_runtime_analysis TARGET)
	set(PARSE_OPTIONS)
	set(PARSE_ONE_VALUE_OPTIONS
		ENABLE_ADDRESS_SANITIZER
        ENABLE_LEAK_SANITIZER
        ENABLE_UNDEFINED_BEHAVIOUR_SANITIZER
        ENABLE_THREAD_SANITIZER
	)
	set(PARSE_MULTI_VALUE_OPTIONS)
	cmake_parse_arguments(PARSE_ARGV 1 arg
		"${PARSE_OPTIONS}" "${PARSE_ONE_VALUE_OPTIONS}" "${PARSE_MULTI_VALUE_OPTIONS}"
	)

    set(SANITIZERS "")
    if (arg_ENABLE_ADDRESS_SANITIZER)
        list(APPEND SANITIZERS "address")
    endif()
    if (arg_ENABLE_LEAK_SANITIZER)
        list(APPEND SANITIZERS "leak")
    endif()
    if (arg_ENABLE_UNDEFINED_BEHAVIOUR_SANITIZER)
        list(APPEND SANITIZERS "undefined")
    endif()
    if (arg_ENABLE_THREAD_SANITIZER)
        list(APPEND SANITIZERS "thread")
    endif()

	bob_debug("SANITIZERS: ${SANITIZERS}")
	if (SANITIZERS)
		bob_configure_sanitizers(${TARGET} SANITIZERS ${SANITIZERS})
	endif()
endfunction()
