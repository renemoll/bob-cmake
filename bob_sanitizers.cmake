#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-FileCopyrightText: 2025 René Moll
# SPDX-License-Identifier: MPL-2.0
#

#
# Compiler sanitizer configuration
#
# Todo:
# - Hardware-assisted AddressSanitizer
#
# Note:
# - Disabled MemorySanitizer as this requires the complete code base
#   (inc external dependencies such as libc++) to be compiled with it.
#

option(BOB_SANITIZE_ADDRESS "Enable AddressSanitizer" On)
option(BOB_SANITIZE_LEAK "Enable LeakSanitizer" On)
option(BOB_SANITIZE_UNDEFINED "Enable UndefinedBehaviorSanitizer" On)
# option(BOB_SANITIZE_MEMORY "Enable MemorySanitizer" Off)
option(BOB_SANITIZE_THREAD "Enable ThreadSanitizer" Off)

#
# Enable compiler sanitizers for the given `target`.
#
# Args:
#   - target: the target to configure
#
function(bob_configure_sanitizers target)

	#
	# Determine which sanitizers to enable
	#
	set(sanitizers "")

	if(BOB_SANITIZE_ADDRESS)
		list(APPEND sanitizers "address")
	endif()

	if(BOB_SANITIZE_LEAK)
		list(APPEND sanitizers "leak")
	endif()

	if(BOB_SANITIZE_UNDEFINED)
		list(APPEND sanitizers "undefined")
	endif()

	if(BOB_SANITIZE_THREAD)
		if("address" IN_LIST sanitizers OR "leak" IN_LIST sanitizers)
			bob_error("ThreadSanitizer cannot be combined with AddressSanitizer or LeakSanitizer")
		else()
			list(APPEND sanitizers "thread")
		endif()
	endif()

	# if(BOB_SANITIZE_MEMORY)
	# 	if(BOB_COMPILER_CLANG)
	# 		list(APPEND sanitizers "memory")
	# 	else()
	# 		bob_info("MemorySanitizer is only supported by Clang")
	# 	endif()
	# endif()

	if(sanitizers)
		#
		# Update compiler options
		#

		if(NOT BOB_COVERAGE)
			add_compile_options(
				-O1						# Recommended for "reasonable performance"
				-fno-omit-frame-pointer # For better stack traces
				-g						# For file names and line numbers
			)
		endif()

		#
		# Add the sanitizer(s) to the given `target`
		#

		list(JOIN sanitizers "," list_of_sanitizers)

		target_compile_options(${target}
			INTERFACE
				-fsanitize=${list_of_sanitizers}
		)
		target_link_options(${target}
			INTERFACE
				-fsanitize=${list_of_sanitizers}
		)
	endif()
endfunction()
