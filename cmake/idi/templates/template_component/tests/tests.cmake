#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2024 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

# This is the list of all tests that should be included as unit test builds.
idi_component_test(@__idi_new_component_name@ "${CMAKE_CURRENT_LIST_DIR}/test.cpp")
idi_component_test_public(@__idi_new_component_name@ "${CMAKE_CURRENT_LIST_DIR}/test_public.cpp")
