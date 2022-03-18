
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")

include(bob)


#
# Generate a single library with all options.
#

add_library(bob_interface INTERFACE)

bob_configure_compiler(bob_interface)

# bob_configure_clang_tidy(bob_interface)
# bob_configure_cppcheck(bob_interface)
