cmake_minimum_required(VERSION 3.23 FATAL_ERROR)
#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2023 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#
set(IDI_ROOT_CML_V 2)
include(${CMAKE_CURRENT_LIST_DIR}/cmake/idi/idi-template.cmake)
if (NOT IDI_DID_UPDATE)
    idi_load_platform_config()
    project(${IDI_PROJECT_NAME} C CXX)
    idi_init()
endif()
