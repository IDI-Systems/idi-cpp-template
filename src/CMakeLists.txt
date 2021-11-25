#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2021 International Development & Integration Systems LLC
#

#####################################################################
# GLOBAL COMPILER OPTIONS                                           #
#####################################################################
if (MSVC)
    add_compile_options(/W4 /WX /Zc:__cplusplus /MP /std:c++latest)
    add_compile_definitions(_CRT_SECURE_NO_WARNINGS) # Disable MSVC 'unsafe' function warnings
else()
    add_compile_options(-Wall -Wextra -Wshadow -pedantic -Werror)
endif()


#####################################################################
# CORE LIBRARY                                                      #
#####################################################################
set(IDI_MAIN_TARGET "${IDI_PROJECT_NAME}")
set(IDI_CORE "idi_core")
if(IDI_IS_LIBRARY AND IDI_IS_DYNAMIC)
    set(IDI_CORE "${IDI_MAIN_TARGET}")
    add_library("${IDI_CORE}" SHARED "")
else()
    add_library("${IDI_CORE}" STATIC "")
endif()
target_compile_features("${IDI_CORE}" PRIVATE cxx_std_20)
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
if((IDI_IS_LIBRARY AND IDI_IS_DYNAMIC) OR (NOT IDI_IS_LIBRARY))
    if(IDI_IS_DYNAMIC)
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
        target_compile_features("${IDI_MAIN_TARGET}" PRIVATE cxx_std_20)
        set_target_properties("${IDI_MAIN_TARGET}" PROPERTIES LINKER_LANGUAGE CXX)
        install(TARGETS "${IDI_MAIN_TARGET}"
            RUNTIME)
    endif()
    add_subdirectory("main")
    get_target_property(IDI_MAIN_TARGET_SOURCES "${IDI_MAIN_TARGET}" SOURCES)
        source_group(TREE ${CMAKE_CURRENT_LIST_DIR}
    FILES ${IDI_MAIN_TARGET_SOURCES})
else()
    install(TARGETS "${IDI_CORE}"
        LIBRARY)
endif()
