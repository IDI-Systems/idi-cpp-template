#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2023 International Development & Integration Systems LLC
#
# This is the list of all files that should be included in the core build.
# You _should_ include .h/.hpp files here so they properly show up in IDEs.

idi_add_public_includes(
    "${CMAKE_CURRENT_LIST_DIR}/@__idi_new_component_name@_public.h"
)
