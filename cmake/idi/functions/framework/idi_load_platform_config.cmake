#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2022 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

macro(idi_load_platform_config)
    idi_cmake_hook_abs(${CMAKE_CURRENT_LIST_DIR}/cmake-hooks/pre-configure.cmake)

    set(IDI_PLATFORM_CONFIG "${CMAKE_CURRENT_LIST_DIR}/platform-config.cmake")
    include("${IDI_PLATFORM_CONFIG}")

    idi_cmake_hook_abs(${CMAKE_CURRENT_LIST_DIR}/cmake-hooks/post-platform-config.cmake)

    string(TOUPPER ${CMAKE_SOURCE_DIR} CMAKE_SOURCE_DIR_UPPER)
    string(TOUPPER ${CMAKE_CURRENT_LIST_DIR} PROJECT_SOURCE_DIR_UPPER)

    if(CMAKE_SOURCE_DIR_UPPER STREQUAL PROJECT_SOURCE_DIR_UPPER)
        set(IDI_DEFERRED_LIB_LIST "" CACHE INTERNAL "Deferred list")
        set(IDI_IS_SUBDIRECTORY false)
    else()
        message(STATUS "Project ${IDI_PROJECT_NAME} has been added as a subproject project via add_subdirectory, include paths will be relative to ${IDI_PROJECT_NAME}/")
        set(IDI_IS_SUBDIRECTORY true)
    endif()

    if(IDI_IS_SHARED AND (NOT IDI_IS_LIBRARY))
        message(FATAL_ERROR "IDI_IS_SHARED is set to TRUE but IDI_IS_LIBRARY is set to FALSE in platform configuration, please set IDI_IS_LIBRARY to true if you wish to build a shared library.")
    endif()

    include(${CMAKE_CURRENT_LIST_DIR}/version.cmake)
    set(__idi_version_major ${IDI_PROJECT_VERSION_MAJOR})
    set(__idi_version_minor ${IDI_PROJECT_VERSION_MINOR})
    set(__idi_version_patch ${IDI_PROJECT_VERSION_PATCH})
    set(__idi_version_full "${IDI_PROJECT_VERSION_MAJOR}.${IDI_PROJECT_VERSION_MINOR}.${IDI_PROJECT_VERSION_PATCH}")

    if(IDI_IS_SUBDIRECTORY AND IDI_DECONFLICT_MULTIPLE AND (NOT IDI_DO_DEFERRED))
        message(STATUS "DOING DECONFLICTION, LIBRARY INITIALIZATION DEFERRED")
        set(IDI_DO_DECONFLICT true)
        if(DEFINED "${IDI_PROJECT_NAME}_MAX_VERSION")
            message(STATUS "Comparing ${IDI_PROJECT_NAME} versions ${__idi_version_full} > ${${IDI_PROJECT_NAME}_MAX_VERSION}")
            if("${__idi_version_full}" VERSION_GREATER "${${IDI_PROJECT_NAME}_MAX_VERSION}")
                set("${IDI_PROJECT_NAME}_MAX_VERSION" "${__idi_version_full}" CACHE INTERNAL "${${IDI_PROJECT_NAME}_MAX_VERSION}")
                set("${IDI_PROJECT_NAME}_MAX_VERSION_PATH" "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL "${${IDI_PROJECT_NAME}_MAX_VERSION_PATH}")
            endif()
        else()
            message(STATUS "Setting ${IDI_PROJECT_NAME} base version ${__idi_version_full}")
            set(__local_list ${IDI_DEFERRED_LIB_LIST})
            list(APPEND __local_list ${IDI_PROJECT_NAME})
            set(IDI_DEFERRED_LIB_LIST ${__local_list} CACHE INTERNAL "Deferred list")
            set("${IDI_PROJECT_NAME}_MAX_VERSION" "${__idi_version_full}" CACHE INTERNAL "${${IDI_PROJECT_NAME}_MAX_VERSION}")
            set("${IDI_PROJECT_NAME}_MAX_VERSION_PATH" "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL "${${IDI_PROJECT_NAME}_MAX_VERSION_PATH}")
        endif()
    endif()
endmacro()
