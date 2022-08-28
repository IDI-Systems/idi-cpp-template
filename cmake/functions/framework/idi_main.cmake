#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2022 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

macro(idi_main)
    include("${CMAKE_CURRENT_LIST_DIR}/objects.cmake")
    target_include_directories("${IDI_MAIN_TARGET}" PRIVATE "${CMAKE_CURRENT_LIST_DIR}")
    include("${CMAKE_CURRENT_LIST_DIR}/tests/tests.cmake")
endmacro()
