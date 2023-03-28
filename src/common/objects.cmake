#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2023 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#
# This is the list of all files that should be included in the core build.
# You _should_ include .h/.hpp files here so they properly show up in IDEs.

idi_add_sources(
    INTERNAL_CONFIGURE
    "${CMAKE_CURRENT_LIST_DIR}/version.cpp"
)

# This include brings in the explict cross-core includes. These are the APIs that
# should be used from component to component in the core library.
include("${CMAKE_CURRENT_LIST_DIR}/include/${IDI_PROJECT_NAME}/include.cmake")
