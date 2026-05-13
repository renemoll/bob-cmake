#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-FileCopyrightText: 2025 René Moll
# SPDX-License-Identifier: MPL-2.0
#

#
# bob_firmware_image(<TARGET>
#     [LINKER_SCRIPTS <LINKER_SCRIPT>...])
#
# Configure the '<TARGET>' to generate outputs for embedded targets.
#
# Args:
#   TARGET: The target to configure the compiler for.
#   LINKER_SCRIPTS: List of linker scripts to use when linking the target.
#
function(bob_firmware_image TARGET)
	set(PARSE_OPTIONS)
	set(PARSE_ONE_VALUE_OPTIONS)
	set(PARSE_MULTI_VALUE_OPTIONS
		LINKER_SCRIPTS
	)
	cmake_parse_arguments(PARSE_ARGV 1 arg
		"${PARSE_OPTIONS}" "${PARSE_ONE_VALUE_OPTIONS}" "${PARSE_MULTI_VALUE_OPTIONS}"
	)

	target_link_options(${TARGET}
		PRIVATE
			LINKER:--print-memory-usage
			LINKER:-Map=$<TARGET_FILE:${TARGET}>.map
	)

	foreach(ldfile ${arg_LINKER_SCRIPTS})
		target_link_options(${TARGET} 
			PRIVATE
				-T${ldfile}
		)
	endforeach()

	set_target_properties(${TARGET}
		PROPERTIES
			SUFFIX .elf
		LINK_DEPENDS
			"${arg_LINKER_SCRIPTS}"
	)

	add_custom_command(
		TARGET 
			${TARGET}
		POST_BUILD
		COMMAND 
			${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${TARGET}>
			${CMAKE_CURRENT_BINARY_DIR}/$<TARGET_NAME:${TARGET}>.hex
		COMMENT "Generating Intel HEX firmware image for ${TARGET}"
	)

	add_custom_command(
		TARGET 
			${TARGET}
		POST_BUILD
		COMMAND
			${CMAKE_OBJCOPY} -I elf32-littlearm -O binary $<TARGET_FILE:${TARGET}>
			${CMAKE_CURRENT_BINARY_DIR}/$<TARGET_NAME:${TARGET}>.bin
		COMMENT "Generating raw binary firmware image for ${TARGET}"
	)

	add_custom_command(
		TARGET 
			${TARGET}
		POST_BUILD
		COMMAND
			${TOOLCHAIN_SIZE} --format=berkeley $<TARGET_FILE:${TARGET}>
			> ${CMAKE_CURRENT_BINARY_DIR}/$<TARGET_NAME:${TARGET}>.bsz
		COMMENT "Generating size report (Berkeley format) for ${TARGET}"
	)
	
	add_custom_command(
		TARGET 
			${TARGET}
		POST_BUILD
		COMMAND 
			${TOOLCHAIN_SIZE} --format=sysv -x $<TARGET_FILE:${TARGET}>
			>${CMAKE_CURRENT_BINARY_DIR}/$<TARGET_NAME:${TARGET}>.ssz
		COMMENT "Generating size report (System V format) for ${TARGET}"
	)

	add_custom_command(
		TARGET
			${TARGET}
		POST_BUILD
		COMMAND
			${TOOLCHAIN_OBJDUMP} -d -S $<TARGET_FILE:${TARGET}>
			>${CMAKE_CURRENT_BINARY_DIR}/$<TARGET_NAME:${TARGET}>.dasm
		COMMENT "Generating disassembly for ${TARGET}"
	)
endfunction()
