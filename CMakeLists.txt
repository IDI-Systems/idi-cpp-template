cmake_minimum_required(VERSION 3.12 FATAL_ERROR)
#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2019 International Development & Integration Systems LLC
#
cmake_policy(SET CMP0079 NEW)

set(IDI_PLATFORM_CONFIG "${CMAKE_CURRENT_LIST_DIR}/platform_config.cmake" CACHE FILEPATH "Platform configuration file.")
set(IDI_BUILD_DEMOS 0 CACHE BOOL "Build demo applications if applicable.")
set(IDI_BUILD_TESTS 1 CACHE BOOL "Build unit tests.")

set(DO_TEMPLATE_COMPONENT_TEST 0 CACHE BOOL "Generate unit test template component and build unit tests for template.")

include("${IDI_PLATFORM_CONFIG}")

set(__idi_vendor_namespace ${IDI_VENDOR_NAMESPACE})
set(__idi_app_namespace ${IDI_APP_NAMESPACE})



# Basic configuration and pass through to src folder.
project(${IDI_PROJECT_NAME} C CXX)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/install CACHE PATH "Set the default installation path." FORCE)


include(CTest)
include("${CMAKE_CURRENT_LIST_DIR}/cmake/component.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/cmake/new_component.cmake")

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/reports)


# Define a nice short hand for 3rd party external library folders
set(IDI_EXTERNAL_LIB_DIR "${CMAKE_CURRENT_LIST_DIR}/lib")

# Add 3rd party external cmake projects below here if needed.

# Catch is included by default as a submodule
add_subdirectory(lib/Catch2)
include("${CMAKE_CURRENT_LIST_DIR}/libraries.cmake")

# Add the main source folder.
add_subdirectory("src")

if(IDI_BUILD_DEMOS) 
    add_subdirectory("demo")
endif()

