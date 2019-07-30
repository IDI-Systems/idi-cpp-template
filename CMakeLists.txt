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

include("${IDI_PLATFORM_CONFIG}")


# Basic configuration and pass through to src folder.
project(${IDI_PROJECT_NAME} C CXX)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/install CACHE PATH "Set the default installation path." FORCE)


include(CTest)
include("${CMAKE_CURRENT_LIST_DIR}/cmake/component.cmake")

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/reports)

add_subdirectory("src")

# Needs to be wrapped in a define for building the demos or not.
if(IDI_BUILD_DEMOS) 
    add_subdirectory("demo")
endif()