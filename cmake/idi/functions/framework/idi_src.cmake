#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2025 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

macro(idi_src)
    include(CMakePrintHelpers)
    add_code_coverage_all_targets(EXCLUDE tests/* lib/*)
    #####################################################################
    # CORE LIBRARY                                                      #
    #####################################################################
    if(IDICMAKE_IS_LIBRARY AND NOT IDICMAKE_IS_SHARED)
        set(IDICMAKE_CORE "${IDICMAKE_PROJECT_NAME}")
    else()
        set(IDICMAKE_CORE "${IDICMAKE_PROJECT_NAME}_core")
    endif()
    # backwards compat, since CORE is always the main target
    set(IDICMAKE_MAIN_TARGET ${IDICMAKE_CORE})

    add_library("${IDICMAKE_CORE}" STATIC "")

    set(IDICMAKE_CORE ${IDICMAKE_CORE} PARENT_SCOPE)
    idi_target_compile_settings("${IDICMAKE_CORE}")
    set_target_properties("${IDICMAKE_CORE}" PROPERTIES LINKER_LANGUAGE CXX)

    #####################################################################
    # PUBLIC CONSUMER INCLUDE TRACKING                                  #
    #####################################################################
    if(IDICMAKE_IS_SHARED)
        # Components that register public headers will append their
        # include/ base directory to this global property.  After all
        # components are processed the _public consumer target uses it.
        define_property(GLOBAL PROPERTY IDICMAKE_PUBLIC_INCLUDE_DIRS
            BRIEF_DOCS "Include dirs of components that expose public headers"
            FULL_DOCS "Accumulated by idi_add_public_includes(); consumed by the _public interface target.")
        set_property(GLOBAL PROPERTY IDICMAKE_PUBLIC_INCLUDE_DIRS "")

        # Relative paths of every public header
        # (e.g. <project>/public/some_header.h).
        # Used to generate the umbrella header.
        define_property(GLOBAL PROPERTY IDICMAKE_PUBLIC_HEADER_RELPATHS
            BRIEF_DOCS "Relative include paths of public headers"
            FULL_DOCS "Accumulated by idi_add_public_includes(); used to generate the umbrella header.")
        set_property(GLOBAL PROPERTY IDICMAKE_PUBLIC_HEADER_RELPATHS "")
    endif()

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
    # MAIN TARGET (if not just a static lib)                            #
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
        message(STATUS "------ Added EXECUTABLE ${IDICMAKE_PROJECT_NAME}")
    else()
        if(IDICMAKE_IS_SHARED)
            add_library("${IDICMAKE_PROJECT_NAME}" SHARED "")
            target_link_libraries("${IDICMAKE_PROJECT_NAME}" PUBLIC "$<LINK_LIBRARY:WHOLE_ARCHIVE,${IDICMAKE_CORE}>")
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

            # Consumer-facing INTERFACE target that only exposes include
            # dirs from components that registered public headers via
            # idi_add_public_includes().  Demos and external projects can
            # link against this to verify they do not depend on internal
            # headers from non-public components.
            add_library("${IDICMAKE_PROJECT_NAME}_public" INTERFACE)
            target_link_libraries("${IDICMAKE_PROJECT_NAME}_public" INTERFACE
                "$<LINK_ONLY:${IDICMAKE_PROJECT_NAME}>")
            get_property(_pub_inc_dirs GLOBAL PROPERTY IDICMAKE_PUBLIC_INCLUDE_DIRS)
            foreach(_dir IN LISTS _pub_inc_dirs)
                target_include_directories("${IDICMAKE_PROJECT_NAME}_public" INTERFACE "${_dir}")
            endforeach()

            # Generate umbrella header: <project>/<project>.h
            if(IDICMAKE_GENERATE_UMBRELLA_HEADER)
                set(_umbrella_dir "${CMAKE_BINARY_DIR}/generated")
                set(_umbrella_file "${_umbrella_dir}/${IDICMAKE_PROJECT_NAME}/${IDICMAKE_PROJECT_NAME}.h")
                get_property(_pub_rels GLOBAL PROPERTY IDICMAKE_PUBLIC_HEADER_RELPATHS)
                set(_umbrella_content "/* Auto-generated umbrella header — do not edit. */\n")
                string(APPEND _umbrella_content "#pragma once\n\n")
                foreach(_rel IN LISTS _pub_rels)
                    # Skip internal configure outputs (__ prefixed filenames)
                    get_filename_component(_fname "${_rel}" NAME)
                    string(SUBSTRING "${_fname}" 0 2 _prefix)
                    if(NOT _prefix STREQUAL "__")
                        string(APPEND _umbrella_content "#include \"${_rel}\"\n")
                    endif()
                endforeach()
                file(MAKE_DIRECTORY "${_umbrella_dir}/${IDICMAKE_PROJECT_NAME}")
                file(WRITE "${_umbrella_file}" "${_umbrella_content}")
                target_include_directories("${IDICMAKE_PROJECT_NAME}_public" INTERFACE "${_umbrella_dir}")
                # Also expose to core so all targets in the project can
                # use the umbrella header.
                target_include_directories("${IDICMAKE_CORE}" PUBLIC "${_umbrella_dir}")

                # Install the umbrella header alongside the other public headers
                install(FILES "${_umbrella_file}"
                    DESTINATION includes/${IDICMAKE_PROJECT_NAME}/${IDICMAKE_PROJECT_NAME})
                message(STATUS "------ Generated umbrella header ${IDICMAKE_PROJECT_NAME}/${IDICMAKE_PROJECT_NAME}.h")
            endif()

            message(STATUS "------ Added SHARED Library ${IDICMAKE_PROJECT_NAME}")
            message(STATUS "------ Added PUBLIC consumer target ${IDICMAKE_PROJECT_NAME}_public")
        else()
            message(STATUS "------ Added STATIC Library ${IDICMAKE_PROJECT_NAME}")
        endif()
    endif()
endmacro()
