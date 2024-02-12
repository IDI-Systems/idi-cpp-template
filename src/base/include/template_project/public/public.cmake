#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2024 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#
# This is the list of all files that should be included in the core build.
# You _should_ include .h/.hpp files here so they properly show up in IDEs.
# They should be marked as INTERFACE so that other libraries consuming the core
# can access them.

# This is only used to in this component to configure files related to commmon.
# It is not needed in any other component.
idi_configure_common_includes()

idi_add_public_includes(
    "${CMAKE_CURRENT_LIST_DIR}/export.h"
    "${CMAKE_CURRENT_LIST_DIR}/version.h"
    "${CMAKE_CURRENT_LIST_DIR}/platform_config.h"
    "${CMAKE_CURRENT_LIST_DIR}/idi_version.h"
    INTERNAL_CONFIGURE
    "${CMAKE_CURRENT_LIST_DIR}/__idi_version.h"
    "${CMAKE_CURRENT_LIST_DIR}/__version.h"
    "${CMAKE_CURRENT_LIST_DIR}/__export.h"
    "${CMAKE_CURRENT_LIST_DIR}/__platform_config.h"
)


