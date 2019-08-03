#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2019 International Development & Integration Systems LLC
#

# This is the list of all files that should be included in the core build.
# You _should_ include .h/.hpp files here so they properly show up in IDEs.
idi_add_includes(
    "${CMAKE_CURRENT_LIST_DIR}/app_version.h"
    INTERNAL_CONFIGURE
    "${CMAKE_CURRENT_LIST_DIR}/__app_version.h"
)

# This include pulls in public header files. These are files that are declared public
# and should expose the public API used when linking against the core as a dynamic 
# library.
include("${CMAKE_CURRENT_LIST_DIR}/public/public.cmake")