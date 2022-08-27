#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2022 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

function(idi_target_compile_settings compile_target)
    idi_cmake_hook(pre-target-compile-options)
    if (MSVC)
        target_compile_options("${compile_target}" PRIVATE ${IDI_MSVC_PRIVATE_COMPILE_OPTIONS})
        target_compile_definitions("${compile_target}" PRIVATE ${IDI_MSVC_PRIVATE_COMPILE_DEFINITIONS})
    else()
        target_compile_options("${compile_target}" PRIVATE ${IDI_GNU_PRIVATE_COMPILE_OPTIONS})
    endif()
    target_compile_features("${compile_target}" PRIVATE ${IDI_PRIVATE_COMPILE_FEATURES})
    idi_cmake_hook(post-target-compile-options)
endfunction()

function(__idi_demo demo_name demo_file)
    set(__LIBRARY_LIST "${LIBRARY_LIST}")
    set(CURRENT_DEMO "${demo_name}")
    add_executable("${CURRENT_DEMO}" ${demo_file})
    idi_target_compile_settings("${CURRENT_DEMO}")

    target_include_directories("${CURRENT_DEMO}" SYSTEM PRIVATE
        "${IDI_EXTERNAL_LIB_DIR}/Catch2/single_include")

    target_link_libraries("${CURRENT_DEMO}" "${IDI_CORE}")
    list(APPEND __LIBRARY_LIST ${CURRENT_DEMO})
    list(APPEND __LIBRARY_LIST ${IDI_CORE})


    set(ADD_MODE "ADDITIONAL_SOURCES")
    foreach(var IN LISTS ARGN)
        if(var STREQUAL "ADDITIONAL_LIBRARIES")
            set(ADD_MODE "ADDITIONAL_LIBRARIES")
        elseif(var STREQUAL "EXTERNAL_LIBRARIES")
            set(ADD_MODE "EXTERNAL_LIBRARIES")
        elseif(var STREQUAL "ADDITIONAL_INCLUDES")
            set(ADD_MODE "ADDITIONAL_INCLUDES")
        elseif(var STREQUAL "ADDITIONAL_SOURCES")
            set(ADD_MODE "ADDITIONAL_SOURCES")
        else()
            if(ADD_MODE STREQUAL "ADDITIONAL_LIBRARIES")
                target_link_libraries("${CURRENT_DEMO}" "${IDI_PROJECT_NAME}_${var}")
                list(APPEND __LIBRARY_LIST ${var})
            elseif(ADD_MODE STREQUAL "EXTERNAL_LIBRARIES")
                target_link_libraries("${CURRENT_DEMO}" ${var})
                list(APPEND __LIBRARY_LIST ${var})
            elseif(ADD_MODE STREQUAL "ADDITIONAL_SOURCES")
                target_sources("${CURRENT_DEMO}" PRIVATE ${var})
            elseif(ADD_MODE STREQUAL "ADDITIONAL_INCLUDES")
                target_include_directories("${CURRENT_DEMO}" SYSTEM PRIVATE
                    ${var})
            endif()
        endif()
    endforeach()
    if (IDI_IS_SHARED)
        # setting target BUILD_WITH_INSTALL_RPATH to OFF for a shared library
        # will make sure that demos link against the build tree RPATH and not
        # the system install dir, this lets tests for the .so on linux.
        set_property(TARGET ${CURRENT_DEMO} PROPERTY BUILD_WITH_INSTALL_RPATH OFF)
    endif()
endfunction()

macro(idi_demo demo_name demo_file)
    __idi_demo(${demo_name} ${demo_file} ${ARGN})
endmacro()

function(__idi_component_test component_name test_file)
    set(__LIBRARY_LIST "${LIBRARY_LIST}")
    get_filename_component(TEST_FILE_WLE ${test_file} NAME_WLE)
    set(CURRENT_LIBRARY_TEST "${IDI_PROJECT_NAME}_${component_name}_${TEST_FILE_WLE}")

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
        elseif(var STREQUAL "EXTERNAL_LIBRARIES")
            set(ADD_MODE "EXTERNAL_LIBRARIES")
        elseif(var STREQUAL "ADDITIONAL_INCLUDES")
            set(ADD_MODE "ADDITIONAL_INCLUDES")
        elseif(var STREQUAL "ADDITIONAL_SOURCES")
            set(ADD_MODE "ADDITIONAL_SOURCES")
        else()
            if(ADD_MODE STREQUAL "ADDITIONAL_LIBRARIES")
                target_link_libraries("${CURRENT_LIBRARY_TEST}" "${IDI_PROJECT_NAME}_${var}")
                list(APPEND __LIBRARY_LIST ${var})
            elseif(ADD_MODE STREQUAL "EXTERNAL_LIBRARIES")
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

function(idi_component_setup component_name)
    set(__LIBRARY_LIST "")
    set(CURRENT_LIBRARY_NAME "${IDI_PROJECT_NAME}_${component_name}")
    set(CURRENT_LIBRARY_DIR ${CMAKE_CURRENT_LIST_DIR})
    idi_cmake_hook(pre-component)
    add_library("${CURRENT_LIBRARY_NAME}" OBJECT "")
    idi_target_compile_settings("${CURRENT_LIBRARY_NAME}")

    file(GLOB include_dirs RELATIVE ${CMAKE_CURRENT_LIST_DIR}/include ${CMAKE_CURRENT_LIST_DIR}/include/*)
    list(LENGTH include_dirs num_include_dirs)
    if (num_include_dirs GREATER 1 OR num_include_dirs LESS 1)
        message(FATAL_ERROR "The include directory ${CMAKE_CURRENT_LIST_DIR}/include must contain exactly one subfolder (of any name) and no other files.")
    endif()

    list(GET include_dirs 0 include_dir_name)

    if (NOT include_dir_name STREQUAL ${IDI_PROJECT_NAME})
        message(STATUS "Updating include prefix dir in ${CMAKE_CURRENT_LIST_DIR}/include/ from ${include_dir_name} to ${IDI_PROJECT_NAME}")
        file(RENAME ${CMAKE_CURRENT_LIST_DIR}/include/${include_dir_name} ${CMAKE_CURRENT_LIST_DIR}/include/${IDI_PROJECT_NAME})
    endif()

    set(ADD_MODE "ADDITIONAL_LIBRARIES")
    foreach(var IN LISTS ARGN)
        if(var STREQUAL "ADDITIONAL_LIBRARIES")
            set(ADD_MODE "ADDITIONAL_LIBRARIES")
        elseif(var STREQUAL "EXTERNAL_LIBRARIES")
            set(ADD_MODE "EXTERNAL_LIBRARIES")
        elseif(var STREQUAL "ADDITIONAL_INCLUDES")
            set(ADD_MODE "ADDITIONAL_INCLUDES")
        elseif(var STREQUAL "ADDITIONAL_SOURCES")
            set(ADD_MODE "ADDITIONAL_SOURCES")
        else()
            if(ADD_MODE STREQUAL "ADDITIONAL_LIBRARIES")
                target_link_libraries("${CURRENT_LIBRARY_NAME}" "${IDI_PROJECT_NAME}_${var}")
                list(APPEND __LIBRARY_LIST ${var})
            elseif(ADD_MODE STREQUAL "EXTERNAL_LIBRARIES")
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

    target_include_directories(${CURRENT_LIBRARY_NAME} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/)
    if(IDI_IS_SHARED)
        set_target_properties("${CURRENT_LIBRARY_NAME}" PROPERTIES CXX_VISIBILITY_PRESET hidden)
        set_target_properties("${CURRENT_LIBRARY_NAME}" PROPERTIES C_VISIBILITY_PRESET hidden)
        install(TARGETS "${CURRENT_LIBRARY_NAME}"
                FILE_SET core_public_includes DESTINATION includes/${IDI_MAIN_TARGET}
        )
        if(IDI_IS_SUBDIRECTORY)
            target_include_directories(${CURRENT_LIBRARY_NAME} PUBLIC ${CMAKE_CURRENT_LIST_DIR}/include/${IDI_PROJECT_NAME})
        else()
            target_include_directories(${CURRENT_LIBRARY_NAME} PUBLIC ${CMAKE_CURRENT_LIST_DIR}/include/${IDI_PROJECT_NAME}/public)
        endif()
    else()
        install(TARGETS "${CURRENT_LIBRARY_NAME}"
            FILE_SET core_includes DESTINATION includes/${IDI_MAIN_TARGET}
        )
        if(IDI_IS_SUBDIRECTORY)
            target_include_directories(${CURRENT_LIBRARY_NAME} PUBLIC ${CMAKE_CURRENT_LIST_DIR}/include)
        else()
            target_include_directories(${CURRENT_LIBRARY_NAME} PUBLIC ${CMAKE_CURRENT_LIST_DIR}/include/${IDI_PROJECT_NAME})
        endif()
    endif()
    if (IDI_IS_SHARED OR IDI_FORCE_PIC)
        set_property(TARGET ${CURRENT_LIBRARY_NAME} PROPERTY POSITION_INDEPENDENT_CODE ON)
    endif()
    source_group(TREE ${CMAKE_CURRENT_LIST_DIR}
        FILES ${INTERNAL_FILE_LIST})

    target_code_coverage("${CURRENT_LIBRARY_NAME}" ALL OBJECTS "${__LIBRARY_LIST}")
    idi_cmake_hook(post-component)
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
                    list(APPEND __INTERNAL_FILE_LIST ${CONFIGURED_FILENAME})
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
endmacro()

macro(idi_add_includes)
    set(FILE_LIST "")
    __process_source_files(${ARGN})
    target_sources("${CURRENT_LIBRARY_NAME}" PUBLIC FILE_SET core_includes TYPE HEADERS BASE_DIRS ${CURRENT_LIBRARY_DIR}/include/${IDI_PROJECT_NAME} FILES ${FILE_LIST})
endmacro()

function(idi_add_public_includes)
    set(FILE_LIST "")
    __process_source_files(${ARGN})
    target_sources("${CURRENT_LIBRARY_NAME}" PUBLIC FILE_SET core_public_includes TYPE HEADERS BASE_DIRS ${CURRENT_LIBRARY_DIR}/include/${IDI_PROJECT_NAME}/public FILES ${FILE_LIST})
    target_sources("${CURRENT_LIBRARY_NAME}" PUBLIC FILE_SET core_includes TYPE HEADERS BASE_DIRS ${CURRENT_LIBRARY_DIR}/include/${IDI_PROJECT_NAME} FILES ${FILE_LIST})
endfunction()

function(idi_add_additional_files)
    foreach(var IN LISTS ARGN)
        get_filename_component(ADDITIONAL_FILE_NAME ${var} NAME)
        configure_file("${var}" "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${ADDITIONAL_FILE_NAME}" COPYONLY)
    endforeach()
endfunction()
