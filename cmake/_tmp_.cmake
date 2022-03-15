# set_target_properties(${target}
# 	PROPERTIES
# 		DEBUG_POSTFIX "d"
# 		RELWITHDEBINFO_POSTFIX "rd"
# )


		target_link_options(${target}
			PRIVATE
				LINKER:--fatal-warnings
		)

-fcolor-diagnostics
-Wstrict-overflow=2
-Wdisabled-optimization
-Wshift-overflow=2
-Wnoexcept
-Wzero-as-null-pointer-constant
