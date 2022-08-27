cmake_minimum_required(VERSION 3.23 FATAL_ERROR)
#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2022 International Development & Integration Systems LLC
#

include(cmake/framework.cmake)

set(IDI_PLATFORM_CONFIG "${CMAKE_CURRENT_LIST_DIR}/platform_config.cmake")
include("${IDI_PLATFORM_CONFIG}")
project(${IDI_PROJECT_NAME} C CXX)

idi_init()

