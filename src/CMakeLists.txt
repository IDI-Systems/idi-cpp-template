#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2021 International Development & Integration Systems LLC
#
include(CMakePrintHelpers)
add_code_coverage_all_targets(EXCLUDE tests/* lib/*)
#####################################################################
# CORE LIBRARY                                                      #
#####################################################################

if(IDI_IS_LIBRARY)
    set(IDI_MAIN_TARGET "${IDI_PROJECT_NAME}")
    set(IDI_CORE "${IDI_MAIN_TARGET}")
    if(IDI_IS_SHARED)
        add_library("${IDI_MAIN_TARGET}" SHARED "")
    endif()
endif()

if (NOT IDI_IS_LIBRARY)
    set(IDI_MAIN_TARGET "${IDI_PROJECT_NAME}")
    set(IDI_CORE "${IDI_PROJECT_NAME}_core")
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
include("${CMAKE_CURRENT_LIST_DIR}/components.cmake")

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
                LIBRARY)
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
        LIBRARY)
endif()
