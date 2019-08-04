#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2019 International Development & Integration Systems LLC
#

# This is the list of all tests that should be included as unit test builds.
idi_component_test(unit_test_component "${CMAKE_CURRENT_LIST_DIR}/test.cpp")
idi_component_test_public(unit_test_component "${CMAKE_CURRENT_LIST_DIR}/test_public.cpp")
