#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2026 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#
# API documentation: a 'docs' target that runs Doxygen over the project's headers, themed with
# doxygen-awesome-css (https://github.com/jothepro/doxygen-awesome-css).
#
# The target is created for top-level builds when <P>_BUILD_DOCS is on (default) and Doxygen is found.
# It is not part of ALL: run `cmake --build build --target docs` or cmake/idi/tools/docs.{sh,bat}.
#
# Inputs are collected from the components automatically:
#   shared library : each component's include/<proj>/public/ (the exported API), plus header-only components
#   static / exe   : each component's include/<proj>/
# Configured headers (__*.out.h) are documented; their unconfigured templates (__*.h) are not.
# The main page is docs/mainpage.md if it exists (other docs/*.md become extra pages), else README.md.
#
# Variables (set in cmake-hooks/post-options.cmake, or with -D):
#   IDICMAKE_DOCS_THEME       - Use doxygen-awesome-css (default ON; downloaded when 'docs' is first built)
#   IDICMAKE_DOCS_OUTPUT_DIR  - Output directory (default <build>/docs; HTML in <dir>/html)
#   IDICMAKE_DOCS_BRIEF       - One-line project description shown under the title
#   IDICMAKE_DOCS_INPUTS      - Extra files/directories to document
#   DOXYGEN_<KEY>             - Any Doxyfile setting; values set by the project win over the defaults here
#

include_guard(GLOBAL)

set_property(GLOBAL PROPERTY _IDICMAKE_DOCS_THEME_SCRIPT "${CMAKE_CURRENT_LIST_DIR}/../scripts/docs-theme.cmake")

set(IDICMAKE_DOCS_THEME ON CACHE BOOL "Theme the docs target with doxygen-awesome-css (downloaded at docs build time)")

# Pinned theme release. Update the version and hash together.
set(_IDICMAKE_DOCS_THEME_VERSION "2.5.0")
set(_IDICMAKE_DOCS_THEME_SHA256 "853d5939f724fd3b388b8a33f5459ba8a50a7972df3e721d7d66da05d82eea33")

# Called by idi_component_setup for every component.
function(idi_docs_register_component component_dir header_only)
    if(IDICMAKE_IS_SHARED AND NOT header_only)
        set(_dir "${component_dir}/include/${IDICMAKE_PROJECT_NAME}/public")
    else()
        set(_dir "${component_dir}/include/${IDICMAKE_PROJECT_NAME}")
    endif()
    if(IS_DIRECTORY "${_dir}")
        set_property(GLOBAL APPEND PROPERTY IDICMAKE_DOC_INPUT_DIRS "${_dir}")
    endif()
endfunction()

# Called by the framework from idi_src(); a no-op for subprojects or when <P>_BUILD_DOCS is off.
function(idi_docs_setup)
    if(IDICMAKE_IS_SUBDIRECTORY OR NOT IDICMAKE_BUILD_DOCS)
        return()
    endif()
    cmake_language(DEFER DIRECTORY ${CMAKE_SOURCE_DIR} CALL _idicmake_create_docs_target)
endfunction()

# Set DOXYGEN_<key> unless the project already set it.
macro(_idicmake_doxygen_default key)
    if(NOT DEFINED DOXYGEN_${key})
        set(DOXYGEN_${key} ${ARGN})
    endif()
endmacro()

function(_idicmake_create_docs_target)
    if(TARGET docs)
        message(STATUS "[Docs] A 'docs' target already exists in this project; the framework docs target is not added.")
        return()
    endif()

    find_package(Doxygen QUIET)
    if(NOT DOXYGEN_FOUND)
        message(STATUS "[Docs] Doxygen not found; 'docs' target not available (install doxygen to enable it).")
        return()
    endif()

    # Collect header files. Explicit files (rather than directories) let us keep __*.out.h but skip __*.h templates.
    get_property(_dirs GLOBAL PROPERTY IDICMAKE_DOC_INPUT_DIRS)
    list(REMOVE_DUPLICATES _dirs)
    set(_inputs "")
    set(_strip "")
    foreach(_dir IN LISTS _dirs)
        file(GLOB_RECURSE _headers "${_dir}/*.h" "${_dir}/*.hh" "${_dir}/*.hpp" "${_dir}/*.hxx")
        foreach(_h IN LISTS _headers)
            get_filename_component(_name "${_h}" NAME)
            if(_name MATCHES "^__" AND NOT _name MATCHES "\\.out\\.")
                continue()
            endif()
            list(APPEND _inputs "${_h}")
        endforeach()
        # Show paths the way they are included: <proj>/public/x.h
        string(REGEX REPLACE "/include/.*$" "/include" _inc_root "${_dir}")
        list(APPEND _strip "${_inc_root}")
    endforeach()
    list(REMOVE_DUPLICATES _strip)

    set(_mainpage "")
    if(EXISTS "${CMAKE_SOURCE_DIR}/docs/mainpage.md")
        set(_mainpage "${CMAKE_SOURCE_DIR}/docs/mainpage.md")
        file(GLOB _pages "${CMAKE_SOURCE_DIR}/docs/*.md")
        list(APPEND _inputs ${_pages})
    elseif(EXISTS "${CMAKE_SOURCE_DIR}/README.md")
        set(_mainpage "${CMAKE_SOURCE_DIR}/README.md")
        list(APPEND _inputs "${_mainpage}")
    endif()
    list(APPEND _inputs ${IDICMAKE_DOCS_INPUTS})

    if(NOT _inputs)
        message(STATUS "[Docs] No headers to document; 'docs' target not added.")
        return()
    endif()

    if(DEFINED IDICMAKE_DOCS_OUTPUT_DIR)
        set(_out "${IDICMAKE_DOCS_OUTPUT_DIR}")
    else()
        set(_out "${CMAKE_BINARY_DIR}/docs")
    endif()

    _idicmake_doxygen_default(PROJECT_NAME "${IDICMAKE_PROJECT_NAME}")
    _idicmake_doxygen_default(PROJECT_NUMBER "${__idi_version_full}")
    if(IDICMAKE_DOCS_BRIEF)
        _idicmake_doxygen_default(PROJECT_BRIEF "${IDICMAKE_DOCS_BRIEF}")
    endif()
    _idicmake_doxygen_default(OUTPUT_DIRECTORY "${_out}")
    _idicmake_doxygen_default(USE_MDFILE_AS_MAINPAGE "${_mainpage}")
    _idicmake_doxygen_default(STRIP_FROM_PATH ${_strip} "${CMAKE_SOURCE_DIR}")
    _idicmake_doxygen_default(STRIP_FROM_INC_PATH ${_strip})
    _idicmake_doxygen_default(EXTRACT_ALL YES)
    _idicmake_doxygen_default(EXTRACT_PRIVATE NO)
    _idicmake_doxygen_default(EXTRACT_STATIC YES)
    _idicmake_doxygen_default(HIDE_UNDOC_MEMBERS YES)
    _idicmake_doxygen_default(HIDE_UNDOC_CLASSES YES)
    _idicmake_doxygen_default(HIDE_FRIEND_COMPOUNDS YES)
    _idicmake_doxygen_default(ENABLE_PREPROCESSING YES)
    _idicmake_doxygen_default(MACRO_EXPANSION YES)
    _idicmake_doxygen_default(EXPAND_ONLY_PREDEF YES)
    _idicmake_doxygen_default(PREDEFINED "${__idi_c_caps_namespace}_EXPORT=")
    _idicmake_doxygen_default(GENERATE_HTML YES)
    _idicmake_doxygen_default(GENERATE_LATEX NO)
    _idicmake_doxygen_default(GENERATE_TREEVIEW YES)
    _idicmake_doxygen_default(DISABLE_INDEX NO)
    _idicmake_doxygen_default(FULL_SIDEBAR NO)
    _idicmake_doxygen_default(SOURCE_BROWSER NO)
    _idicmake_doxygen_default(VERBATIM_HEADERS NO)
    _idicmake_doxygen_default(HAVE_DOT NO)
    _idicmake_doxygen_default(QUIET YES)
    _idicmake_doxygen_default(WARN_IF_UNDOCUMENTED YES)
    _idicmake_doxygen_default(WARN_NO_PARAMDOC NO)

    set(_theme_dir "${CMAKE_BINARY_DIR}/docs-theme")
    if(IDICMAKE_DOCS_THEME)
        if(DOXYGEN_VERSION VERSION_LESS 1.9.6)
            message(WARNING "[Docs] doxygen-awesome-css works best with Doxygen >= 1.9.6 (found ${DOXYGEN_VERSION}). "
                "Set IDICMAKE_DOCS_THEME=OFF if the output looks wrong.")
        endif()
        # The theme requires the light color style; it provides its own dark mode.
        _idicmake_doxygen_default(HTML_COLORSTYLE LIGHT)
        _idicmake_doxygen_default(HTML_HEADER "${_theme_dir}/header.html")
        _idicmake_doxygen_default(HTML_EXTRA_STYLESHEET "${_theme_dir}/doxygen-awesome.css")
        _idicmake_doxygen_default(HTML_EXTRA_FILES
            "${_theme_dir}/doxygen-awesome-darkmode-toggle.js"
            "${_theme_dir}/doxygen-awesome-fragment-copy-button.js"
            "${_theme_dir}/doxygen-awesome-paragraph-link.js")
    endif()

    doxygen_add_docs(docs ${_inputs}
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
        COMMENT "Generating API documentation with Doxygen")
    add_custom_command(TARGET docs POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E echo "[Docs] ${_out}/html/index.html"
        VERBATIM)

    if(IDICMAKE_DOCS_THEME)
        get_property(_theme_script GLOBAL PROPERTY _IDICMAKE_DOCS_THEME_SCRIPT)
        add_custom_target(docs-theme
            COMMAND ${CMAKE_COMMAND}
                "-DTHEME_DIR=${_theme_dir}"
                "-DTHEME_VERSION=${_IDICMAKE_DOCS_THEME_VERSION}"
                "-DTHEME_SHA256=${_IDICMAKE_DOCS_THEME_SHA256}"
                "-DDOXYGEN=${DOXYGEN_EXECUTABLE}"
                -P "${_theme_script}"
            COMMENT "Preparing the doxygen-awesome-css theme"
            VERBATIM)
        add_dependencies(docs docs-theme)
    endif()

    list(LENGTH _inputs _count)
    message(STATUS "[Docs] 'docs' target added (Doxygen ${DOXYGEN_VERSION}, ${_count} inputs, output ${_out}/html)")
endfunction()
