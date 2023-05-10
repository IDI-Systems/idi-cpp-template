#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2022 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

macro(idi_init)
    include(CTest)

    idi_cmake_hook(pre-init)

    cmake_policy(SET CMP0079 NEW)
    cmake_policy(SET CMP0135 NEW)

    string(TOUPPER ${CMAKE_SOURCE_DIR} CMAKE_SOURCE_DIR_UPPER)
    string(TOUPPER ${CMAKE_CURRENT_LIST_DIR} PROJECT_SOURCE_DIR_UPPER)

    if(CMAKE_SOURCE_DIR_UPPER STREQUAL PROJECT_SOURCE_DIR_UPPER)
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

    if(NOT (TARGET "${IDI_PROJECT_NAME}_${__idi_version_full}"))

        if(IDI_IS_SUBDIRECTORY AND IDI_DECONFLICT_MULTIPLE)
            message(STATUS "DOING DECONFLICTION, LIBRARY INITIALIZATION DEFERRED")
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

        idi_cmake_hook(pre-options)

        # backwards compat with old configuration for naming
        set(IDI_IS_DYNAMIC ${IDI_IS_SHARED})
        string(TOUPPER ${IDI_PROJECT_NAME} IDI_PREFIX_UPPER)
        set(IDI_PREFIX ${IDI_PREFIX_UPPER})

        set("${IDI_PREFIX}_VERSION_MAJOR" ${IDI_PROJECT_VERSION_MAJOR})
        set("${IDI_PREFIX}_VERSION_MINOR" ${IDI_PROJECT_VERSION_MINOR})
        set("${IDI_PREFIX}_VERSION_PATCH" ${IDI_PROJECT_VERSION_PATCH})
        set("${IDI_PREFIX}_VERSION_FULL" "${IDI_PROJECT_VERSION_MAJOR}.${IDI_PROJECT_VERSION_MINOR}.${IDI_PROJECT_VERSION_PATCH}")

        if(IDI_IS_SUBDIRECTORY)
            set("${IDI_PREFIX}_BUILD_DEMOS" 0 CACHE BOOL "Build demo applications if applicable.")
            set("${IDI_PREFIX}_BUILD_TESTS" 0 CACHE BOOL "Build unit tests.")
        else()
            set("${IDI_PREFIX}_BUILD_DEMOS" 1 CACHE BOOL "Build demo applications if applicable.")
            set("${IDI_PREFIX}_BUILD_TESTS" 1 CACHE BOOL "Build unit tests.")
        endif()
        set("${IDI_PREFIX}_USE_GIT_VERSIONING" 1 CACHE BOOL "Check git for version information related to hashes and branches.")
        set("${IDI_PREFIX}_USE_BUILD_TIMESTAMPS" 0 CACHE BOOL "Set the current time for the build as build info. Disabled by default as it can increase build time during development.")
        set("${IDI_PREFIX}_DO_TEMPLATE_COMPONENT_TEST" 0 CACHE BOOL "Generate unit test template component and build unit tests for template.")
        set("${IDI_PREFIX}_FORCE_PIC" 0 CACHE BOOL "Force the use of Position Independent Code (PIC). This is useful if this library is a static library being included in a shared library.")
        set("${IDI_PREFIX}_CI_GIT_BRANCH_NAME" "" CACHE STRING "The branch name of the git repo. If not set it will be interogated from Git itself, but could result in a value of HEAD.")

        include(${PROJECT_SOURCE_DIR}/platform-compile-options.cmake)

        idi_cmake_hook(post-options)

        set("IDI_BUILD_DEMOS" "${${IDI_PREFIX}_BUILD_DEMOS}")
        set("IDI_BUILD_TESTS" "${${IDI_PREFIX}_BUILD_TESTS}")
        set("IDI_USE_GIT_VERSIONING" "${${IDI_PREFIX}_USE_GIT_VERSIONING}")
        set("IDI_USE_BUILD_TIMESTAMPS" "${${IDI_PREFIX}_USE_BUILD_TIMESTAMPS}")
        set("IDI_DO_TEMPLATE_COMPONENT_TEST" "${${IDI_PREFIX}_DO_TEMPLATE_COMPONENT_TEST}")
        set("IDI_CI_GIT_BRANCH_NAME" "${${IDI_PREFIX}_CI_GIT_BRANCH_NAME}")
        set("IDI_FORCE_PIC" "${${IDI_PREFIX}_FORCE_PIC}")

        if (IDI_APP_NAMESPACE)
            set(__idi_namespace "${IDI_VENDOR_NAMESPACE}::${IDI_APP_NAMESPACE}")
            set(__idi_app_namespace ${IDI_APP_NAMESPACE})
            set(__idi_c_namespace "${IDI_VENDOR_NAMESPACE}_${IDI_APP_NAMESPACE}")
        else()
            set(__idi_namespace ${IDI_VENDOR_NAMESPACE})
            set(__idi_app_namespace ${IDI_VENDOR_NAMESPACE})
            set(__idi_c_namespace ${IDI_VENDOR_NAMESPACE})
        endif()
        string(TOUPPER ${__idi_c_namespace} __idi_c_caps_namespace)
        set(__idi_project_name ${IDI_PROJECT_NAME})

        idi_platform_config("${__idi_c_caps_namespace}_PROJECT_NAME" RAW ${IDI_PROJECT_NAME})
        idi_platform_config("${__idi_c_caps_namespace}_PROJECT_NAME_STR" STRING ${IDI_PROJECT_NAME})
        idi_platform_config("${__idi_c_caps_namespace}_IS_LIBRARY" BOOL ${IDI_IS_LIBRARY})
        idi_platform_config("${__idi_c_caps_namespace}_IS_SHARED" BOOL ${IDI_IS_SHARED})
        idi_platform_config("${__idi_c_caps_namespace}_IS_DYNAMIC" BOOL ${IDI_IS_DYNAMIC})
        idi_platform_config("${__idi_c_caps_namespace}_VENDOR_NAMESPACE" RAW ${IDI_VENDOR_NAMESPACE})
        idi_platform_config("${__idi_c_caps_namespace}_APP_NAMESPACE" RAW ${IDI_APP_NAMESPACE})


        if(NOT IDI_IS_SUBDIRECTORY)
            set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
            set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
            set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
        endif()

        message(STATUS "[${IDI_PROJECT_NAME}] IDI CPP CMake Framework: v${IDI_CPP_FRAMEWORK_VERSION_MAJOR}.${IDI_CPP_FRAMEWORK_VERSION_MINOR}.${IDI_CPP_FRAMEWORK_VERSION_HOTFIX}")
        message(STATUS "[${IDI_PROJECT_NAME}] Load status IDI_IS_SUBDIRECTORY: ${IDI_IS_SUBDIRECTORY}")
        message(STATUS "[${IDI_PROJECT_NAME}] Config IDI_IS_LIBRARY: ${IDI_IS_LIBRARY}")
        message(STATUS "[${IDI_PROJECT_NAME}] Config IDI_IS_SHARED: ${IDI_IS_SHARED}")
        message(STATUS "[${IDI_PROJECT_NAME}] Compiler IDI_MSVC_PRIVATE_COMPILE_OPTIONS: ${IDI_MSVC_PRIVATE_COMPILE_OPTIONS}")
        message(STATUS "[${IDI_PROJECT_NAME}] Compiler IDI_MSVC_PRIVATE_COMPILE_DEFINITIONS: ${IDI_MSVC_PRIVATE_COMPILE_DEFINITIONS}")
        message(STATUS "[${IDI_PROJECT_NAME}] Compiler IDI_GNU_PRIVATE_COMPILE_OPTIONS: ${IDI_GNU_PRIVATE_COMPILE_OPTIONS}")
        message(STATUS "[${IDI_PROJECT_NAME}] Compiler IDI_PRIVATE_COMPILE_FEATURES: ${IDI_PRIVATE_COMPILE_FEATURES}")

        file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/reports)

        idi_new_component()

        # Define a nice short hand for 3rd party external library folders
        set(IDI_EXTERNAL_LIB_DIR "${CMAKE_CURRENT_LIST_DIR}/lib")

        # Add the main source folder.
        idi_cmake_hook(pre-source)
        add_subdirectory("src")
        idi_cmake_hook(post-source)

        # Catch is included by default as a submodule
        if(NOT TARGET Catch2)
            add_subdirectory(lib/Catch2)
        endif()

        if(IDI_BUILD_DEMOS)
            add_subdirectory("demo")
        endif()

        if(IDI_IS_SUBDIRECTORY AND IDI_DECONFLICT_MULTIPLE)
            configure_file("${CMAKE_CURRENT_LIST_DIR}/lib/libraries.cmake" "${CMAKE_BINARY_DIR}/${IDI_PROJECT_NAME}_${${IDI_PREFIX}_VERSION_FULL}_libraries.cmake")
        else()
            include("${CMAKE_CURRENT_LIST_DIR}/lib/libraries.cmake")
        endif()


        idi_cmake_hook(post-configure)

        if(NOT IDI_IS_SUBDIRECTORY)
            message(STATUS "Doing deferred library initializations... ${IDI_DEFERRED_LIB_LIST}")
            set(IDI_DO_DEFERRED true)
            foreach(var IN LISTS IDI_DEFERRED_LIB_LIST)
                message(STATUS "ADDING DEFERRED LIB: ${var} @ v${${var}_MAX_VERSION} located at: ${${var}_MAX_VERSION_PATH}")
                add_library("${var}" ALIAS "${var}_${${var}_MAX_VERSION}")
                include("${CMAKE_BINARY_DIR}/${var}_${${var}_MAX_VERSION}_libraries.cmake")
            endforeach()
        endif()
    endif()
endmacro()
