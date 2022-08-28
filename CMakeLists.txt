cmake_minimum_required(VERSION 3.23 FATAL_ERROR)
#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2022 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#
set(IDI_ROOT_CML_V 1)
include(${CMAKE_CURRENT_LIST_DIR}/cmake/idi/idi-template.cmake)
idi_load_platform_config()
project(${IDI_PROJECT_NAME} C CXX)
idi_init()
