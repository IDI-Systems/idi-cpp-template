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
        set(IDICMAKE_IS_SUBDIRECTORY false)
    else()
        message(STATUS "Project ${IDICMAKE_PROJECT_NAME} has been added as a subproject project via add_subdirectory, include paths will be relative to ${IDICMAKE_PROJECT_NAME}/")
        set(IDICMAKE_IS_SUBDIRECTORY true)
    endif()

    if(IDICMAKE_IS_SHARED AND (NOT IDICMAKE_IS_LIBRARY))
        message(FATAL_ERROR "IDICMAKE_IS_SHARED is set to TRUE but IDICMAKE_IS_LIBRARY is set to FALSE in platform configuration, please set IDICMAKE_IS_LIBRARY to true if you wish to build a shared library.")
    endif()

    include(${CMAKE_CURRENT_LIST_DIR}/version.cmake)
    if(DEFINED IDI_PROJECT_VERSION_MAJOR)
        message(FATAL_ERROR "You may be using a version of the framework prior to version 4 and you have not updated all required files! Please make sure all cmake related files use the new cmake variable prefix IDICMAKE and not IDI")
    endif()
    set(__idi_version_major ${IDICMAKE_PROJECT_VERSION_MAJOR})
    set(__idi_version_minor ${IDICMAKE_PROJECT_VERSION_MINOR})
    set(__idi_version_patch ${IDICMAKE_PROJECT_VERSION_PATCH})
    set(__idi_version_full "${IDICMAKE_PROJECT_VERSION_MAJOR}.${IDICMAKE_PROJECT_VERSION_MINOR}.${IDICMAKE_PROJECT_VERSION_PATCH}")

    if(NOT (TARGET "${IDICMAKE_PROJECT_NAME}_${__idi_version_full}"))

        if(IDICMAKE_IS_SUBDIRECTORY AND IDICMAKE_DECONFLICT_MULTIPLE)
            message(STATUS "DOING DECONFLICTION, LIBRARY INITIALIZATION DEFERRED")
            if(DEFINED "${IDICMAKE_PROJECT_NAME}_MAX_VERSION")
                message(STATUS "Comparing ${IDICMAKE_PROJECT_NAME} versions ${__idi_version_full} > ${${IDICMAKE_PROJECT_NAME}_MAX_VERSION}")
                if("${__idi_version_full}" VERSION_GREATER "${${IDICMAKE_PROJECT_NAME}_MAX_VERSION}")
                    set("${IDICMAKE_PROJECT_NAME}_MAX_VERSION" "${__idi_version_full}" CACHE INTERNAL "${${IDICMAKE_PROJECT_NAME}_MAX_VERSION}")
                    set("${IDICMAKE_PROJECT_NAME}_MAX_VERSION_PATH" "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL "${${IDICMAKE_PROJECT_NAME}_MAX_VERSION_PATH}")
                endif()
            else()
                message(STATUS "Setting ${IDICMAKE_PROJECT_NAME} base version ${__idi_version_full}")
                set(__local_list ${IDICMAKE_DEFERRED_LIB_LIST})
                list(APPEND __local_list ${IDICMAKE_PROJECT_NAME})
                set(IDICMAKE_DEFERRED_LIB_LIST ${__local_list} CACHE INTERNAL "Deferred list")
                set("${IDICMAKE_PROJECT_NAME}_MAX_VERSION" "${__idi_version_full}" CACHE INTERNAL "${${IDICMAKE_PROJECT_NAME}_MAX_VERSION}")
                set("${IDICMAKE_PROJECT_NAME}_MAX_VERSION_PATH" "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL "${${IDICMAKE_PROJECT_NAME}_MAX_VERSION_PATH}")
            endif()
        endif()

        idi_cmake_hook(pre-options)

        # backwards compat with old configuration for naming
        set(IDICMAKE_IS_DYNAMIC ${IDICMAKE_IS_SHARED})
        string(TOUPPER ${IDICMAKE_PROJECT_NAME} IDICMAKE_PREFIX_UPPER)
        set(IDICMAKE_PREFIX ${IDICMAKE_PREFIX_UPPER})

        if(IDICMAKE_PREFIX STREQUAL "IDICMAKE")
            message(FATAL_ERROR "The value of IDICMAKE_PREFIX is IDICMAKE and that is reserved! The project name cannot be 'idicmake' or 'IDICMAKE'!")
        endif()

        set("${IDICMAKE_PREFIX}_VERSION_MAJOR" ${IDICMAKE_PROJECT_VERSION_MAJOR})
        set("${IDICMAKE_PREFIX}_VERSION_MINOR" ${IDICMAKE_PROJECT_VERSION_MINOR})
        set("${IDICMAKE_PREFIX}_VERSION_PATCH" ${IDICMAKE_PROJECT_VERSION_PATCH})
        set("${IDICMAKE_PREFIX}_VERSION_FULL" "${IDICMAKE_PROJECT_VERSION_MAJOR}.${IDICMAKE_PROJECT_VERSION_MINOR}.${IDICMAKE_PROJECT_VERSION_PATCH}")

        if(IDICMAKE_IS_SUBDIRECTORY)
            set("${IDICMAKE_PREFIX}_BUILD_DEMOS" 0 CACHE BOOL "Build demo applications if applicable.")
            set("${IDICMAKE_PREFIX}_BUILD_TESTS" 0 CACHE BOOL "Build unit tests.")
        else()
            set("${IDICMAKE_PREFIX}_BUILD_DEMOS" 1 CACHE BOOL "Build demo applications if applicable.")
            set("${IDICMAKE_PREFIX}_BUILD_TESTS" 1 CACHE BOOL "Build unit tests.")
        endif()
        set("${IDICMAKE_PREFIX}_USE_GIT_VERSIONING" 1 CACHE BOOL "Check git for version information related to hashes and branches.")
        set("${IDICMAKE_PREFIX}_USE_BUILD_TIMESTAMPS" 0 CACHE BOOL "Set the current time for the build as build info. Disabled by default as it can increase build time during development.")
        set("${IDICMAKE_PREFIX}_DO_TEMPLATE_COMPONENT_TEST" 0 CACHE BOOL "Generate unit test template component and build unit tests for template.")
        set("${IDICMAKE_PREFIX}_FORCE_PIC" 0 CACHE BOOL "Force the use of Position Independent Code (PIC). This is useful if this library is a static library being included in a shared library.")
        set("${IDICMAKE_PREFIX}_CI_GIT_BRANCH_NAME" "" CACHE STRING "The branch name of the git repo. If not set it will be interogated from Git itself, but could result in a value of HEAD.")

        include(${PROJECT_SOURCE_DIR}/platform-compile-options.cmake)

        idi_cmake_hook(post-options)

        set("IDICMAKE_BUILD_DEMOS" "${${IDICMAKE_PREFIX}_BUILD_DEMOS}")
        set("IDICMAKE_BUILD_TESTS" "${${IDICMAKE_PREFIX}_BUILD_TESTS}")
        set("IDICMAKE_USE_GIT_VERSIONING" "${${IDICMAKE_PREFIX}_USE_GIT_VERSIONING}")
        set("IDICMAKE_USE_BUILD_TIMESTAMPS" "${${IDICMAKE_PREFIX}_USE_BUILD_TIMESTAMPS}")
        set("IDICMAKE_DO_TEMPLATE_COMPONENT_TEST" "${${IDICMAKE_PREFIX}_DO_TEMPLATE_COMPONENT_TEST}")
        set("IDICMAKE_CI_GIT_BRANCH_NAME" "${${IDICMAKE_PREFIX}_CI_GIT_BRANCH_NAME}")
        set("IDICMAKE_FORCE_PIC" "${${IDICMAKE_PREFIX}_FORCE_PIC}")

        if (IDICMAKE_APP_NAMESPACE)
            set(__idi_namespace "${IDICMAKE_VENDOR_NAMESPACE}::${IDICMAKE_APP_NAMESPACE}")
            set(__idi_app_namespace ${IDICMAKE_APP_NAMESPACE})
            set(__idi_c_namespace "${IDICMAKE_VENDOR_NAMESPACE}_${IDICMAKE_APP_NAMESPACE}")
        else()
            set(__idi_namespace ${IDICMAKE_VENDOR_NAMESPACE})
            set(__idi_app_namespace ${IDICMAKE_VENDOR_NAMESPACE})
            set(__idi_c_namespace ${IDICMAKE_VENDOR_NAMESPACE})
        endif()
        string(TOUPPER ${__idi_c_namespace} __idi_c_caps_namespace)
        set(__idi_project_name ${IDICMAKE_PROJECT_NAME})

        idi_platform_config("${__idi_c_caps_namespace}_PROJECT_NAME" RAW ${IDICMAKE_PROJECT_NAME})
        idi_platform_config("${__idi_c_caps_namespace}_PROJECT_NAME_STR" STRING ${IDICMAKE_PROJECT_NAME})
        idi_platform_config("${__idi_c_caps_namespace}_IS_LIBRARY" BOOL ${IDICMAKE_IS_LIBRARY})
        idi_platform_config("${__idi_c_caps_namespace}_IS_SHARED" BOOL ${IDICMAKE_IS_SHARED})
        idi_platform_config("${__idi_c_caps_namespace}_IS_DYNAMIC" BOOL ${IDICMAKE_IS_DYNAMIC})
        idi_platform_config("${__idi_c_caps_namespace}_VENDOR_NAMESPACE" RAW ${IDICMAKE_VENDOR_NAMESPACE})
        idi_platform_config("${__idi_c_caps_namespace}_APP_NAMESPACE" RAW ${IDICMAKE_APP_NAMESPACE})


        if(NOT IDICMAKE_IS_SUBDIRECTORY)
            set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
            set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
            set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
        endif()

        message(STATUS "[${IDICMAKE_PROJECT_NAME}] IDI CPP CMake Framework: v${IDICMAKE_CPP_FRAMEWORK_VERSION_MAJOR}.${IDICMAKE_CPP_FRAMEWORK_VERSION_MINOR}.${IDICMAKE_CPP_FRAMEWORK_VERSION_HOTFIX}")
        message(STATUS "[${IDICMAKE_PROJECT_NAME}] Load status IDICMAKE_IS_SUBDIRECTORY: ${IDICMAKE_IS_SUBDIRECTORY}")
        message(STATUS "[${IDICMAKE_PROJECT_NAME}] Config IDICMAKE_IS_LIBRARY: ${IDICMAKE_IS_LIBRARY}")
        message(STATUS "[${IDICMAKE_PROJECT_NAME}] Config IDICMAKE_IS_SHARED: ${IDICMAKE_IS_SHARED}")
        message(STATUS "[${IDICMAKE_PROJECT_NAME}] Compiler IDICMAKE_MSVC_PRIVATE_COMPILE_OPTIONS: ${IDICMAKE_MSVC_PRIVATE_COMPILE_OPTIONS}")
        message(STATUS "[${IDICMAKE_PROJECT_NAME}] Compiler IDICMAKE_MSVC_PRIVATE_COMPILE_DEFINITIONS: ${IDICMAKE_MSVC_PRIVATE_COMPILE_DEFINITIONS}")
        message(STATUS "[${IDICMAKE_PROJECT_NAME}] Compiler IDICMAKE_GNU_PRIVATE_COMPILE_OPTIONS: ${IDICMAKE_GNU_PRIVATE_COMPILE_OPTIONS}")
        message(STATUS "[${IDICMAKE_PROJECT_NAME}] Compiler IDICMAKE_PRIVATE_COMPILE_FEATURES: ${IDICMAKE_PRIVATE_COMPILE_FEATURES}")

        file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/reports)

        idi_new_component()

        # Define a nice short hand for 3rd party external library folders
        set(IDICMAKE_EXTERNAL_LIB_DIR "${CMAKE_CURRENT_LIST_DIR}/lib")

        # Add the main source folder.
        idi_cmake_hook(pre-source)
        add_subdirectory("src")
        idi_cmake_hook(post-source)

        # Catch is included by default as a submodule
        if(NOT TARGET Catch2)
            add_subdirectory(lib/Catch2)
        endif()

        if(IDICMAKE_BUILD_DEMOS)
            add_subdirectory("demo")
        endif()

        if(IDICMAKE_IS_SUBDIRECTORY AND IDICMAKE_DECONFLICT_MULTIPLE)
            configure_file("${CMAKE_CURRENT_LIST_DIR}/lib/libraries.cmake" "${CMAKE_BINARY_DIR}/${IDICMAKE_PROJECT_NAME}_${${IDICMAKE_PREFIX}_VERSION_FULL}_libraries.cmake")
        else()
            include("${CMAKE_CURRENT_LIST_DIR}/lib/libraries.cmake")
        endif()


        idi_cmake_hook(post-configure)

        if(NOT IDICMAKE_IS_SUBDIRECTORY)
            message(STATUS "Doing deferred library initializations... ${IDICMAKE_DEFERRED_LIB_LIST}")
            set(IDICMAKE_DO_DEFERRED true)
            foreach(var IN LISTS IDICMAKE_DEFERRED_LIB_LIST)
                message(STATUS "ADDING DEFERRED LIB: ${var} @ v${${var}_MAX_VERSION} located at: ${${var}_MAX_VERSION_PATH}")
                add_library("${var}" ALIAS "${var}_${${var}_MAX_VERSION}")
                include("${CMAKE_BINARY_DIR}/${var}_${${var}_MAX_VERSION}_libraries.cmake")
            endforeach()
        endif()
    endif()
endmacro()
