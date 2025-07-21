#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2025 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

macro(idi_main)
    include("${CMAKE_CURRENT_LIST_DIR}/objects.cmake")
    target_include_directories("${IDICMAKE_CORE}" PRIVATE "${CMAKE_CURRENT_LIST_DIR}")
    include("${CMAKE_CURRENT_LIST_DIR}/tests/tests.cmake")
endmacro()
