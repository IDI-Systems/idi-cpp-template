#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2022 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

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
