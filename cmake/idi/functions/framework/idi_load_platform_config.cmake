#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2026 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

macro(idi_load_platform_config)
    idi_cmake_hook_abs(${CMAKE_CURRENT_LIST_DIR}/platform-options.cmake)
    idi_cmake_hook_abs(${CMAKE_CURRENT_LIST_DIR}/platform-local-options.cmake)
    idi_cmake_hook_abs(${CMAKE_CURRENT_LIST_DIR}/cmake-hooks/pre-configure.cmake)

    # set(CACHE FILEPATH) makes a relative -D value absolute against the directory cmake
    # was run from. If that file does not exist, retry the raw value against the build
    # dir, then the source dir, and stop before anything is generated if none exists.
    set(__idi_pc_raw "$CACHE{IDICMAKE_PLATFORM_CONFIG}")
    set(IDICMAKE_PLATFORM_CONFIG "${CMAKE_CURRENT_LIST_DIR}/platform-config.cmake" CACHE FILEPATH "Platform config definitions file")
    set(__idi_pc_file "${IDICMAKE_PLATFORM_CONFIG}")
    set(__idi_pc_tried "${__idi_pc_file}")
    if(NOT EXISTS "${__idi_pc_file}" AND NOT __idi_pc_raw STREQUAL "" AND NOT IS_ABSOLUTE "${__idi_pc_raw}")
        foreach(__idi_pc_base IN ITEMS "${CMAKE_CURRENT_BINARY_DIR}" "${CMAKE_CURRENT_LIST_DIR}")
            cmake_path(ABSOLUTE_PATH __idi_pc_raw BASE_DIRECTORY "${__idi_pc_base}" NORMALIZE
                OUTPUT_VARIABLE __idi_pc_candidate)
            list(APPEND __idi_pc_tried "${__idi_pc_candidate}")
            if(EXISTS "${__idi_pc_candidate}")
                set(__idi_pc_file "${__idi_pc_candidate}")
                break()
            endif()
        endforeach()
    endif()
    unset(IDICMAKE_PLATFORM_CONFIG CACHE) # prevent propagation to subprojects using this template
    if(NOT EXISTS "${__idi_pc_file}")
        list(REMOVE_DUPLICATES __idi_pc_tried)
        list(JOIN __idi_pc_tried "\n  " __idi_pc_tried)
        message(FATAL_ERROR "IDICMAKE_PLATFORM_CONFIG: platform config file not found. Tried:\n  ${__idi_pc_tried}")
    endif()
    include("${__idi_pc_file}")
    unset(__idi_pc_raw)
    unset(__idi_pc_file)
    unset(__idi_pc_tried)
    unset(__idi_pc_base)
    unset(__idi_pc_candidate)

    idi_cmake_hook_abs(${CMAKE_CURRENT_LIST_DIR}/cmake-hooks/post-platform-config.cmake)

endmacro()
