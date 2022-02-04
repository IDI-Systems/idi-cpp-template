#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2021 International Development & Integration Systems LLC
#

function(idi_target_compile_settings)
    if (MSVC)
        target_compile_options("${ARGV0}" PRIVATE ${IDI_MSVC_PRIVATE_COMPILE_OPTIONS})
        target_compile_definitions("${ARGV0}" PRIVATE ${IDI_MSVC_PRIVATE_COMPILE_DEFINITIONS}) # Disable MSVC 'unsafe' function warnings
    else()
        target_compile_options("${ARGV0}" PRIVATE ${IDI_GNU_PRIVATE_COMPILE_OPTIONS})
    endif()
    target_compile_features("${ARGV0}" PRIVATE ${IDI_PRIVATE_COMPILE_FEATURES})
endfunction()

function(__idi_component_test component_name test_file)
    set(__LIBRARY_LIST "${LIBRARY_LIST}")
    get_filename_component(TEST_FILE_WLE ${test_file} NAME_WLE)
    set(CURRENT_LIBRARY_TEST "${component_name}_${TEST_FILE_WLE}")

    add_executable("${CURRENT_LIBRARY_TEST}" ${test_file})
    idi_target_compile_settings("${CURRENT_LIBRARY_TEST}")

    target_include_directories("${CURRENT_LIBRARY_TEST}" SYSTEM PRIVATE
        "${IDI_EXTERNAL_LIB_DIR}/Catch2/single_include")

    target_link_libraries("${CURRENT_LIBRARY_TEST}" "${IDI_CORE}")
    list(APPEND __LIBRARY_LIST ${CURRENT_LIBRARY_TEST})
    list(APPEND __LIBRARY_LIST ${IDI_CORE})


    set(ADD_MODE "ADDITIONAL_SOURCES")
    foreach(var IN LISTS ARGN)
        if(var STREQUAL "ADDITIONAL_LIBRARIES")
            set(ADD_MODE "ADDITIONAL_LIBRARIES")
        elseif(var STREQUAL "ADDITIONAL_INCLUDES")
            set(ADD_MODE "ADDITIONAL_INCLUDES")
        elseif(var STREQUAL "ADDITIONAL_SOURCES")
            set(ADD_MODE "ADDITIONAL_SOURCES")
        else()
            if(ADD_MODE STREQUAL "ADDITIONAL_LIBRARIES")
                target_link_libraries("${CURRENT_LIBRARY_TEST}" ${var})
                list(APPEND __LIBRARY_LIST ${var})
            elseif(ADD_MODE STREQUAL "ADDITIONAL_SOURCES")
                target_sources("${CURRENT_LIBRARY_TEST}" PRIVATE ${var})
            elseif(ADD_MODE STREQUAL "ADDITIONAL_INCLUDES")
                target_include_directories("${CURRENT_LIBRARY_TEST}" SYSTEM PRIVATE
                    ${var})
            endif()
        endif()
    endforeach()

    add_test(NAME "${CURRENT_LIBRARY_TEST}" COMMAND "${CURRENT_LIBRARY_TEST}")
    target_code_coverage("${CURRENT_LIBRARY_TEST}" ALL OBJECTS "${__LIBRARY_LIST}" EXCLUDE tests/* lib/*)
    # message(WARNING "TEST LIBS: ${__LIBRARY_LIST}")
endfunction()

macro(idi_component_test component_name test_file)
    if(IDI_BUILD_TESTS AND (NOT IDI_IS_DYNAMIC))
        __idi_component_test(${idi_component_test} ${component_name} ${test_file} ${ARGN})
    endif()
endmacro()

macro(idi_component_test_public component_name test_file)
    if(IDI_BUILD_TESTS)
        __idi_component_test(${idi_component_test} ${component_name} ${test_file} ${ARGN})
    endif()
endmacro()

function(idi_component_setup component_name)
    set(__LIBRARY_LIST "")
    set(CURRENT_LIBRARY_NAME "${component_name}")
    add_library("${CURRENT_LIBRARY_NAME}" OBJECT "")
    idi_target_compile_settings("${CURRENT_LIBRARY_NAME}")
    set(ADD_MODE "ADDITIONAL_LIBRARIES")
    foreach(var IN LISTS ARGN)
        if(var STREQUAL "ADDITIONAL_LIBRARIES")
            set(ADD_MODE "ADDITIONAL_LIBRARIES")
        elseif(var STREQUAL "ADDITIONAL_INCLUDES")
            set(ADD_MODE "ADDITIONAL_INCLUDES")
        elseif(var STREQUAL "ADDITIONAL_SOURCES")
            set(ADD_MODE "ADDITIONAL_SOURCES")
        else()
            if(ADD_MODE STREQUAL "ADDITIONAL_LIBRARIES")
                target_link_libraries("${CURRENT_LIBRARY_NAME}" ${var})
                list(APPEND __LIBRARY_LIST ${var})
            elseif(ADD_MODE STREQUAL "ADDITIONAL_SOURCES")
                target_sources("${CURRENT_LIBRARY_NAME}" PRIVATE ${var})
            elseif(ADD_MODE STREQUAL "ADDITIONAL_INCLUDES")
                target_include_directories("${CURRENT_LIBRARY_NAME}" SYSTEM PRIVATE
                    ${var})
            endif()
        endif()
    endforeach()


    set(INTERNAL_FILE_LIST "" CACHE INTERNAL "INTERNAL_FILE_LIST")
    include("${CMAKE_CURRENT_LIST_DIR}/objects.cmake")
    target_link_libraries("${IDI_CORE}"
        "${CURRENT_LIBRARY_NAME}"
    )
    if(IDI_IS_DYNAMIC)
        set_target_properties("${CURRENT_LIBRARY_NAME}" PROPERTIES CXX_VISIBILITY_PRESET hidden)
        set_target_properties("${CURRENT_LIBRARY_NAME}" PROPERTIES C_VISIBILITY_PRESET hidden)
    endif()
    source_group(TREE ${CMAKE_CURRENT_LIST_DIR}
        FILES ${INTERNAL_FILE_LIST})

    target_code_coverage("${CURRENT_LIBRARY_NAME}" ALL OBJECTS "${__LIBRARY_LIST}")
    # message(WARNING "LIBS: ${__LIBRARY_LIST}")
endfunction()

macro(idi_component component_name)
    idi_component_setup(${component_name} ${ARGN})
    include("${CMAKE_CURRENT_LIST_DIR}/tests/tests.cmake")
endmacro()

macro(idi_component_no_tests component_name)
    idi_component_setup(${component_name} ${ARGN})
endmacro()

function(idi_configure_file return_configured_name file_name)
    get_filename_component(SOURCE_FILE_DIR ${file_name} DIRECTORY)
    get_filename_component(SOURCE_FILE_WLE ${file_name} NAME_WLE)
    get_filename_component(SOURCE_FILE_EXT ${file_name} LAST_EXT)
    set(configured_name "${SOURCE_FILE_DIR}/${SOURCE_FILE_WLE}.out${SOURCE_FILE_EXT}")
    set(${return_configured_name} ${configured_name} PARENT_SCOPE)
    configure_file(${file_name} ${configured_name})
endfunction()

function(__process_source_files)
    set(__INTERNAL_FILE_LIST "${INTERNAL_FILE_LIST}")
    set(__FILE_LIST "${FILE_LIST}")
    set(ADD_MODE "INTERNAL")
    foreach(var IN LISTS ARGN)
        if(var STREQUAL "INTERNAL")
            set(ADD_MODE "INTERNAL")
        elseif(var STREQUAL "EXTERNAL")
            set(ADD_MODE "EXTERNAL")
        elseif(var STREQUAL "INTERNAL_CONFIGURE")
            set(ADD_MODE "INTERNAL_CONFIGURE")
        elseif(var STREQUAL "EXTERNAL_CONFIGURE")
            set(ADD_MODE "EXTERNAL_CONFIGURE")
        else()

            if(ADD_MODE STREQUAL "INTERNAL" OR ADD_MODE STREQUAL "INTERNAL_CONFIGURE")
                list(APPEND __INTERNAL_FILE_LIST ${var})
            endif()

            target_sources("${CURRENT_LIBRARY_NAME}" PRIVATE ${var})

            if((ADD_MODE STREQUAL "INTERNAL_CONFIGURE") OR (ADD_MODE STREQUAL "EXTERNAL_CONFIGURE"))
                idi_configure_file(CONFIGURED_FILENAME ${var})
                target_sources("${CURRENT_LIBRARY_NAME}" PRIVATE ${CONFIGURED_FILENAME})
                if(ADD_MODE STREQUAL "INTERNAL_CONFIGURE")
                    list(APPEND __INTERNAL_FILE_LIST CONFIGURED_FILENAME)
                    list(APPEND __FILE_LIST ${CONFIGURED_FILENAME})
                endif()
                set_source_files_properties(${var} PROPERTIES HEADER_FILE_ONLY TRUE)
            else()
                list(APPEND __FILE_LIST ${var})
            endif()

        endif()
    endforeach()

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
