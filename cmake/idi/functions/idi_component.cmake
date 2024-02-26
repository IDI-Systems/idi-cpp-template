#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2024 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

function(idi_component_setup component_name)
    set(HEADER_ONLY false)
    foreach(var IN LISTS ARGN)
        if(var STREQUAL "HEADER_ONLY")
            set(HEADER_ONLY true)
            list(REMOVE_ITEM ARGN "HEADER_ONLY")
        endif()
    endforeach()
    set(__LIBRARY_LIST "")
    set(CURRENT_LIBRARY_NAME "${IDICMAKE_PROJECT_NAME}_${component_name}")
    set(CURRENT_LIBRARY_DIR ${CMAKE_CURRENT_LIST_DIR})
    idi_cmake_hook(pre-component)
    if (HEADER_ONLY)
        add_library("${CURRENT_LIBRARY_NAME}" INTERFACE)
    else()
        add_library("${CURRENT_LIBRARY_NAME}" OBJECT "")
        idi_target_compile_settings("${CURRENT_LIBRARY_NAME}")
    endif()


    file(GLOB include_dirs RELATIVE ${CMAKE_CURRENT_LIST_DIR}/include ${CMAKE_CURRENT_LIST_DIR}/include/*)
    list(LENGTH include_dirs num_include_dirs)
    if (num_include_dirs GREATER 1 OR num_include_dirs LESS 1)
        message(FATAL_ERROR "The include directory ${CMAKE_CURRENT_LIST_DIR}/include must contain exactly one subfolder (of any name) and no other files.")
    endif()

    list(GET include_dirs 0 include_dir_name)

    if (NOT include_dir_name STREQUAL ${IDICMAKE_PROJECT_NAME})
        message(STATUS "Updating include prefix dir in ${CMAKE_CURRENT_LIST_DIR}/include/ from ${include_dir_name} to ${IDICMAKE_PROJECT_NAME}")
        file(RENAME ${CMAKE_CURRENT_LIST_DIR}/include/${include_dir_name} ${CMAKE_CURRENT_LIST_DIR}/include/${IDICMAKE_PROJECT_NAME})
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
                if (HEADER_ONLY)
                    target_link_libraries("${CURRENT_LIBRARY_NAME}" INTERFACE "${IDICMAKE_PROJECT_NAME}_${var}")
                else()
                    target_link_libraries("${CURRENT_LIBRARY_NAME}" PUBLIC "${IDICMAKE_PROJECT_NAME}_${var}")
                endif()
            elseif(ADD_MODE STREQUAL "EXTERNAL_LIBRARIES")
                if (HEADER_ONLY)
                    target_link_libraries("${CURRENT_LIBRARY_NAME}" INTERFACE ${var})
                else()
                    target_link_libraries("${CURRENT_LIBRARY_NAME}" PUBLIC ${var})
                endif()
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
    target_link_libraries("${IDICMAKE_CORE}" PUBLIC
        "${CURRENT_LIBRARY_NAME}"
    )
    # if(NOT HEADER_ONLY)
    #     target_include_directories(${CURRENT_LIBRARY_NAME} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/)
    # endif()
    if(IDICMAKE_IS_SHARED)
        set_target_properties("${CURRENT_LIBRARY_NAME}" PROPERTIES CXX_VISIBILITY_PRESET hidden)
        set_target_properties("${CURRENT_LIBRARY_NAME}" PROPERTIES C_VISIBILITY_PRESET hidden)
        install(TARGETS "${CURRENT_LIBRARY_NAME}"
                FILE_SET core_public_includes DESTINATION includes/${IDICMAKE_PROJECT_NAME}
        )
        target_include_directories(${CURRENT_LIBRARY_NAME} PUBLIC ${CMAKE_CURRENT_LIST_DIR}/include)

    else()
        install(TARGETS "${CURRENT_LIBRARY_NAME}"
            FILE_SET core_includes DESTINATION includes/${IDICMAKE_PROJECT_NAME}
        )
        if (HEADER_ONLY)
            target_include_directories(${CURRENT_LIBRARY_NAME} INTERFACE ${CMAKE_CURRENT_LIST_DIR}/include)
        else()
            target_include_directories(${CURRENT_LIBRARY_NAME} PUBLIC ${CMAKE_CURRENT_LIST_DIR}/include)
        endif()
    endif()
    if (IDICMAKE_IS_SHARED OR IDICMAKE_FORCE_PIC)
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
