#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-FileCopyrightText: 2025 René Moll
# SPDX-License-Identifier: MPL-2.0
#

#
# Configure the target to generate outputs for embedded targets.
#
# Args:
#   - target: the target to configure
#   - linker_scripts: list of linker scripts to use when linking the target
#
function(bob_firmware_image target linker_scripts)
	target_link_options(${target}
		PRIVATE
			LINKER:--print-memory-usage
			LINKER:-Map=$<TARGET_FILE:${target}>.map
	)

	foreach(ldfile ${linker_scripts})
		target_link_options(${target} PRIVATE
			-T${ldfile}
		)
	endforeach()

	set_target_properties(${target}
		PROPERTIES
			SUFFIX .elf
		LINK_DEPENDS
			"${linker_scripts}"
	)

	add_custom_command(
		TARGET ${target}
		POST_BUILD
		COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${target}>
			${CMAKE_CURRENT_BINARY_DIR}/$<TARGET_NAME:${target}>.hex
		COMMENT "Generating Intel HEX firmware image for ${target}"
	)

	add_custom_command(
		TARGET ${target}
		POST_BUILD
		COMMAND ${CMAKE_OBJCOPY} -I elf32-littlearm -O binary $<TARGET_FILE:${target}>
			${CMAKE_CURRENT_BINARY_DIR}/$<TARGET_NAME:${target}>.bin
		COMMENT "Generating raw binary firmware image for ${target}"
	)

	add_custom_command(
		TARGET ${target}
		POST_BUILD
		COMMAND ${TOOLCHAIN_SIZE} --format=berkeley $<TARGET_FILE:${target}>
			> ${CMAKE_CURRENT_BINARY_DIR}/$<TARGET_NAME:${target}>.bsz
		COMMENT "Generating size report (Berkeley format) for ${target}"
	)
	add_custom_command(
		TARGET ${target}
		POST_BUILD
		COMMAND ${TOOLCHAIN_SIZE} --format=sysv -x $<TARGET_FILE:${target}>
			>${CMAKE_CURRENT_BINARY_DIR}/$<TARGET_NAME:${target}>.ssz
		COMMENT "Generating size report (System V format) for ${target}"
	)

	add_custom_command(
		TARGET ${target}
		POST_BUILD
		COMMAND ${TOOLCHAIN_OBJDUMP} -d -S $<TARGET_FILE:${target}>
			>${CMAKE_CURRENT_BINARY_DIR}/$<TARGET_NAME:${target}>.dasm
		COMMENT "Generating disassembly for ${target}"
	)
endfunction()
