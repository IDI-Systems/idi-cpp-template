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

    # if(IDI_IS_LIBRARY)
    #     set(IDI_MAIN_TARGET "${IDI_PROJECT_NAME}")
    #     set(IDI_CORE "${IDI_MAIN_TARGET}_${__idi_version_full}")
    #     if(IDI_IS_SHARED)
    #         add_library("${IDI_MAIN_TARGET}" SHARED "")
    #     endif()
    # endif()

    # if(NOT IDI_IS_LIBRARY)
    #     set(IDI_MAIN_TARGET "${IDI_PROJECT_NAME}")
    #     set(IDI_CORE "${IDI_PROJECT_NAME}_core_${__idi_version_full}")
    #     target_code_coverage("${IDI_CORE}" ALL)
    # endif()

    # if(NOT IDI_IS_SHARED)
    #     add_library("${IDI_CORE}" STATIC "")
    #     if(IDI_IS_LIBRARY AND (NOT IDI_DECONFLICT_MULTIPLE))
    #         add_library("${IDI_MAIN_TARGET}" ALIAS "${IDI_CORE}")
    #     endif()
    # endif()

    set(IDI_CORE "${IDI_PROJECT_NAME}_${__idi_version_full}")
    # backwards compat, since CORE is always the main target
    set(IDI_MAIN_TARGET ${IDI_CORE})

    if(IDI_IS_LIBRARY AND IDI_IS_SHARED AND IDI_DECONFLICT_MULTIPLE)
        set(IDI_SHARED_NAME ${IDI_CORE})
        add_library("${IDI_CORE}" SHARED "")
        message(STATUS "------ Added SHARED Library ${IDI_CORE}")
    else()
        add_library("${IDI_CORE}" STATIC "")
        message(STATUS "------ Added STATIC Library ${IDI_CORE}")
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

    if(NOT IDI_IS_LIBRARY)
        add_executable("${IDI_PROJECT_NAME}" "")
        target_sources(
            "${IDI_PROJECT_NAME}"
            PRIVATE
            # EDIT LIST FILES BELOW HERE
            "${CMAKE_CURRENT_LIST_DIR}/main/main.cpp"
        )
        target_link_libraries("${IDI_PROJECT_NAME}" "${IDI_CORE}")
        idi_target_compile_settings("${IDI_PROJECT_NAME}")
        set_target_properties("${IDI_PROJECT_NAME}" PROPERTIES LINKER_LANGUAGE CXX)
        install(TARGETS "${IDI_PROJECT_NAME}"
            RUNTIME)
        add_subdirectory("${CMAKE_CURRENT_LIST_DIR}/main")
    else()
        if(IDI_IS_SHARED)
            if(NOT IDI_DECONFLICT_MULTIPLE)
                add_library("${IDI_PROJECT_NAME}" SHARED "")
                set(IDI_SHARED_NAME ${IDI_PROJECT_NAME})
            endif()

            set_target_properties("${IDI_SHARED_NAME}" PROPERTIES CXX_VISIBILITY_PRESET hidden)
            set_target_properties("${IDI_SHARED_NAME}" PROPERTIES C_VISIBILITY_PRESET hidden)

            target_sources(
                "${IDI_SHARED_NAME}"
                PRIVATE
                # EDIT LIST FILES BELOW HERE
                "${CMAKE_CURRENT_LIST_DIR}/main/dll_main.cpp"
            )
            install(TARGETS "${IDI_SHARED_NAME}"
                    LIBRARY FILE_SET HEADERS DESTINATION includes/${IDI_PROJECT_NAME}/public)
            add_subdirectory("${CMAKE_CURRENT_LIST_DIR}/main")
        else()
            if(NOT IDI_DECONFLICT_MULTIPLE)
                add_library("${IDI_PROJECT_NAME}" ALIAS ${IDI_CORE})
            endif()
        endif()
    endif()
    # if((IDI_IS_LIBRARY AND IDI_IS_SHARED) OR (NOT IDI_IS_LIBRARY))
    #     if(IDI_IS_SHARED)
    #         set_target_properties("${IDI_MAIN_TARGET}" PROPERTIES CXX_VISIBILITY_PRESET hidden)
    #         set_target_properties("${IDI_MAIN_TARGET}" PROPERTIES C_VISIBILITY_PRESET hidden)

    #         target_sources(
    #             "${IDI_MAIN_TARGET}"
    #             PRIVATE
    #             # EDIT LIST FILES BELOW HERE
    #             "${CMAKE_CURRENT_LIST_DIR}/main/dll_main.cpp"
    #         )
    #         install(TARGETS "${IDI_MAIN_TARGET}"
    #                 LIBRARY FILE_SET HEADERS DESTINATION includes/${IDI_MAIN_TARGET}/public)
    #     else()
    #         add_executable("${IDI_MAIN_TARGET}" "")
    #         target_sources(
    #             "${IDI_MAIN_TARGET}"
    #             PRIVATE
    #             # EDIT LIST FILES BELOW HERE
    #             "${CMAKE_CURRENT_LIST_DIR}/main/main.cpp"
    #         )
    #         target_link_libraries("${IDI_MAIN_TARGET}" "${IDI_CORE}")
    #         idi_target_compile_settings("${IDI_MAIN_TARGET}")
    #         set_target_properties("${IDI_MAIN_TARGET}" PROPERTIES LINKER_LANGUAGE CXX)
    #         install(TARGETS "${IDI_MAIN_TARGET}"
    #             RUNTIME)
    #     endif()
    #     add_subdirectory("${CMAKE_CURRENT_LIST_DIR}/main")
    #     get_target_property(IDI_MAIN_TARGET_SOURCES "${IDI_MAIN_TARGET}" SOURCES)
    #         source_group(TREE ${CMAKE_CURRENT_LIST_DIR}
    #     FILES ${IDI_MAIN_TARGET_SOURCES})
    #     target_code_coverage("${IDI_MAIN_TARGET}" ALL OBJECTS "${IDI_CORE}")
    # else()
    #     install(TARGETS "${IDI_CORE}"
    #         ARCHIVE)
    # endif()

endmacro()
