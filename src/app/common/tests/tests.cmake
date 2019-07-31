#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2019 International Development & Integration Systems LLC
#

# This is the list of all files that should be included in the unit test build.
# You _should_ include .h/.hpp files here so they properly show up in IDEs.
idi_configure_file(CONFIGURED_FILENAME "${CMAKE_CURRENT_LIST_DIR}/test.cpp")
idi_component_test(common "${CONFIGURED_FILENAME}")
idi_configure_file(CONFIGURED_FILENAME "${CMAKE_CURRENT_LIST_DIR}/test_public.cpp")
idi_component_test_public(common "${CONFIGURED_FILENAME}")
