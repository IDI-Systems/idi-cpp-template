#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2019 International Development & Integration Systems LLC
#

###################################################################################
#         THIS FILE CAN BE REMOVED AND NOT INCLUDED IN ALL OTHER MODULES          #
###################################################################################

target_sources("${CURRENT_LIBRARY_NAME}" PUBLIC 
    "${CMAKE_CURRENT_LIST_DIR}/../../idi_version.h")

# The following two target includes are explicitly for the version.hpp file included
# in the root of the project.
target_include_directories("${CURRENT_LIBRARY_NAME}" PUBLIC 
    "${CMAKE_CURRENT_LIST_DIR}/../../")