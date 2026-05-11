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

option(BOB_CLANG_TIDY "Enable `clang-tidy`" On)

#
# bob_configure_clang_tidy(<TARGET>)
#
# Enable and configure `clang-tidy` for the given `<TARGET>`.
#
# Args:
#   TARGET: The target to run `clang-tidy` on.
#
function(bob_configure_clang_tidy TARGET)
	if (BOB_COVERAGE AND BOB_COMPILER_GCC)
		bob_info("disabling `clang-tidy` due to code coverage generation.")
		return()
	endif()

	find_program(CLANG_TIDY_EXE NAMES clang-tidy)

	if (BOB_CLANG_TIDY)
		if (NOT CLANG_TIDY_EXE)
			bob_error("request for `clang-tidy` failed as the executable could not be found.")
		endif()

		bob_info("enabling `clang-tidy` for '${TARGET}'.")

		set(CLANG_TIDY_OPTIONS
			"--config-file=${PROJECT_SOURCE_DIR}/.clang-tidy"
		)
		set_target_properties(${TARGET}
			PROPERTIES
				C_CLANG_TIDY "${CLANG_TIDY_EXE};${CLANG_TIDY_OPTIONS}"
				CXX_CLANG_TIDY "${CLANG_TIDY_EXE};${CLANG_TIDY_OPTIONS}"
		)

		# add_custom_target(${TARGET}_clang_tidy
		# 	COMMAND ${CLANG_TIDY_EXE} ${CLANG_TIDY_OPTIONS} -p=${CMAKE_BINARY_DIR} $<TARGET_PROPERTY:${TARGET},SOURCES>
		# 	WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
		# 	COMMENT "Running clang-tidy for target '${TARGET}'"
		# 	VERBATIM
		# )
	endif()
endfunction()
