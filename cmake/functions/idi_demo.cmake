#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2022 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

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
