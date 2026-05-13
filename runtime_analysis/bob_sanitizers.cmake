#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-FileCopyrightText: 2025 René Moll
# SPDX-License-Identifier: MPL-2.0
#

#
# Options
#

option(BOB_ADDRESS_SANITIZER   				"Enable address sanitizer" On)
option(BOB_LEAK_SANITIZER  			    	"Enable leak sanitizer" On)
option(BOB_UNDEFINED_BEHAVIOUR_SANITIZER	"Enable undefined behaviour sanitizer" On)
# option(BOB_MEMORY_SANITIZER    "Enable memory sanitizer" Off)
option(BOB_THREAD_SANITIZER    				"Enable thread sanitizer" Off)

#
# bob_configure_sanitizers(<TARGET>
#     [SANITIZERS <sanitizer1> <sanitizer2> ...])
# 
# Enable compiler sanitizers for the given `<TARGET>`.
#
# Args:
#   TARGET: The target to run static analysis on.
#   SANITIZERS: A list of sanitizers to enable for this target.
#
# Supported sanitizers:
#   - address: AddressSanitizer
#   - leak: LeakSanitizer
#   - undefined: UndefinedBehaviourSanitizer
#   - thread: ThreadSanitizer
#
# Todo:
# - Hardware-assisted AddressSanitizer
#
# Note:
# - Disabled MemorySanitizer as this requires the complete code base
#   (inc external dependencies such as libc++) to be compiled with it.
#
function(bob_configure_sanitizers TARGET)
	set(PARSE_OPTIONS)
	set(PARSE_ONE_VALUE_OPTIONS)
	set(PARSE_MULTI_VALUE_OPTIONS
		SANITIZERS
	)
	cmake_parse_arguments(PARSE_ARGV 1 arg
		"${PARSE_OPTIONS}" "${PARSE_ONE_VALUE_OPTIONS}" "${PARSE_MULTI_VALUE_OPTIONS}"
	)

	if("thread" IN_LIST arg_SANITIZERS AND ("address" IN_LIST arg_SANITIZERS OR "leak" IN_LIST arg_SANITIZERS))
		bob_error("ThreadSanitizer cannot be combined with AddressSanitizer or LeakSanitizer")
	endif()

	if("memory" IN_LIST arg_SANITIZERS AND NOT BOB_COMPILER_CLANG)
		bob_error("MemorySanitizer is only supported by Clang")
	endif()

	#
	# Update compiler options, unless code coverage is enabled.
	# Code coverage has its own set of compiler options.
	#
	if(NOT BOB_COVERAGE)
		add_compile_options(
			-O1						# Recommended for "reasonable performance"
			-fno-omit-frame-pointer # For better stack traces
			-g						# For file names and line numbers
		)
	endif()

	string(JOIN "," SANITIZERS ${arg_SANITIZERS})
	target_compile_options(${TARGET}
		INTERFACE
			-fsanitize=${SANITIZERS}
	)
	target_link_options(${TARGET}
		INTERFACE
			-fsanitize=${SANITIZERS}
	)
endfunction()
