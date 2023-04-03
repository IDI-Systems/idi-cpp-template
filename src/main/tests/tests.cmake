#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2023 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

# This is the list of all files that should be included in the unit test build.
# You _should_ include .h/.hpp files here so they properly show up in IDEs.

if(IDI_IS_LIBRARY AND IDI_IS_SHARED)
    idi_configure_file(CONFIGURED_FILENAME "${CMAKE_CURRENT_LIST_DIR}/dll_test.cpp")
    idi_component_test_public(main "${CMAKE_CURRENT_LIST_DIR}/dll_test.out.cpp")
endif()
