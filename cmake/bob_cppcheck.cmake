
option(BOB_CPPCHECK "Execute `cppcheck`" On)

function(bob_configure_cppcheck TARGET)
	find_program(BOB_CPPCHECK_EXE NAMES cppcheck)
	if (BOB_CPPCHECK_EXE AND BOB_CPPCHECK)
		message(STATUS "Enabling `cppcheck` for ${TARGET}")

		set(options
			"--enable=all"
			"-i${PROJECT_COURCE_DIR}/build"
			"--suppressions-list=${PROJECT_COURCE_DIR}/.cppcheck_suppressions"
		)

		set_target_properties(${TARGET}
			PROPERTIES
				C_CPPCHECK "cppcheck;--std=c11;{$options}"
				CXX_CPPCHECK "cppcheck;--std=c++20;{$options}"
		)
	else()
		set_target_properties(${TARGET}
			PROPERTIES
				C_CPPCHECK ""
				CXX_CPPCHECK ""
		)
	endif()
endfunction()
