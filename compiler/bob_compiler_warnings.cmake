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

option(BOB_STRICT_COMPILER_WARNINGS "Enable strict compiler warnings by default" On)
if(BOB_COMPILER_CLANG)
	option(BOB_CLANG_WARN_EVERYTHING "Enable `-Weverything` for Clang" Off)
endif()

#
# Helpers
#

include(CheckCompilerFlag)

#
# filter_compiler_flags(<LANG> <FLAGS> <OUTPUT>)
#
# Given a list of `FLAGS`, generate a list of supported flags (`OUTPUT`) for the given language (`LANG`).
#
# Args:
#   LANG: The language to check the flags for (e.g. C, CXX, ASM, ..).
#   FLAGS: A list of flags to check.
#   OUTPUT: The variable to store the supported flags in.
#
function(_filter_compiler_flags LANG FLAGS OUTPUT)
	get_property(enabled_languages GLOBAL PROPERTY ENABLED_LANGUAGES)
	set(RESULT "")

	if(${LANG} IN_LIST enabled_languages)
		foreach(flag IN LISTS FLAGS)
			string(REPLACE - _ flag_available ${flag})
			check_compiler_flag(${LANG} ${flag} ${flag_available})
			if (${flag_available})
				list(APPEND RESULT ${flag})
			endif()
		endforeach()
	endif()

	set(${OUTPUT} "${RESULT}" PARENT_SCOPE)
endfunction()

#
# bob_configure_compiler_warnings(<TARGET>)
#
# Apply compiler warnings to the given `<TARGET>`.
#
# Args:
#   TARGET: The target to apply the compiler warnings to.
#
function(bob_configure_compiler_warnings TARGET)
	set(WARNINGS "")
	set(C_WARNINGS "")
	set(CXX_WARNINGS "")

	if (BOB_COMPILER_CLANG OR BOB_COMPILER_GCC)
		list(APPEND WARNINGS
			# General
			-Wall								# Enable warnings for common coding mistakes or potential errors.
			-Wextra								# Extensions for -Wall.
			-Werror								# Treat warnings as errors to fail the build in case of warnings.
			-Wpedantic							# Warn about non-standard C/C++.
			# (Type) conversion
			-Wconversion						# Warn about implicit type conversions which (may) change the value.
			-Wsign-conversion					# Warn about implicit sign conversions.
			-Wdouble-promotion					# Warn about floats being implicitly converted to doubles.
			-Wfloat-equal						# Warn about floating point values used in equality tests.
			-Wcast-qual							# Warn when casting removes a type qualifier from a pointer.
			-Wcast-align						# Warn when casting a pointers changes the alignment of the pointee.
			-Wstrict-overflow=2					# Warn about optimizations where signed overflow is assumed not to occur.
			# Misc
			-Wshadow							# Warn about duplicated variable names.
			-Wswitch-enum						# Warn about switch statements not using all possible enum values.
			-Wimplicit-fallthrough				# Warn about implicit, un-annotated, fallthrough.
			-Wnull-dereference					# Warn about possible null pointer dereference code paths.
			-Wundef								# Warn when undefined macros are used (implicit conversion to 0.)
			-Wunused							# Warn about any unused parameter/function/variable/etc...
			-Wmisleading-indentation			# Warn about indentation giving the impression of scope.
			-Winline							# Warn when desired inlining is not possible.
			-Wzero-as-null-pointer-constant		# Warn about the use of 0 as nullptr.
			# Strings related
			-Wvla								# Warn about variable-length arrays being used.
			-Wwrite-strings						# Warn when attempting to write to a string constant.
			-Wformat=2							# Verify printf/scanf/.. arguments and format strings match.
		)

		list(APPEND C_WARNINGS
			# (Type) conversion
			-Wbad-function-cast					# Warn about casts to function pointers.
			# Misc
			-Wstrict-prototypes					# Warn when a function declaration misses argument types.
		)

		list(APPEND CXX_WARNINGS
			# (Type) conversion
			-Wold-style-cast					# Warn about C-style casts.
			# Classes
			-Wnon-virtual-dtor					# Warn about base classes without virtual destructors.
			-Wctor-dtor-privacy					# Warn about classes which seemingly cannot be used.
			-Wsuggest-override					# Warn when a method overwriting a virtual method is not marked with override.
			-Woverloaded-virtual				# Warn when a derived function hides a virtual function of the base class.
		)
	endif()

	if(BOB_COMPILER_GCC)
		list(APPEND WARNINGS
			# (Type) conversion
			-Warith-conversion					# Warn about implicit type conversions during arithmetic operations.
			-Wcast-align=strict					# Warn when casting a pointers changes the alignment of the pointee.
			-Wshift-overflow=2					# Warn about left shifting a 1 into the sign bit.
			# Misc
			-Wduplicated-branches				# Warn about identical branches in if-else expressions.
			-Wduplicated-cond					# Warn about duplicated conditions in if-else expressions.
			-Wredundant-decls					# Warn about multiple declarations within the same scope.
			-Wlogical-op						# Warn about potential errors with logical operations.
			-Wtrampolines						# Warn about code to jump to a function, requiring an executable stack.
			-Warray-bounds=2					# Warns about invalid array indices.
			-Wstrict-null-sentinel				# Warn about the use of an uncasted NULL as sentinel.
			-Wtrivial-auto-var-init				# Warn about automatic variables which might be uninitialized.
			# Strings related
			-Wformat-truncation=2				# Warn when the output of sprintf/... might be truncated.
		)

		list(APPEND CXX_WARNINGS
			# (Type) conversion
			-Wuseless-cast						# Warn about casting to the same type.
		)
	elseif(BOB_COMPILER_CLANG)
		list(APPEND WARNINGS
			# (Type) conversion
			-Wshift-sign-overflow				# Warn about left shifting a 1 into the sign bit.
			-Wzero-as-null-pointer-constant		# Warn about using 0 as a null pointer.
			# Misc
			-Wshadow-all						# Additional shadowing checks.
			-Wconditional-uninitialized			# Warn about variables which might be uninitialized.
			-Wloop-analysis						# Warn about loop variables being manipulated/ignored/.. inside the loop
			# Strings related
			-Wformat-type-confusion				# Warn when an argument does match the format specified type.
		)

		if (BOB_CLANG_WARN_EVERYTHING)
			list(APPEND WARNINGS
				-Weverything					# Enable all diagnostic warnings.
			)
		endif()
	else()
		bob_error("unsupported compiler.")
	endif()

	# Merge the lists into 2: one for C and one for C++
	list(APPEND C_WARNINGS "${WARNINGS}")
	list(APPEND CXX_WARNINGS "${WARNINGS}")

	set(C_WARNINGS_FILTERED "")
	_filter_compiler_flags(C "${C_WARNINGS}" C_WARNINGS_FILTERED)
	set(CXX_WARNINGS_FILTERED "")
	_filter_compiler_flags(CXX "${CXX_WARNINGS}" CXX_WARNINGS_FILTERED)

	target_compile_options(${TARGET}
		PRIVATE
			$<$<COMPILE_LANGUAGE:C>:${C_WARNINGS_FILTERED}>
			$<$<COMPILE_LANGUAGE:CXX>:${CXX_WARNINGS_FILTERED}>
	)
endfunction()
