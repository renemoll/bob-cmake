#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-FileCopyrightText: 2025 René Moll
# SPDX-License-Identifier: MPL-2.0
#

#
# CMake module to generate code coverage reports
#
# To generate a report:
# 1. Enable BOB_COVERAGE
# 2. Call `bob_create_coverage_report` with a unit-test runner.
#

#
# Options
#

option(BOB_COVERAGE "Enable code coverage target creation" Off)

if(BOB_COVERAGE)
	if(BOB_COMPILER_CLANG)
		#
		# Following the instructions from: https://clang.llvm.org/docs/SourceBasedCodeCoverage.html
		#

		bob_info("generating llvm coverage report.")

		find_program(LLVM_PROFDATA_EXE NAMES llvm-profdata)
		if(NOT LLVM_PROFDATA_EXE)
			bob_error("llvm-profdata not found, cannot generate coverage report")
		endif()

		find_program(LLVM_COV_EXE NAMES llvm-cov)
		if(NOT LLVM_COV_EXE)
			bob_error("llvm-cov not found, cannot generate coverage report")
		endif()

		add_compile_options(
			-O0							# Disable optimizations when generating test-coverage
			-fno-elide-constructors
			-fprofile-instr-generate	# Instrument code to collect execution counts (default.profraw)
			-fcoverage-mapping			# Generate coverage mapping to enable code coverage analysis
			-fcoverage-mcdc				# Modified Condition/Decision Coverage (MC/DC)
		)
		add_link_options(
			-fprofile-instr-generate	# Instrument code to collect execution counts (default.profraw)
			-fcoverage-mapping			# Generate coverage mapping to enable code coverage analysis
		)
	elseif(BOB_COMPILER_GCC)
		#
		# Based on: https://gcovr.com/en/stable/guide/compiling.html
		#

		bob_info("generating gcov coverage report.")

		find_program(GCOVR_EXE NAMES gcovr)
		if(NOT GCOVR_EXE)
			bob_error("gcovr not found, cannot generate coverage report")
		endif()

		add_compile_options(
			-O0							# Disable optimizations when generating test-coverage
			-fno-elide-constructors
			--coverage					# Synonym for -fprofile-arcs -ftest-coverage & -lgcov
			# -fprofile-arcs			# Instrument code to produce gcov data files (*.gcda)
			# -ftest-coverage			# Produce gcov notes files (*.gcno)
			-fprofile-abs-path			# Use absolute instead of relative paths
		)
		add_link_options(
			--coverage
		)
	else()
		bob_error("unsupported compiler")
	endif()
endif()

#
# bob_generate_coverage_report(
#     TARGET <TARGET>
#     RUNNER <RUNNER>)
#
# Generate a coverage report.
#
# Args:
#   NAME: name of the coverage target
#   RUNNER: executable target to run the tests
#
function(bob_generate_coverage_report)
	if(NOT BOB_COVERAGE)
		return()
	endif()

	set(PARSE_OPTIONS)
	set(PARSE_ONE_VALUE_OPTIONS
		TARGET
		RUNNER
	)
	set(PARSE_MULTI_VALUE_OPTIONS)
	cmake_parse_arguments(PARSE_ARGV 0 arg
		"${PARSE_OPTIONS}" "${PARSE_ONE_VALUE_OPTIONS}" "${PARSE_MULTI_VALUE_OPTIONS}"
	)

	set(OUTPUT_FOLDER "${PROJECT_BINARY_DIR}/coverage_${arg_TARGET}")
	bob_info("generating coverage report in: ${OUTPUT_FOLDER}")

	if(BOB_COMPILER_CLANG)
		add_custom_target(${arg_TARGET}
			COMMAND ${CMAKE_COMMAND} -E env LLVM_PROFILE_FILE="${arg_TARGET}.profraw" $<TARGET_FILE:${arg_RUNNER}>
			COMMAND ${CMAKE_COMMAND} -E make_directory ${OUTPUT_FOLDER}
			COMMAND ${LLVM_PROFDATA_EXE} merge -sparse "${arg_TARGET}.profraw" -o "${arg_TARGET}.profdata"
			COMMAND ${LLVM_COV_EXE} show
					-ignore-filename-regex=".*[/\]tests[/\].*"
					-show-mcdc
					-show-line-counts-or-regions
					-format=html
					-instr-profile="${arg_TARGET}.profdata"
					$<TARGET_FILE:${arg_RUNNER}>
					> "${OUTPUT_FOLDER}/index.html"
			COMMAND ${LLVM_COV_EXE} report
					-ignore-filename-regex=".*[/\]tests[/\].*"
					-show-mcdc-summary
					-instr-profile="${arg_TARGET}.profdata"
					$<TARGET_FILE:${arg_RUNNER}>
					> "${OUTPUT_FOLDER}/report.txt"
			COMMAND ${LLVM_COV_EXE} export
					-format=lcov
					-instr-profile="${arg_TARGET}.profdata"
					$<TARGET_FILE:${arg_RUNNER}>
					> "${OUTPUT_FOLDER}/coverage.lcov"
			WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
			DEPENDS ${arg_RUNNER}
			COMMENT "Generating coverage report for ${arg_RUNNER}"
		)
	elseif(BOB_COMPILER_GCC)
		add_custom_target(${arg_TARGET}
			COMMAND ${arg_RUNNER}
			COMMAND ${CMAKE_COMMAND} -E make_directory ${OUTPUT_FOLDER}
			COMMAND ${GCOVR_EXE} -r ${PROJECT_SOURCE_DIR}
					--html-details
					--output "${OUTPUT_FOLDER}/index.html"
			COMMAND ${GCOVR_EXE} -r ${PROJECT_SOURCE_DIR}
					--cobertura-pretty
					--cobertura "${OUTPUT_FOLDER}/cobertura.xml"
			COMMAND ${GCOVR_EXE} -r ${PROJECT_SOURCE_DIR}
			WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
			DEPENDS ${arg_RUNNER}
			COMMENT "Generating coverage report for ${arg_RUNNER}"
		)
	else()
		bob_error("unsupported compiler")
	endif()
endfunction()
