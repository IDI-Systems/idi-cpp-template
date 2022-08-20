cmake_minimum_required(VERSION 3.23 FATAL_ERROR)
#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2022 International Development & Integration Systems LLC
#
cmake_policy(SET CMP0079 NEW)

# Basic configuration and pass through to src folder.


set(IDI_PLATFORM_CONFIG "${CMAKE_CURRENT_LIST_DIR}/platform_config.cmake" CACHE FILEPATH "Platform configuration file.")

include("${IDI_PLATFORM_CONFIG}")

project(${IDI_PROJECT_NAME} C CXX)

if(IDI_IS_SHARED AND (NOT IDI_IS_LIBRARY))
    message(FATAL_ERROR "IDI_IS_SHARED is set to TRUE but IDI_IS_LIBRARY is set to FALSE in platform configuration, please set IDI_IS_LIBRARY to true if you wish to build a shared library.")
endif()

# backwards compat with old configuration for naming
set(IDI_IS_DYNAMIC ${IDI_IS_SHARED})

string(TOUPPER ${IDI_PROJECT_NAME} IDI_PREFIX_UPPER)

set(IDI_PREFIX ${IDI_PREFIX_UPPER})

set("${IDI_PREFIX}_BUILD_DEMOS" 1 CACHE BOOL "Build demo applications if applicable.")
set("${IDI_PREFIX}_BUILD_TESTS" 1 CACHE BOOL "Build unit tests.")
set("${IDI_PREFIX}_USE_GIT_VERSIONING" 1 CACHE BOOL "Check git for version information related to hashes and branches.")
set("${IDI_PREFIX}_USE_BUILD_TIMESTAMPS" 0 CACHE BOOL "Set the current time for the build as build info. Disabled by default as it can increase build time during development.")
set("${IDI_PREFIX}_DO_TEMPLATE_COMPONENT_TEST" 0 CACHE BOOL "Generate unit test template component and build unit tests for template.")
set("${IDI_PREFIX}_FORCE_PIC" 0 CACHE BOOL "Force the use of Position Independent Code (PIC). This is useful if this library is a static library being included in a shared library.")
set("${IDI_PREFIX}_CI_GIT_BRANCH_NAME" "" CACHE STRING "The branch name of the git repo. If not set it will be interogated from Git itself, but could result in a value of HEAD.")

set("IDI_BUILD_DEMOS" "${${IDI_PREFIX}_BUILD_DEMOS}")
set("IDI_BUILD_TESTS" "${${IDI_PREFIX}_BUILD_TESTS}")
set("IDI_USE_GIT_VERSIONING" "${${IDI_PREFIX}_USE_GIT_VERSIONING}")
set("IDI_USE_BUILD_TIMESTAMPS" "${${IDI_PREFIX}_USE_BUILD_TIMESTAMPS}")
set("IDI_DO_TEMPLATE_COMPONENT_TEST" "${${IDI_PREFIX}_DO_TEMPLATE_COMPONENT_TEST}")
set("IDI_CI_GIT_BRANCH_NAME" "${${IDI_PREFIX}_CI_GIT_BRANCH_NAME}")
set("IDI_FORCE_PIC" "${${IDI_PREFIX}_FORCE_PIC}")

set(__idi_vendor_namespace ${IDI_VENDOR_NAMESPACE})
set(__idi_app_namespace ${IDI_APP_NAMESPACE})
set(__idi_project_name ${IDI_PROJECT_NAME})

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

message("[${IDI_PROJECT_NAME}] Config IDI_IS_LIBRARY: ${IDI_IS_LIBRARY}")
message("[${IDI_PROJECT_NAME}] Config IDI_IS_SHARED: ${IDI_IS_SHARED}")
message("[${IDI_PROJECT_NAME}] Compiler IDI_MSVC_PRIVATE_COMPILE_OPTIONS: ${IDI_MSVC_PRIVATE_COMPILE_OPTIONS}")
message("[${IDI_PROJECT_NAME}] Compiler IDI_MSVC_PRIVATE_COMPILE_DEFINITIONS: ${IDI_MSVC_PRIVATE_COMPILE_DEFINITIONS}")
message("[${IDI_PROJECT_NAME}] Compiler IDI_GNU_PRIVATE_COMPILE_OPTIONS: ${IDI_GNU_PRIVATE_COMPILE_OPTIONS}")
message("[${IDI_PROJECT_NAME}] Compiler IDI_PRIVATE_COMPILE_FEATURES: ${IDI_PRIVATE_COMPILE_FEATURES}")

include(CTest)
include("${CMAKE_CURRENT_LIST_DIR}/cmake/component.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/cmake/new_component.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/cmake/code-coverage.cmake")

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/reports)

# Define a nice short hand for 3rd party external library folders
set(IDI_EXTERNAL_LIB_DIR "${CMAKE_CURRENT_LIST_DIR}/lib")

# Add 3rd party external cmake projects below here if needed.

# Add the main source folder.
add_subdirectory("src")

# Catch is included by default as a submodule
if(NOT TARGET Catch2)
    add_subdirectory(lib/Catch2)
endif()

if(IDI_BUILD_DEMOS)
    add_subdirectory("demo")
endif()

include("${CMAKE_CURRENT_LIST_DIR}/lib/libraries.cmake")

