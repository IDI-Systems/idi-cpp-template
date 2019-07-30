#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2019 International Development & Integration Systems LLC
#

macro(__idi_component_test component_name test_file)
    get_filename_component(TEST_FILE_WLE ${test_file} NAME_WLE)
    set(CURRENT_LIBRARY_TEST "${component_name}_${TEST_FILE_WLE}")

    add_executable("${CURRENT_LIBRARY_TEST}" ${test_file})
    target_compile_features("${CURRENT_LIBRARY_TEST}" PRIVATE cxx_std_17)

    target_include_directories("${CURRENT_LIBRARY_TEST}" SYSTEM PRIVATE 
        "${IDI_EXTERNAL_LIB_DIR}/Catch2/single_include")

    target_link_libraries("${CURRENT_LIBRARY_TEST}" "${IDI_CORE}")

    add_test(NAME "${CURRENT_LIBRARY_TEST}" COMMAND "${CURRENT_LIBRARY_TEST}" -o ${CMAKE_BINARY_DIR}/reports/${CURRENT_LIBRARY_TEST}_report.xml -r junit)
endmacro()

macro(idi_component_test component_name test_file)
    if(IDI_BUILD_TESTS AND (NOT IDI_IS_DYNAMIC))
        __idi_component_test(${idi_component_test} ${component_name} ${test_file})
    endif()
endmacro()

macro(idi_component_test_public component_name test_file)
    if(IDI_BUILD_TESTS)
        __idi_component_test(${idi_component_test} ${component_name} ${test_file})
    endif()
endmacro()

macro(idi_component_setup component_name)
    set(CURRENT_LIBRARY_NAME "${component_name}")
    add_library("${CURRENT_LIBRARY_NAME}" OBJECT "")
    target_link_libraries("${CURRENT_LIBRARY_NAME}" ${ARGN})
    target_compile_features("${CURRENT_LIBRARY_NAME}" PUBLIC cxx_std_17)

    include("${CMAKE_CURRENT_LIST_DIR}/objects.cmake")
    target_link_libraries("${IDI_CORE}"
        "${CURRENT_LIBRARY_NAME}"
    )
endmacro()

macro(idi_component component_name)
    idi_component_setup(${component_name} ${ARGN})
    include("${CMAKE_CURRENT_LIST_DIR}/tests/tests.cmake")
endmacro()

macro(idi_component_no_tests component_name)
    idi_component_setup(${component_name} ${ARGN})
endmacro()

macro(idi_add_sources)
    target_sources(
        "${CURRENT_LIBRARY_NAME}"
        PRIVATE
        # EDIT LIST FILES BELOW HERE
        ${ARGN}
    )

    target_include_directories("${CURRENT_LIBRARY_NAME}" PRIVATE "${CMAKE_CURRENT_LIST_DIR}")
endmacro()

macro(idi_add_includes)
    target_sources(
        "${CURRENT_LIBRARY_NAME}"
        PUBLIC
        # EDIT LIST FILES BELOW HERE
        ${ARGN}
    )
    if(IDI_IS_LIBRARY AND (NOT IDI_IS_DYNAMIC))
        set_target_properties("${CURRENT_LIBRARY_NAME}" PROPERTIES PUBLIC_HEADER "${ARGN}")
        install(TARGETS "${CURRENT_LIBRARY_NAME}"
                PUBLIC_HEADER DESTINATION ${CMAKE_BINARY_DIR}/install/includes/${IDI_MAIN_TARGET}
        )
    endif()
    target_include_directories("${CURRENT_LIBRARY_NAME}" PUBLIC "${CMAKE_CURRENT_LIST_DIR}")
    target_include_directories("${IDI_CORE}" PUBLIC "${CMAKE_CURRENT_LIST_DIR}")
endmacro()

macro(idi_add_public_includes)
    target_sources(
        "${CURRENT_LIBRARY_NAME}"
        INTERFACE
        # EDIT LIST FILES BELOW HERE
        ${ARGN}
    )
    if(IDI_IS_LIBRARY)
        set_target_properties("${CURRENT_LIBRARY_NAME}" PROPERTIES PUBLIC_HEADER "${ARGN}")
        install(TARGETS "${CURRENT_LIBRARY_NAME}"
                PUBLIC_HEADER DESTINATION ${CMAKE_BINARY_DIR}/install/includes/${IDI_MAIN_TARGET}
        )
    endif()

    target_include_directories("${CURRENT_LIBRARY_NAME}" PUBLIC "${CMAKE_CURRENT_LIST_DIR}")
    target_include_directories("${IDI_CORE}" PUBLIC "${CMAKE_CURRENT_LIST_DIR}")
    target_include_directories("${IDI_CORE}" INTERFACE "${CMAKE_CURRENT_LIST_DIR}")
endmacro()