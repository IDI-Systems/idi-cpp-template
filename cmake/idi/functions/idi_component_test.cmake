#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2022 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

function(__idi_component_test component_name test_file)
    set(__LIBRARY_LIST "${LIBRARY_LIST}")
    get_filename_component(TEST_FILE_WLE ${test_file} NAME_WLE)
    set(CURRENT_LIBRARY_TEST "${IDI_PROJECT_NAME}_${component_name}_${TEST_FILE_WLE}_${__idi_version_full}")

    add_executable("${CURRENT_LIBRARY_TEST}" ${test_file})
    idi_target_compile_settings("${CURRENT_LIBRARY_TEST}")

    target_include_directories("${CURRENT_LIBRARY_TEST}" SYSTEM PRIVATE
        "${IDI_EXTERNAL_LIB_DIR}/Catch2/single_include")

    set(ADD_MODE "ADDITIONAL_SOURCES")
    set(ADD_CORE true)

    foreach(var IN LISTS ARGN)
        if(var STREQUAL "ADDITIONAL_LIBRARIES")
            set(ADD_MODE "ADDITIONAL_LIBRARIES")
        elseif(var STREQUAL "EXTERNAL_LIBRARIES")
            set(ADD_MODE "EXTERNAL_LIBRARIES")
        elseif(var STREQUAL "ADDITIONAL_INCLUDES")
            set(ADD_MODE "ADDITIONAL_INCLUDES")
        elseif(var STREQUAL "ADDITIONAL_SOURCES")
            set(ADD_MODE "ADDITIONAL_SOURCES")
        elseif(var STREQUAL "EXCLUDE_CORE")
            set(ADD_CORE false)
        else()
            if(ADD_MODE STREQUAL "ADDITIONAL_LIBRARIES")
                target_link_libraries("${CURRENT_LIBRARY_TEST}" PUBLIC "${IDI_PROJECT_NAME}_${var}_${__idi_version_full}")
                list(APPEND __LIBRARY_LIST ${var})
            elseif(ADD_MODE STREQUAL "EXTERNAL_LIBRARIES")
                target_link_libraries("${CURRENT_LIBRARY_TEST}" PUBLIC ${var})
                list(APPEND __LIBRARY_LIST ${var})
            elseif(ADD_MODE STREQUAL "ADDITIONAL_SOURCES")
                target_sources("${CURRENT_LIBRARY_TEST}" PRIVATE ${var})
            elseif(ADD_MODE STREQUAL "ADDITIONAL_INCLUDES")
                target_include_directories("${CURRENT_LIBRARY_TEST}" SYSTEM PRIVATE
                    ${var})
            endif()
        endif()
    endforeach()

    if (ADD_CORE)
        target_link_libraries("${CURRENT_LIBRARY_TEST}" PUBLIC "${IDI_CORE}")
        list(APPEND __LIBRARY_LIST ${CURRENT_LIBRARY_TEST})
        list(APPEND __LIBRARY_LIST ${IDI_CORE})
    else()
        target_link_libraries("${CURRENT_LIBRARY_TEST}" PUBLIC "${CURRENT_LIBRARY_NAME}")
        list(APPEND __LIBRARY_LIST ${CURRENT_LIBRARY_TEST})
    endif()

    add_test(NAME "${CURRENT_LIBRARY_TEST}" COMMAND "${CURRENT_LIBRARY_TEST}" WORKING_DIRECTORY "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
    if (IDI_IS_SHARED)
        # setting target BUILD_WITH_INSTALL_RPATH to OFF for a shared library
        # will make sure that tests link against the build tree RPATH and not
        # the system install dir, this lets tests for the .so on linux.
        set_property(TARGET ${CURRENT_LIBRARY_TEST} PROPERTY BUILD_WITH_INSTALL_RPATH OFF)
    endif()
    target_code_coverage("${CURRENT_LIBRARY_TEST}" ALL OBJECTS "${__LIBRARY_LIST}" EXCLUDE tests/* lib/*)
    # message(WARNING "TEST LIBS: ${__LIBRARY_LIST}")
endfunction()

macro(idi_component_test component_name test_file)
    if(IDI_BUILD_TESTS AND (NOT IDI_IS_SHARED))
        __idi_component_test(${component_name} ${test_file} ${ARGN})
    endif()
endmacro()

macro(idi_component_test_public component_name test_file)
    if(IDI_BUILD_TESTS)
        __idi_component_test(${component_name} ${test_file} ${ARGN})
    endif()
endmacro()
