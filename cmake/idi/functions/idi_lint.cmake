#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2025 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#
# Lint support: clang-format and clang-tidy targets for the project's own sources.
#
# Targets (top-level builds only, each skipped if a target with that name already exists):
#   format             - clang-format -i on every project file
#   format-check       - fail if any project file is not clang-formatted
#   tidy               - clang-tidy with the gate checks (IDICMAKE_LINT_TIDY_GATE_CHECKS); fails on any warning
#   tidy-report        - clang-tidy with the full .clang-tidy check list; report only, never fails
#   lint               - format-check + tidy
#   install-git-hooks  - install cmake/idi/tools/pre-commit (clang-format check of staged files)
#
# Variables (set in cmake-hooks/post-options.cmake, or with -D):
#   IDICMAKE_CLANG_TOOLS_VERSION     - LLVM major version to use (e.g. 21). Empty: newest installed.
#   IDICMAKE_LINT_DIRS               - project-relative directories to lint (default: src)
#   IDICMAKE_LINT_DEMOS              - also lint demo/ (cache option, default OFF)
#   IDICMAKE_LINT_EXCLUDES           - project-relative globs to skip (default: *.out.*;src/base/*;src/unit_test_component/*)
#   IDICMAKE_LINT_EXTENSIONS         - file extensions to lint
#   IDICMAKE_LINT_TIDY_GATE_CHECKS   - clang-tidy checks enforced by 'tidy'
#
# The actual work happens in cmake/idi/scripts/lint.cmake, which the targets and the
# cmake/idi/tools/lint.{sh,bat} wrappers both run with the config file written here.
#

include_guard(GLOBAL)

set_property(GLOBAL PROPERTY _IDICMAKE_LINT_SCRIPT "${CMAKE_CURRENT_LIST_DIR}/../scripts/lint.cmake")
set_property(GLOBAL PROPERTY _IDICMAKE_TOOLS_DIR "${CMAKE_CURRENT_LIST_DIR}/../tools")

# Defaults. Set before the project's hooks run, so a hook can append or replace them.
if(NOT DEFINED IDICMAKE_LINT_DIRS)
    set(IDICMAKE_LINT_DIRS src)
endif()
if(NOT DEFINED IDICMAKE_LINT_EXCLUDES)
    set(IDICMAKE_LINT_EXCLUDES "*.out.*" "src/base/*" "src/unit_test_component/*")
endif()
if(NOT DEFINED IDICMAKE_LINT_EXTENSIONS)
    set(IDICMAKE_LINT_EXTENSIONS c cc cpp cxx h hh hpp hxx inl ipp)
endif()
if(NOT DEFINED IDICMAKE_LINT_TIDY_GATE_CHECKS)
    set(IDICMAKE_LINT_TIDY_GATE_CHECKS
        -*
        readability-identifier-naming
        readability-redundant-string-cstr
        readability-container-size-empty
        readability-simplify-boolean-expr
        bugprone-use-after-move
        bugprone-dangling-handle
        bugprone-move-forwarding-reference
        bugprone-string-constructor
        bugprone-unused-return-value
        performance-unnecessary-copy-initialization
        performance-move-const-arg
        performance-inefficient-string-concatenation
        modernize-use-override
        modernize-use-nullptr
        misc-unused-using-decls
    )
endif()
option(IDICMAKE_LINT_DEMOS "Also lint the demo/ folder (format and tidy targets, lint scripts)" OFF)
set(IDICMAKE_CLANG_TOOLS_VERSION "" CACHE STRING "LLVM major version of clang-format/clang-tidy to use for lint targets (empty = newest found)")

# Top-level builds export compile_commands.json so clang-tidy (and editors) can use it.
# Visual Studio generators ignore this; use Ninja for clang-tidy on Windows.
if(NOT DEFINED CMAKE_EXPORT_COMPILE_COMMANDS AND CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE BOOL "Write compile_commands.json (used by clang-tidy)")
endif()

# ---------------------------------------------------------------------------
# Internal: find <tool>-<version> (or the newest versioned one), then the unversioned <tool>.
# ---------------------------------------------------------------------------
function(_idicmake_find_clang_tool OUT_VAR TOOL)
    set(_names "")
    if(IDICMAKE_CLANG_TOOLS_VERSION)
        list(APPEND _names "${TOOL}-${IDICMAKE_CLANG_TOOLS_VERSION}")
    else()
        foreach(_v RANGE 30 14 -1)
            list(APPEND _names "${TOOL}-${_v}")
        endforeach()
    endif()
    list(APPEND _names "${TOOL}")
    find_program(${OUT_VAR} NAMES ${_names} DOC "${TOOL} used by the lint targets")
endfunction()

function(_idicmake_tool_major OUT_VAR TOOL_PATH)
    set(${OUT_VAR} "" PARENT_SCOPE)
    if(TOOL_PATH)
        execute_process(COMMAND "${TOOL_PATH}" --version OUTPUT_VARIABLE _out ERROR_QUIET)
        string(REGEX MATCH "version ([0-9]+)" _m "${_out}")
        set(${OUT_VAR} "${CMAKE_MATCH_1}" PARENT_SCOPE)
    endif()
endfunction()

# Quote a value for writing into a generated .cmake file.
function(_idicmake_lint_quote OUT_VAR VALUE)
    set(${OUT_VAR} "[==[${VALUE}]==]" PARENT_SCOPE)
endfunction()

# ---------------------------------------------------------------------------
# idi_lint_setup() — schedules the lint targets for the end of configuration.
# Called by the framework from idi_src(); a no-op when this project is a subproject.
# ---------------------------------------------------------------------------
function(idi_lint_setup)
    if(IDICMAKE_IS_SUBDIRECTORY)
        return()
    endif()
    cmake_language(DEFER DIRECTORY ${CMAKE_SOURCE_DIR} CALL _idicmake_create_lint_targets)
endfunction()

function(_idicmake_create_lint_targets)
    # Re-search the tools when the requested version changes
    if(NOT "${IDICMAKE_CLANG_TOOLS_VERSION}" STREQUAL "${_IDICMAKE_LINT_TOOLS_VERSION_USED}")
        unset(IDICMAKE_CLANG_FORMAT_EXE CACHE)
        unset(IDICMAKE_CLANG_TIDY_EXE CACHE)
        unset(IDICMAKE_RUN_CLANG_TIDY CACHE)
        set(_IDICMAKE_LINT_TOOLS_VERSION_USED "${IDICMAKE_CLANG_TOOLS_VERSION}" CACHE INTERNAL "")
    endif()

    _idicmake_find_clang_tool(IDICMAKE_CLANG_FORMAT_EXE clang-format)
    _idicmake_find_clang_tool(IDICMAKE_CLANG_TIDY_EXE clang-tidy)
    _idicmake_tool_major(_format_major "${IDICMAKE_CLANG_FORMAT_EXE}")
    _idicmake_tool_major(_tidy_major "${IDICMAKE_CLANG_TIDY_EXE}")

    if(IDICMAKE_CLANG_TOOLS_VERSION)
        foreach(_pair "clang-format;${IDICMAKE_CLANG_FORMAT_EXE};${_format_major}" "clang-tidy;${IDICMAKE_CLANG_TIDY_EXE};${_tidy_major}")
            list(GET _pair 0 _name)
            list(GET _pair 1 _path)
            list(GET _pair 2 _major)
            if(_path AND NOT _major STREQUAL IDICMAKE_CLANG_TOOLS_VERSION)
                message(WARNING "[Lint] Requested ${_name} ${IDICMAKE_CLANG_TOOLS_VERSION} but found version '${_major}' (${_path}). "
                    "Different versions can format and diagnose differently from CI.")
            endif()
        endforeach()
    endif()

    # run-clang-tidy (parallel runner) is a Python script; it is optional.
    if(IDICMAKE_CLANG_TIDY_EXE)
        get_filename_component(_tidy_dir "${IDICMAKE_CLANG_TIDY_EXE}" DIRECTORY)
        get_filename_component(_tidy_real "${IDICMAKE_CLANG_TIDY_EXE}" REALPATH)
        get_filename_component(_tidy_real_dir "${_tidy_real}" DIRECTORY)
        find_program(IDICMAKE_RUN_CLANG_TIDY
            NAMES run-clang-tidy-${_tidy_major} run-clang-tidy-${_tidy_major}.py run-clang-tidy run-clang-tidy.py
            HINTS "${_tidy_real_dir}" "${_tidy_dir}" "${_tidy_real_dir}/../share/clang"
            DOC "run-clang-tidy used by the lint targets")
        find_package(Python3 COMPONENTS Interpreter QUIET)
    endif()

    message(STATUS "[Lint] clang-format:   ${IDICMAKE_CLANG_FORMAT_EXE} (${_format_major})")
    message(STATUS "[Lint] clang-tidy:     ${IDICMAKE_CLANG_TIDY_EXE} (${_tidy_major})")
    message(STATUS "[Lint] run-clang-tidy: ${IDICMAKE_RUN_CLANG_TIDY}")
    message(STATUS "[Lint] demos linted:   ${IDICMAKE_LINT_DEMOS} (IDICMAKE_LINT_DEMOS)")

    get_property(_script GLOBAL PROPERTY _IDICMAKE_LINT_SCRIPT)
    get_property(_tools_dir GLOBAL PROPERTY _IDICMAKE_TOOLS_DIR)
    get_filename_component(_tools_dir "${_tools_dir}" ABSOLUTE)

    set(_python "")
    if(Python3_Interpreter_FOUND)
        set(_python "${Python3_EXECUTABLE}")
    endif()

    # Write the config the lint script (and the wrappers / pre-commit hook) read.
    set(_config "${CMAKE_BINARY_DIR}/idi-lint-config.cmake")
    set(_content "# Generated by the IDI CMake framework (idi_lint.cmake). Do not edit.\n")
    foreach(_pair
            "LINT_SOURCE_DIR;${CMAKE_SOURCE_DIR}"
            "LINT_BUILD_DIR;${CMAKE_BINARY_DIR}"
            "LINT_CLANG_FORMAT;${IDICMAKE_CLANG_FORMAT_EXE}"
            "LINT_CLANG_TIDY;${IDICMAKE_CLANG_TIDY_EXE}"
            "LINT_CLANG_TIDY_MAJOR;${_tidy_major}"
            "LINT_RUN_CLANG_TIDY;${IDICMAKE_RUN_CLANG_TIDY}"
            "LINT_PYTHON;${_python}")
        list(GET _pair 0 _key)
        list(LENGTH _pair _len)
        set(_value "")
        if(_len GREATER 1)
            list(GET _pair 1 _value)
        endif()
        if(_value MATCHES "-NOTFOUND$")
            set(_value "")
        endif()
        _idicmake_lint_quote(_q "${_value}")
        string(APPEND _content "set(${_key} ${_q})\n")
    endforeach()
    set(_lint_dirs ${IDICMAKE_LINT_DIRS})
    if(IDICMAKE_LINT_DEMOS AND NOT "demo" IN_LIST _lint_dirs)
        list(APPEND _lint_dirs demo)
    endif()
    _idicmake_lint_quote(_q "${_lint_dirs}")
    string(APPEND _content "set(LINT_DIRS ${_q})\n")
    foreach(_list_var EXCLUDES EXTENSIONS)
        _idicmake_lint_quote(_q "${IDICMAKE_LINT_${_list_var}}")
        string(APPEND _content "set(LINT_${_list_var} ${_q})\n")
    endforeach()
    list(JOIN IDICMAKE_LINT_TIDY_GATE_CHECKS "," _gate)
    _idicmake_lint_quote(_q "${_gate}")
    string(APPEND _content "set(LINT_GATE_CHECKS ${_q})\n")
    file(CONFIGURE OUTPUT "${_config}" CONTENT "${_content}" @ONLY)

    set(_run ${CMAKE_COMMAND} -DLINT_CONFIG=${_config})

    foreach(_name format format-check tidy tidy-report lint install-git-hooks)
        if(TARGET ${_name})
            message(STATUS "[Lint] A '${_name}' target already exists; the framework's '${_name}' target is not added "
                "(use cmake/idi/tools/lint.sh instead).")
        endif()
    endforeach()

    if(NOT TARGET format)
        add_custom_target(format
            COMMAND ${_run} -DMODE=format -P "${_script}"
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR} USES_TERMINAL VERBATIM
            COMMENT "Formatting project sources with clang-format")
    endif()
    if(NOT TARGET format-check)
        add_custom_target(format-check
            COMMAND ${_run} -DMODE=format-check -P "${_script}"
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR} USES_TERMINAL VERBATIM
            COMMENT "Checking project sources with clang-format")
    endif()
    if(NOT TARGET tidy)
        add_custom_target(tidy
            COMMAND ${_run} -DMODE=tidy -P "${_script}"
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR} USES_TERMINAL VERBATIM
            COMMENT "Checking project sources with clang-tidy (gate checks)")
    endif()
    if(NOT TARGET tidy-report)
        add_custom_target(tidy-report
            COMMAND ${_run} -DMODE=tidy-report -P "${_script}"
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR} USES_TERMINAL VERBATIM
            COMMENT "Reporting all .clang-tidy findings (advisory)")
    endif()
    if(NOT TARGET lint)
        add_custom_target(lint
            COMMAND ${_run} -DMODE=lint -P "${_script}"
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR} USES_TERMINAL VERBATIM
            COMMENT "Running clang-format check and clang-tidy gate")
    endif()
    if(NOT TARGET install-git-hooks)
        add_custom_target(install-git-hooks
            COMMAND ${_run} -DMODE=install-hook "-DHOOK_SOURCE=${_tools_dir}/pre-commit" -P "${_script}"
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR} VERBATIM
            COMMENT "Installing the IDI pre-commit hook")
    endif()
endfunction()
