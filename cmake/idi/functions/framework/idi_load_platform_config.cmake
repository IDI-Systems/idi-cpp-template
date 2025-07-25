#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2025 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

macro(idi_load_platform_config)
    idi_cmake_hook_abs(${CMAKE_CURRENT_LIST_DIR}/platform-options.cmake)
    idi_cmake_hook_abs(${CMAKE_CURRENT_LIST_DIR}/platform-local-options.cmake)
    idi_cmake_hook_abs(${CMAKE_CURRENT_LIST_DIR}/cmake-hooks/pre-configure.cmake)

    set(IDICMAKE_PLATFORM_CONFIG "${CMAKE_CURRENT_LIST_DIR}/platform-config.cmake" CACHE FILEPATH "Platform config definitions file")
    include("${IDICMAKE_PLATFORM_CONFIG}")
    unset(IDICMAKE_PLATFORM_CONFIG CACHE) # prevent propagation to subprojects using this template

    idi_cmake_hook_abs(${CMAKE_CURRENT_LIST_DIR}/cmake-hooks/post-platform-config.cmake)

endmacro()
