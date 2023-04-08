#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2022 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

macro(idi_src)
    include(CMakePrintHelpers)
    add_code_coverage_all_targets(EXCLUDE tests/* lib/*)
    #####################################################################
    # CORE LIBRARY                                                      #
    #####################################################################

    if(IDI_IS_LIBRARY)
        set(IDI_MAIN_TARGET "${IDI_PROJECT_NAME}")
        set(IDI_CORE "${IDI_MAIN_TARGET}_${__idi_version_full}")
        if(IDI_IS_SHARED)
            add_library("${IDI_MAIN_TARGET}" SHARED "")
        endif()
    endif()

    if (NOT IDI_IS_LIBRARY)
        set(IDI_MAIN_TARGET "${IDI_PROJECT_NAME}")
        set(IDI_CORE "${IDI_PROJECT_NAME}_core_${__idi_version_full}")
        target_code_coverage("${IDI_CORE}" ALL)
    endif()

    if (NOT IDI_IS_SHARED)
        add_library("${IDI_CORE}" STATIC "")
    endif()

    set(IDI_CORE ${IDI_CORE} PARENT_SCOPE)
    idi_target_compile_settings("${IDI_CORE}")
    set_target_properties("${IDI_CORE}" PROPERTIES LINKER_LANGUAGE CXX)

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
    if((IDI_IS_LIBRARY AND IDI_IS_SHARED) OR (NOT IDI_IS_LIBRARY))
        if(IDI_IS_SHARED)
            set_target_properties("${IDI_MAIN_TARGET}" PROPERTIES CXX_VISIBILITY_PRESET hidden)
            set_target_properties("${IDI_MAIN_TARGET}" PROPERTIES C_VISIBILITY_PRESET hidden)

            target_sources(
                "${IDI_MAIN_TARGET}"
                PRIVATE
                # EDIT LIST FILES BELOW HERE
                "${CMAKE_CURRENT_LIST_DIR}/main/dll_main.cpp"
            )
            install(TARGETS "${IDI_MAIN_TARGET}"
                    LIBRARY FILE_SET HEADERS DESTINATION includes/${IDI_MAIN_TARGET}/public)
        else()
            add_executable("${IDI_MAIN_TARGET}" "")
            target_sources(
                "${IDI_MAIN_TARGET}"
                PRIVATE
                # EDIT LIST FILES BELOW HERE
                "${CMAKE_CURRENT_LIST_DIR}/main/main.cpp"
            )
            target_link_libraries("${IDI_MAIN_TARGET}" "${IDI_CORE}")
            idi_target_compile_settings("${IDI_MAIN_TARGET}")
            set_target_properties("${IDI_MAIN_TARGET}" PROPERTIES LINKER_LANGUAGE CXX)
            install(TARGETS "${IDI_MAIN_TARGET}"
                RUNTIME)
        endif()
        add_subdirectory("${CMAKE_CURRENT_LIST_DIR}/main")
        get_target_property(IDI_MAIN_TARGET_SOURCES "${IDI_MAIN_TARGET}" SOURCES)
            source_group(TREE ${CMAKE_CURRENT_LIST_DIR}
        FILES ${IDI_MAIN_TARGET_SOURCES})
        target_code_coverage("${IDI_MAIN_TARGET}" ALL OBJECTS "${IDI_CORE}")
    else()
        install(TARGETS "${IDI_CORE}"
            ARCHIVE)
    endif()

endmacro()
