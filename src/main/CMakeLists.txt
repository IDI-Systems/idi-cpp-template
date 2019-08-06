#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2019 International Development & Integration Systems LLC
#

include("${CMAKE_CURRENT_LIST_DIR}/objects.cmake")

target_include_directories("${IDI_MAIN_TARGET}" PRIVATE "${CMAKE_CURRENT_LIST_DIR}")

include("${CMAKE_CURRENT_LIST_DIR}/tests/tests.cmake")
