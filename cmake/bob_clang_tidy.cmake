
option(BOB_CLANG_TIDY "Execute `clang-tidy`" On)

#
# Configure `clang-tidy` for the given `TARGET`.
#
function(bob_configure_clang_tidy TARGET)
	find_program(BOB_CLANG_TIDY_EXE NAMES clang-tidy)

	if (BOB_CLANG_TIDY_EXE AND BOB_CLANG_TIDY)
		message(STATUS "Enabling `clang-tidy` for ${TARGET}")

		set_target_properties(${TARGET}
			PROPERTIES
				C_CLANG_TIDY "clang-tidy"
				CXX_CLANG_TIDY "clang-tidy"
		)
	else()
		if (BOB_CLANG_TIDY AND NOT BOB_CLANG_TIDY_EXE)
			message(WARNING "Request for `clang-tidy` failed as the executable could not be found")
		endif()

		set_target_properties(${TARGET}
			PROPERTIES
				C_CLANG_TIDY ""
				CXX_CLANG_TIDY ""
		)
	endif()
endfunction()
