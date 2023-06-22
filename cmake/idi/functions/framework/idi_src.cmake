#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2023 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

macro(idi_src)
    include(CMakePrintHelpers)
    add_code_coverage_all_targets(EXCLUDE tests/* lib/*)
    #####################################################################
    # CORE LIBRARY                                                      #
    #####################################################################
    set(IDICMAKE_CORE "${IDICMAKE_PROJECT_NAME}_${__idi_version_full}")
    # backwards compat, since CORE is always the main target
    set(IDICMAKE_MAIN_TARGET ${IDICMAKE_CORE})

    if(IDICMAKE_IS_LIBRARY AND IDICMAKE_IS_SHARED)
        set(IDICMAKE_SHARED_NAME ${IDICMAKE_CORE})
        add_library("${IDICMAKE_CORE}" SHARED "")
        message(STATUS "------ Added SHARED Library ${IDICMAKE_CORE}")
    else()
        add_library("${IDICMAKE_CORE}" STATIC "")
        message(STATUS "------ Added STATIC Library ${IDICMAKE_CORE}")
    endif()

    set(IDICMAKE_CORE ${IDICMAKE_CORE} PARENT_SCOPE)
    idi_target_compile_settings("${IDICMAKE_CORE}")
    set_target_properties("${IDICMAKE_CORE}" PROPERTIES LINKER_LANGUAGE CXX)

    #####################################################################
    # CORE COMPONENTS                                                   #
    #####################################################################

    # List core components below via add_subdirectory
    idi_cmake_hook(pre-components-list)
    include("${CMAKE_CURRENT_LIST_DIR}/components.cmake")
    idi_cmake_hook(post-components-list)

    if(DO_TEMPLATE_COMPONENT_TEST)
        add_subdirectory("unit_test_component")
    endif()

    #####################################################################
    # MAIN TARGET                                                       #
    #####################################################################

    if(NOT IDICMAKE_IS_LIBRARY)
        add_executable("${IDICMAKE_PROJECT_NAME}" "")
        target_sources(
            "${IDICMAKE_PROJECT_NAME}"
            PRIVATE
            "${CMAKE_CURRENT_LIST_DIR}/main/main.cpp"
        )
        target_link_libraries("${IDICMAKE_PROJECT_NAME}" "${IDICMAKE_CORE}")
        idi_target_compile_settings("${IDICMAKE_PROJECT_NAME}")
        set_target_properties("${IDICMAKE_PROJECT_NAME}" PROPERTIES LINKER_LANGUAGE CXX)
        install(TARGETS "${IDICMAKE_PROJECT_NAME}"
            RUNTIME)
        add_subdirectory("${CMAKE_CURRENT_LIST_DIR}/main")
    else()
        if(IDICMAKE_IS_SHARED)
            add_library("${IDICMAKE_PROJECT_NAME}" SHARED "")
            set(IDICMAKE_SHARED_NAME ${IDICMAKE_PROJECT_NAME})

            set_target_properties("${IDICMAKE_SHARED_NAME}" PROPERTIES CXX_VISIBILITY_PRESET hidden)
            set_target_properties("${IDICMAKE_SHARED_NAME}" PROPERTIES C_VISIBILITY_PRESET hidden)

            target_sources(
                "${IDICMAKE_SHARED_NAME}"
                PRIVATE
                "${CMAKE_CURRENT_LIST_DIR}/main/dll_main.cpp"
            )
            install(TARGETS "${IDICMAKE_SHARED_NAME}"
                    LIBRARY FILE_SET HEADERS DESTINATION includes/${IDICMAKE_PROJECT_NAME}/public)
            add_subdirectory("${CMAKE_CURRENT_LIST_DIR}/main")
        else()
            add_library("${IDICMAKE_PROJECT_NAME}" ALIAS ${IDICMAKE_CORE})
        endif()
    endif()
endmacro()
