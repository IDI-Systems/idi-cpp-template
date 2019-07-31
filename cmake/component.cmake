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
    set(INTERNAL_FILE_LIST "" CACHE INTERNAL "INTERNAL_FILE_LIST")
    include("${CMAKE_CURRENT_LIST_DIR}/objects.cmake")
    target_link_libraries("${IDI_CORE}"
        "${CURRENT_LIBRARY_NAME}"
    )
    message("TREE FILES: ${INTERNAL_FILE_LIST}")
    source_group(TREE ${CMAKE_CURRENT_LIST_DIR} 
        FILES ${INTERNAL_FILE_LIST})
endmacro()

macro(idi_component component_name)
    idi_component_setup(${component_name} ${ARGN})
    include("${CMAKE_CURRENT_LIST_DIR}/tests/tests.cmake")
endmacro()

macro(idi_component_no_tests component_name)
    idi_component_setup(${component_name} ${ARGN})
endmacro()

function(__process_source_files)
    set(__INTERNAL_FILE_LIST "${INTERNAL_FILE_LIST}")
    set(__FILE_LIST "${FILE_LIST}")
    set(ADD_MODE "INTERNAL")
    foreach(var IN LISTS ARGN)
        if(var STREQUAL "INTERNAL")
            set(ADD_MODE "INTERNAL")
        elseif(var STREQUAL "EXTERNAL")
            set(ADD_MODE "EXTERNAL")
        else()
            list(APPEND __FILE_LIST ${var})
            message("${CURRENT_LIBRARY_NAME} added ${var}")
            if(ADD_MODE STREQUAL "INTERNAL")
                list(APPEND __INTERNAL_FILE_LIST ${var})
            endif()
        endif()
    endforeach()
    target_sources("${CURRENT_LIBRARY_NAME}" PRIVATE "${__FILE_LIST}")
    set(INTERNAL_FILE_LIST "${__INTERNAL_FILE_LIST}" CACHE INTERNAL "INTERNAL_FILE_LIST")
    set(FILE_LIST "${__FILE_LIST}" PARENT_SCOPE)
endfunction()

macro(idi_add_sources)
    set(FILE_LIST "")
    __process_source_files(${ARGN})

    target_include_directories("${CURRENT_LIBRARY_NAME}" PRIVATE "${CMAKE_CURRENT_LIST_DIR}")
endmacro()

macro(idi_add_includes)
    set(FILE_LIST "")
    __process_source_files(${ARGN})

    if(IDI_IS_LIBRARY AND (NOT IDI_IS_DYNAMIC))
        set_target_properties("${CURRENT_LIBRARY_NAME}" PROPERTIES PUBLIC_HEADER "${FILE_LIST}")
        install(TARGETS "${CURRENT_LIBRARY_NAME}"
                PUBLIC_HEADER DESTINATION ${CMAKE_BINARY_DIR}/install/includes/${IDI_MAIN_TARGET}
        )
    endif()
    target_include_directories("${CURRENT_LIBRARY_NAME}" PUBLIC "${CMAKE_CURRENT_LIST_DIR}")
    target_include_directories("${IDI_CORE}" PUBLIC "${CMAKE_CURRENT_LIST_DIR}")
endmacro()

function(idi_add_public_includes)
    set(FILE_LIST "")
    __process_source_files(${ARGN})
    message("${CMAKE_CURRENT_LIST_DIR} --> ${INTERNAL_FILE_LIST}")
    if(IDI_IS_LIBRARY)
        set_target_properties("${CURRENT_LIBRARY_NAME}" PROPERTIES PUBLIC_HEADER "${FILE_LIST}")
        install(TARGETS "${CURRENT_LIBRARY_NAME}"
                PUBLIC_HEADER DESTINATION ${CMAKE_BINARY_DIR}/install/includes/${IDI_MAIN_TARGET}
        )
    endif()
    target_include_directories("${CURRENT_LIBRARY_NAME}" PUBLIC "${CMAKE_CURRENT_LIST_DIR}")
    target_include_directories("${IDI_CORE}" PUBLIC "${CMAKE_CURRENT_LIST_DIR}")
    target_include_directories("${IDI_CORE}" INTERFACE "${CMAKE_CURRENT_LIST_DIR}")
endfunction()