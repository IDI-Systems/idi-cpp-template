#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2025 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#
# This is the list of all files that should be included in the core build.
# You _should_ include .h/.hpp files here so they properly show up in IDEs.
idi_add_includes(
    "${CMAKE_CURRENT_LIST_DIR}/version.hpp"
    INTERNAL_CONFIGURE
    "${CMAKE_CURRENT_LIST_DIR}/__version.hpp"
)

# This include pulls in public header files. These are files that are declared public
# and should expose the public API used when linking against the core as a shared
# library.
include("${CMAKE_CURRENT_LIST_DIR}/public/public.cmake")
