cmake_minimum_required(VERSION 3.14 FATAL_ERROR)
#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2021 International Development & Integration Systems LLC
#
cmake_policy(SET CMP0079 NEW)

# Basic configuration and pass through to src folder.
project(${IDI_PROJECT_NAME} C CXX)

set(IDI_PLATFORM_CONFIG "${CMAKE_CURRENT_LIST_DIR}/platform_config.cmake" CACHE FILEPATH "Platform configuration file.")
set(IDI_BUILD_DEMOS 0 CACHE BOOL "Build demo applications if applicable.")
set(IDI_BUILD_TESTS 1 CACHE BOOL "Build unit tests.")
set(IDI_USE_GIT_VERSIONING 1 CACHE BOOL "Check git for version information related to hashes and branches.")
set(IDI_USE_BUILD_TIMESTAMPS 0 CACHE BOOL "Set the current time for the build as build info. Disabled by default as it can increase build time during development.")
set(DO_TEMPLATE_COMPONENT_TEST 0 CACHE BOOL "Generate unit test template component and build unit tests for template.")
set(IDI_GIT_BRANCH_NAME "" CACHE STRING "The branch name of the git repo. If not set it will be interogated from Git itself, but could result in a value of HEAD.")

list(APPEND IDI_MSVC_PRIVATE_COMPILE_OPTIONS /W4 /WX /Zc:__cplusplus /MP /std:c++latest)
list(APPEND IDI_MSVC_PRIVATE_COMPILE_DEFINITIONS _CRT_SECURE_NO_WARNINGS)
list(APPEND IDI_GNU_PRIVATE_COMPILE_OPTIONS -Wall -Wextra -Wshadow -pedantic -Werror -fno-exceptions)
list(APPEND IDI_PRIVATE_COMPILE_FEATURES cxx_std_20)

include("${IDI_PLATFORM_CONFIG}")

set(__idi_vendor_namespace ${IDI_VENDOR_NAMESPACE})
set(__idi_app_namespace ${IDI_APP_NAMESPACE})

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/install CACHE PATH "Set the default installation path." FORCE)

# Set runtime library search path to relative and make it available without installing
set(CMAKE_INSTALL_RPATH $ORIGIN/${IDI_PROJECT_NAME})
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)

include(CTest)
include("${CMAKE_CURRENT_LIST_DIR}/cmake/component.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/cmake/new_component.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/cmake/code-coverage.cmake")


file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/reports)


# Define a nice short hand for 3rd party external library folders
set(IDI_EXTERNAL_LIB_DIR "${CMAKE_CURRENT_LIST_DIR}/lib")

# Add 3rd party external cmake projects below here if needed.

# Catch is included by default as a submodule
add_subdirectory(lib/Catch2)
include("${CMAKE_CURRENT_LIST_DIR}/lib/libraries.cmake")

# Add the main source folder.
add_subdirectory("src")

if(IDI_BUILD_DEMOS)
    add_subdirectory("demo")
endif()
