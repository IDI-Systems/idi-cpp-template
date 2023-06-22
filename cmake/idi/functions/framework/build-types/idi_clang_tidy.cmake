#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2023 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    find_program(IS_TIDY "clang-tidy")
    if (IS_TIDY)
        message(STATUS "Found clang-tidy, will use it during compilation.")
        set(CMAKE_CXX_CLANG_TIDY clang-tidy -p ${CMAKE_BINARY_DIR} --config-file=${CMAKE_SOURCE_DIR}/.clang-tidy PARENT_SCOPE)
    else()
        message(FATAL_ERROR "clang-tidy is unable to be found!")
    endif()
else()
    message(WARNING "Using clang-tidy is only supported currently with builds specifically targeting clang.")
endif()
