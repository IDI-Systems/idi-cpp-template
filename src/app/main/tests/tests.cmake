#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2019 International Development & Integration Systems LLC
#

# This is the list of all files that should be included in the unit test build.
# You _should_ include .h/.hpp files here so they properly show up in IDEs.

idi_component_test_public(main "${CMAKE_CURRENT_LIST_DIR}/dll_test.cpp")

# if(IDI_IS_LIBRARY AND IDI_IS_DYNAMIC)
#     set(CURRENT_LIBRARY_TEST dll_test)
#     add_executable("${CURRENT_LIBRARY_TEST}" "")
#     target_compile_features("${CURRENT_LIBRARY_TEST}" PRIVATE cxx_std_17)

#     target_include_directories("${CURRENT_LIBRARY_TEST}" SYSTEM PRIVATE 
#         "${IDI_EXTERNAL_LIB_DIR}/Catch2/single_include")

#     target_link_libraries("${CURRENT_LIBRARY_TEST}" "${IDI_MAIN_TARGET}")

#     target_sources(
#         "${CURRENT_LIBRARY_TEST}"
#         PRIVATE
#         # EDIT LIST FILES BELOW HERE
#         "${CMAKE_CURRENT_LIST_DIR}/dll_test.cpp"
#     )

#     target_include_directories("${CURRENT_LIBRARY_TEST}" PRIVATE "${CMAKE_CURRENT_LIST_DIR}")

#     add_test(NAME "${CURRENT_LIBRARY_TEST}" COMMAND "${CURRENT_LIBRARY_TEST}" -o ${CMAKE_BINARY_DIR}/reports/${CURRENT_LIBRARY_TEST}_report.xml -r junit)
# endif()