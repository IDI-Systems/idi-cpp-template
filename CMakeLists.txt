cmake_minimum_required(VERSION 3.23 FATAL_ERROR)
#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2022 International Development & Integration Systems LLC
#

include(cmake/framework.cmake)

idi_cmake_hook_abs(${CMAKE_CURRENT_LIST_DIR}/cmake-hooks/pre-configure.cmake)

set(IDI_PLATFORM_CONFIG "${CMAKE_CURRENT_LIST_DIR}/platform-config.cmake")
include("${IDI_PLATFORM_CONFIG}")

idi_cmake_hook_abs(${CMAKE_CURRENT_LIST_DIR}/cmake-hooks/post-platform-config.cmake)

project(${IDI_PROJECT_NAME} C CXX)

idi_init()

idi_cmake_hook(post-configure)
