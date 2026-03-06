#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2025 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

function(__idi_demo demo_name demo_file)
    set(__LIBRARY_LIST "${LIBRARY_LIST}")
    set(CURRENT_DEMO "${demo_name}")
    add_executable("${CURRENT_DEMO}" ${demo_file})
    idi_target_compile_settings("${CURRENT_DEMO}")

    # target_include_directories("${CURRENT_DEMO}" SYSTEM PRIVATE
    #     "${IDICMAKE_EXTERNAL_LIB_DIR}/Catch2/single_include")



    set(ADD_MODE "ADDITIONAL_SOURCES")
    set(ADD_CORE true)
    set(ADD_CATCH true)
    set(USE_PUBLIC false)

    foreach(var IN LISTS ARGN)
        if(var STREQUAL "ADDITIONAL_LIBRARIES")
            set(ADD_MODE "ADDITIONAL_LIBRARIES")
        elseif(var STREQUAL "EXTERNAL_LIBRARIES")
            set(ADD_MODE "EXTERNAL_LIBRARIES")
        elseif(var STREQUAL "ADDITIONAL_INCLUDES")
            set(ADD_MODE "ADDITIONAL_INCLUDES")
        elseif(var STREQUAL "ADDITIONAL_SOURCES")
            set(ADD_MODE "ADDITIONAL_SOURCES")
        elseif(var STREQUAL "NO_CATCH")
            set(ADD_CATCH false)
        elseif(var STREQUAL "EXCLUDE_CORE")
            set(ADD_CORE false)
        elseif(var STREQUAL "PUBLIC_ONLY")
            set(USE_PUBLIC true)
        else()
            if(ADD_MODE STREQUAL "ADDITIONAL_LIBRARIES")
                target_link_libraries("${CURRENT_DEMO}" PUBLIC "${IDICMAKE_PROJECT_NAME}_${var}")
                list(APPEND __LIBRARY_LIST ${var})
            elseif(ADD_MODE STREQUAL "EXTERNAL_LIBRARIES")
                target_link_libraries("${CURRENT_DEMO}" PUBLIC ${var})
                list(APPEND __LIBRARY_LIST ${var})
            elseif(ADD_MODE STREQUAL "ADDITIONAL_SOURCES")
                target_sources("${CURRENT_DEMO}" PRIVATE ${var})
            elseif(ADD_MODE STREQUAL "ADDITIONAL_INCLUDES")
                target_include_directories("${CURRENT_DEMO}" SYSTEM PRIVATE
                    ${var})
            endif()
        endif()
    endforeach()

    if(ADD_CATCH)
        target_link_libraries("${CURRENT_DEMO}" PRIVATE Catch2::Catch2WithMain)
    endif()

    if(ADD_CORE)
        if(USE_PUBLIC AND TARGET "${IDICMAKE_PROJECT_NAME}_public")
            target_link_libraries("${CURRENT_DEMO}" PUBLIC "${IDICMAKE_PROJECT_NAME}_public")
        else()
            target_link_libraries("${CURRENT_DEMO}" PUBLIC "${IDICMAKE_CORE}")
        endif()
        list(APPEND __LIBRARY_LIST ${CURRENT_DEMO})
        list(APPEND __LIBRARY_LIST ${IDICMAKE_CORE})
    endif()

    if(IDICMAKE_IS_SHARED)
        # setting target BUILD_WITH_INSTALL_RPATH to OFF for a shared library
        # will make sure that demos link against the build tree RPATH and not
        # the system install dir, this lets tests for the .so on linux.
        set_property(TARGET ${CURRENT_DEMO} PROPERTY BUILD_WITH_INSTALL_RPATH OFF)
    endif()
endfunction()

macro(idi_demo demo_name demo_file)
    __idi_demo(${demo_name} ${demo_file} ${ARGN})
endmacro()

# Convenience wrapper that links against the _public consumer target
# instead of the core target.  This restricts the demo to only the
# public API headers, matching what an installed consumer would see.
# The demo is skipped entirely when not building a shared library,
# since the _public target only exists in shared mode.
macro(idi_demo_public demo_name demo_file)
    if(IDICMAKE_IS_SHARED AND TARGET "${IDICMAKE_PROJECT_NAME}_public")
        __idi_demo(${demo_name} ${demo_file} PUBLIC_ONLY ${ARGN})
    else()
        message(STATUS "------ Skipping public-only demo '${demo_name}': not building as a shared library")
    endif()
endmacro()
