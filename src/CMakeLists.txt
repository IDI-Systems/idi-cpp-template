#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2019 International Development & Integration Systems LLC
#

# Define a nice short hand for 3rd party external library folders
set(IDI_EXTERNAL_LIB_DIR "${CMAKE_CURRENT_LIST_DIR}/lib")

# Add 3rd party external cmake projects below here if needed.

# Catch is included by default as a submodule
add_subdirectory(lib/Catch2)

# Add the core.
add_subdirectory("app")