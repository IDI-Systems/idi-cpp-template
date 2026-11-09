#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2025 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#
# Script mode lint runner used by the lint targets, cmake/idi/tools/lint.{sh,bat} and the pre-commit hook.
#
#   cmake -DLINT_CONFIG=<build>/idi-lint-config.cmake -DMODE=<mode> [-DFILES=<a;b;...>] -P lint.cmake
#
# Modes:
#   format        clang-format -i on the files
#   format-check  fail if any file is not formatted
#   tidy          clang-tidy gate checks, fail on any finding
#   tidy-report   clang-tidy with the .clang-tidy check list, report only
#   lint          format-check + tidy
#   install-hook  install the pre-commit hook (HOOK_SOURCE = path of cmake/idi/tools/pre-commit)
#
# Without LINT_CONFIG (pre-commit hook before any configure), pass -DLINT_SOURCE_DIR=<project root>;
# defaults are used and only the format modes work. LINT_SOFT_MISSING_TOOLS=ON turns a missing
# clang-format into a warning instead of an error. The CLANG_FORMAT / CLANG_TIDY environment
# variables override the configured tools.
#

cmake_minimum_required(VERSION 3.26)

if(LINT_CONFIG)
    if(NOT EXISTS "${LINT_CONFIG}")
        message(FATAL_ERROR "[Lint] Config file not found: ${LINT_CONFIG}. Configure the project first.")
    endif()
    include("${LINT_CONFIG}")
endif()

if(NOT LINT_SOURCE_DIR)
    message(FATAL_ERROR "[Lint] Pass -DLINT_CONFIG=<build>/idi-lint-config.cmake or -DLINT_SOURCE_DIR=<project root>")
endif()
file(TO_CMAKE_PATH "${LINT_SOURCE_DIR}" LINT_SOURCE_DIR)

if(NOT DEFINED LINT_DIRS)
    set(LINT_DIRS src)
endif()
if(NOT DEFINED LINT_EXCLUDES)
    set(LINT_EXCLUDES "*.out.*" "src/base/*" "src/unit_test_component/*")
endif()
if(NOT DEFINED LINT_EXTENSIONS)
    set(LINT_EXTENSIONS c cc cpp cxx h hh hpp hxx inl ipp)
endif()
set(_source_extensions c cc cpp cxx)

if(DEFINED ENV{CLANG_FORMAT} AND NOT "$ENV{CLANG_FORMAT}" STREQUAL "")
    set(LINT_CLANG_FORMAT "$ENV{CLANG_FORMAT}")
endif()
if(DEFINED ENV{CLANG_TIDY} AND NOT "$ENV{CLANG_TIDY}" STREQUAL "")
    set(LINT_CLANG_TIDY "$ENV{CLANG_TIDY}")
endif()
if(NOT LINT_CLANG_FORMAT)
    find_program(_found_clang_format NAMES clang-format)
    if(_found_clang_format)
        set(LINT_CLANG_FORMAT "${_found_clang_format}")
    endif()
endif()

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Escape a string for use inside a POSIX ERE / Python regex.
function(_lint_regex_escape OUT_VAR VALUE)
    string(REGEX REPLACE "([][.^$*+?(){}|\\\\])" "\\\\\\1" _escaped "${VALUE}")
    set(${OUT_VAR} "${_escaped}" PARENT_SCOPE)
endfunction()

# Project-relative glob -> anchored regex for a project-relative path.
function(_lint_glob_to_regex OUT_VAR GLOB)
    _lint_regex_escape(_r "${GLOB}")
    string(REPLACE "\\*" ".*" _r "${_r}")
    set(${OUT_VAR} "^${_r}$" PARENT_SCOPE)
endfunction()

set(_exclude_regexes "")
foreach(_glob IN LISTS LINT_EXCLUDES)
    _lint_glob_to_regex(_r "${_glob}")
    list(APPEND _exclude_regexes "${_r}")
endforeach()

# Keep a project-relative path if it is in a lint dir, has a lint extension and is not excluded.
function(_lint_accept OUT_VAR REL)
    set(${OUT_VAR} FALSE PARENT_SCOPE)
    set(_in_dir FALSE)
    foreach(_dir IN LISTS LINT_DIRS)
        string(FIND "${REL}" "${_dir}/" _pos)
        if(_pos EQUAL 0)
            set(_in_dir TRUE)
        endif()
    endforeach()
    if(NOT _in_dir)
        return()
    endif()
    get_filename_component(_ext "${REL}" LAST_EXT)
    string(SUBSTRING "${_ext}" 1 -1 _ext)
    string(TOLOWER "${_ext}" _ext)
    if(NOT _ext IN_LIST LINT_EXTENSIONS)
        return()
    endif()
    foreach(_r IN LISTS _exclude_regexes)
        if(REL MATCHES "${_r}")
            return()
        endif()
    endforeach()
    set(${OUT_VAR} TRUE PARENT_SCOPE)
endfunction()

# Absolute or relative path -> project-relative path ("" if outside the project).
function(_lint_relative OUT_VAR PATH)
    file(TO_CMAKE_PATH "${PATH}" _p)
    if(NOT IS_ABSOLUTE "${_p}")
        set(_p "${LINT_SOURCE_DIR}/${_p}")
    endif()
    file(RELATIVE_PATH _rel "${LINT_SOURCE_DIR}" "${_p}")
    if(_rel MATCHES "^\\.\\./" OR IS_ABSOLUTE "${_rel}")
        set(_rel "")
    endif()
    set(${OUT_VAR} "${_rel}" PARENT_SCOPE)
endfunction()

# All project files to lint (project-relative, sorted).
function(_lint_all_files OUT_VAR)
    set(_files "")
    foreach(_dir IN LISTS LINT_DIRS)
        if(NOT IS_DIRECTORY "${LINT_SOURCE_DIR}/${_dir}")
            continue()
        endif()
        foreach(_ext IN LISTS LINT_EXTENSIONS)
            file(GLOB_RECURSE _found RELATIVE "${LINT_SOURCE_DIR}" "${LINT_SOURCE_DIR}/${_dir}/*.${_ext}")
            list(APPEND _files ${_found})
        endforeach()
    endforeach()
    set(_kept "")
    foreach(_f IN LISTS _files)
        _lint_accept(_ok "${_f}")
        if(_ok)
            list(APPEND _kept "${_f}")
        endif()
    endforeach()
    list(REMOVE_DUPLICATES _kept)
    list(SORT _kept)
    set(${OUT_VAR} "${_kept}" PARENT_SCOPE)
endfunction()

# Files passed with -DFILES=..., filtered the same way (missing files are dropped).
function(_lint_explicit_files OUT_VAR)
    set(_kept "")
    foreach(_f IN LISTS FILES)
        _lint_relative(_rel "${_f}")
        if(_rel AND EXISTS "${LINT_SOURCE_DIR}/${_rel}")
            _lint_accept(_ok "${_rel}")
            if(_ok)
                list(APPEND _kept "${_rel}")
            endif()
        endif()
    endforeach()
    list(REMOVE_DUPLICATES _kept)
    set(${OUT_VAR} "${_kept}" PARENT_SCOPE)
endfunction()

function(_lint_is_source OUT_VAR REL)
    get_filename_component(_ext "${REL}" LAST_EXT)
    string(SUBSTRING "${_ext}" 1 -1 _ext)
    string(TOLOWER "${_ext}" _ext)
    if(_ext IN_LIST _source_extensions)
        set(${OUT_VAR} TRUE PARENT_SCOPE)
    else()
        set(${OUT_VAR} FALSE PARENT_SCOPE)
    endif()
endfunction()

function(_lint_require_tool VAR NAME)
    if(NOT ${VAR})
        if(LINT_SOFT_MISSING_TOOLS)
            message(WARNING "[Lint] ${NAME} not found; skipping the check. Set the ${NAME} path with the "
                "environment variable or install it.")
            set(_LINT_SKIP TRUE PARENT_SCOPE)
            return()
        endif()
        message(FATAL_ERROR "[Lint] ${NAME} not found. Install it (e.g. apt install ${NAME}-<version>, or the LLVM "
            "installer on Windows) and re-configure, or set IDICMAKE_CLANG_TOOLS_VERSION / the ${NAME} environment variable.")
    endif()
endfunction()

# The files this run works on: explicit FILES or everything.
function(_lint_target_files OUT_VAR)
    if(DEFINED FILES AND NOT FILES STREQUAL "")
        _lint_explicit_files(_files)
    else()
        _lint_all_files(_files)
    endif()
    set(${OUT_VAR} "${_files}" PARENT_SCOPE)
endfunction()

# ---------------------------------------------------------------------------
# clang-format
# ---------------------------------------------------------------------------
# Sets FORMAT_FAILED in the caller.
function(_lint_format MODE)
    set(FORMAT_FAILED FALSE PARENT_SCOPE)
    set(_LINT_SKIP FALSE)
    _lint_require_tool(LINT_CLANG_FORMAT clang-format)
    if(_LINT_SKIP)
        return()
    endif()

    _lint_target_files(_files)
    list(LENGTH _files _count)
    if(_count EQUAL 0)
        message(NOTICE "=== clang-format: no files to check ===")
        return()
    endif()

    execute_process(COMMAND "${LINT_CLANG_FORMAT}" --version OUTPUT_VARIABLE _ver OUTPUT_STRIP_TRAILING_WHITESPACE)

    if(MODE STREQUAL "format")
        message(NOTICE "=== clang-format: formatting ${_count} file(s) (${_ver}) ===")
        set(_args -i --style=file)
    else()
        message(NOTICE "=== clang-format: checking ${_count} file(s) (${_ver}) ===")
        set(_args --dry-run --Werror --style=file)
    endif()

    # Run in chunks to stay under command line length limits (Windows).
    set(_failures "")
    set(_chunk "")
    set(_n 0)
    list(APPEND _files "<end>")
    foreach(_f IN LISTS _files)
        if(NOT _f STREQUAL "<end>")
            list(APPEND _chunk "${_f}")
            math(EXPR _n "${_n} + 1")
        endif()
        if(_chunk AND (_n EQUAL 50 OR _f STREQUAL "<end>"))
            execute_process(
                COMMAND "${LINT_CLANG_FORMAT}" ${_args} ${_chunk}
                WORKING_DIRECTORY "${LINT_SOURCE_DIR}"
                RESULT_VARIABLE _rc
                OUTPUT_VARIABLE _out
                ERROR_VARIABLE _err)
            if(NOT _rc EQUAL 0)
                # "<file>:<line>:<col>: error: code should be clang-formatted"
                string(REGEX MATCHALL "[^\n]+:[0-9]+:[0-9]+: (error|warning): code should be clang-formatted" _hits "${_err}")
                set(_chunk_failures "")
                foreach(_hit IN LISTS _hits)
                    string(REGEX REPLACE ":[0-9]+:[0-9]+: (error|warning): code should be clang-formatted$" "" _file "${_hit}")
                    list(APPEND _chunk_failures "${_file}")
                endforeach()
                if(NOT _chunk_failures)
                    message(FATAL_ERROR "[Lint] clang-format failed:\n${_err}${_out}")
                endif()
                list(APPEND _failures ${_chunk_failures})
            endif()
            set(_chunk "")
            set(_n 0)
        endif()
    endforeach()

    if(MODE STREQUAL "format")
        message(NOTICE "Done.")
        return()
    endif()

    list(REMOVE_DUPLICATES _failures)
    list(LENGTH _failures _fail_count)
    if(_fail_count EQUAL 0)
        message(NOTICE "PASS - all files are correctly formatted.")
    else()
        message(NOTICE "FAIL - ${_fail_count} file(s) need formatting:")
        foreach(_f IN LISTS _failures)
            message(NOTICE "  ${_f}")
        endforeach()
        message(NOTICE "Fix with: cmake --build <build-dir> --target format   (or cmake/idi/tools/lint.sh --fix)")
        set(FORMAT_FAILED TRUE PARENT_SCOPE)
    endif()
endfunction()

# ---------------------------------------------------------------------------
# clang-tidy
# ---------------------------------------------------------------------------
# Source files in compile_commands.json that belong to the project (project-relative).
function(_lint_compile_db_files OUT_VAR)
    set(_db "${LINT_BUILD_DIR}/compile_commands.json")
    if(NOT EXISTS "${_db}")
        message(FATAL_ERROR "[Lint] ${_db} not found. clang-tidy needs a compile database: configure with a Makefile or "
            "Ninja generator (Visual Studio generators do not write one) and CMAKE_EXPORT_COMPILE_COMMANDS=ON.")
    endif()
    file(STRINGS "${_db}" _lines REGEX "^[ \t]*\"file\"[ \t]*:")
    set(_files "")
    foreach(_line IN LISTS _lines)
        string(REGEX REPLACE "^[ \t]*\"file\"[ \t]*:[ \t]*\"(.*)\"[ \t]*,?[ \t]*$" "\\1" _path "${_line}")
        string(REPLACE "\\\\" "/" _path "${_path}")
        _lint_relative(_rel "${_path}")
        if(_rel)
            _lint_accept(_ok "${_rel}")
            if(_ok)
                list(APPEND _files "${_rel}")
            endif()
        endif()
    endforeach()
    list(REMOVE_DUPLICATES _files)
    list(SORT _files)
    set(${OUT_VAR} "${_files}" PARENT_SCOPE)
endfunction()

# Sets TIDY_FAILED in the caller. MODE is tidy (gate) or tidy-report.
function(_lint_tidy MODE)
    set(TIDY_FAILED FALSE PARENT_SCOPE)
    if(NOT LINT_BUILD_DIR)
        message(FATAL_ERROR "[Lint] clang-tidy needs a configured build: pass -DLINT_CONFIG=<build>/idi-lint-config.cmake")
    endif()
    set(_LINT_SKIP FALSE)
    _lint_require_tool(LINT_CLANG_TIDY clang-tidy)
    if(_LINT_SKIP)
        return()
    endif()

    _lint_compile_db_files(_db_files)

    # Explicit files: check the given sources. Headers are checked through the sources that include them,
    # so a header-only change checks everything.
    set(_files "${_db_files}")
    if(DEFINED FILES AND NOT FILES STREQUAL "")
        _lint_explicit_files(_explicit)
        set(_sources "")
        set(_has_header FALSE)
        foreach(_f IN LISTS _explicit)
            _lint_is_source(_is_src "${_f}")
            if(_is_src)
                if(_f IN_LIST _db_files)
                    list(APPEND _sources "${_f}")
                else()
                    message(NOTICE "[Lint] ${_f} is not in compile_commands.json; skipping it for clang-tidy.")
                endif()
            else()
                set(_has_header TRUE)
            endif()
        endforeach()
        if(_sources)
            set(_files "${_sources}")
        elseif(NOT _has_header)
            set(_files "")
        endif()
    endif()

    list(LENGTH _files _count)
    if(_count EQUAL 0)
        message(NOTICE "=== clang-tidy: no source files to check ===")
        return()
    endif()

    # Only report diagnostics from the project's own lint dirs; drop excluded paths (clang-tidy >= 19).
    _lint_regex_escape(_root "${LINT_SOURCE_DIR}")
    string(REPLACE "/" "[/\\\\]" _root "${_root}")
    list(JOIN LINT_DIRS "|" _dirs)
    set(_header_filter "^${_root}[/\\\\](${_dirs})[/\\\\]")
    set(_exclude_parts "")
    foreach(_glob IN LISTS LINT_EXCLUDES)
        _lint_regex_escape(_r "${_glob}")
        string(REPLACE "\\*" ".*" _r "${_r}")
        string(REPLACE "/" "[/\\\\]" _r "${_r}")
        if(_glob MATCHES "^\\*")
            list(APPEND _exclude_parts "${_r}$")
        else()
            list(APPEND _exclude_parts "^${_root}[/\\\\]${_r}$")
        endif()
    endforeach()
    list(JOIN _exclude_parts "|" _exclude_filter)

    set(_common_args "")
    if(MODE STREQUAL "tidy")
        list(APPEND _common_args "-checks=${LINT_GATE_CHECKS}" "-warnings-as-errors=*")
        message(NOTICE "=== clang-tidy: checking ${_count} file(s) with the gate checks ===")
    else()
        message(NOTICE "=== clang-tidy: reporting on ${_count} file(s) with the .clang-tidy checks (advisory) ===")
    endif()
    # Compile databases from GCC builds can hold GCC-only warning flags that clang does not know.
    list(APPEND _common_args "-extra-arg=-Wno-unknown-warning-option" "-header-filter=${_header_filter}")
    if(_exclude_filter AND LINT_CLANG_TIDY_MAJOR AND LINT_CLANG_TIDY_MAJOR GREATER_EQUAL 19)
        list(APPEND _common_args "-exclude-header-filter=${_exclude_filter}")
    endif()

    set(_output "")
    set(_failed FALSE)
    if(LINT_RUN_CLANG_TIDY AND LINT_PYTHON)
        # run-clang-tidy takes regexes of absolute paths; run in chunks to bound the command line.
        set(_chunk "")
        set(_n 0)
        list(APPEND _files "<end>")
        foreach(_f IN LISTS _files)
            if(NOT _f STREQUAL "<end>")
                _lint_regex_escape(_abs "${LINT_SOURCE_DIR}/${_f}")
                list(APPEND _chunk "^${_abs}$")
                math(EXPR _n "${_n} + 1")
            endif()
            if(_chunk AND (_n EQUAL 100 OR _f STREQUAL "<end>"))
                execute_process(
                    COMMAND "${LINT_PYTHON}" "${LINT_RUN_CLANG_TIDY}" -clang-tidy-binary "${LINT_CLANG_TIDY}"
                        -p "${LINT_BUILD_DIR}" -quiet ${_common_args} ${_chunk}
                    WORKING_DIRECTORY "${LINT_SOURCE_DIR}"
                    RESULT_VARIABLE _rc
                    OUTPUT_VARIABLE _out
                    ERROR_VARIABLE _err)
                string(APPEND _output "${_out}\n${_err}\n")
                if(NOT _rc EQUAL 0)
                    set(_failed TRUE)
                endif()
                set(_chunk "")
                set(_n 0)
            endif()
        endforeach()
    else()
        message(NOTICE "(run-clang-tidy or Python not found: running clang-tidy one file at a time)")
        foreach(_f IN LISTS _files)
            execute_process(
                COMMAND "${LINT_CLANG_TIDY}" -p "${LINT_BUILD_DIR}" --quiet ${_common_args} "${LINT_SOURCE_DIR}/${_f}"
                WORKING_DIRECTORY "${LINT_SOURCE_DIR}"
                RESULT_VARIABLE _rc
                OUTPUT_VARIABLE _out
                ERROR_VARIABLE _err)
            string(APPEND _output "${_out}\n${_err}\n")
            if(NOT _rc EQUAL 0)
                set(_failed TRUE)
            endif()
        endforeach()
    endif()

    # Drop runner noise, keep diagnostics and their code snippets.
    string(REPLACE "\r" "" _output "${_output}")
    string(REPLACE ";" "\\;" _output "${_output}")
    string(REPLACE "\n" ";" _lines "${_output}")
    set(_report "")
    set(_findings 0)
    set(_compile_errors FALSE)
    foreach(_line IN LISTS _lines)
        if(_line STREQUAL ""
                OR _line MATCHES "^[^ ]*clang-tidy[^ ]* -"
                OR _line MATCHES "^Running clang-tidy"
                OR _line MATCHES "^[0-9]+ (warnings?|errors?)( and [0-9]+ (warnings?|errors?))? generated\\.?$"
                OR _line MATCHES "^Suppressed [0-9]+ warnings"
                OR _line MATCHES "^Use -header-filter"
                OR _line MATCHES "^Error while processing"
                OR _line MATCHES "^Found compiler error"
                OR _line MATCHES "^\\[ *[0-9]+/[0-9]+\\]")
            continue()
        endif()
        if(_line MATCHES ": (warning|error): .*\\[[a-zA-Z0-9.,-]+\\]$")
            math(EXPR _findings "${_findings} + 1")
            if(_line MATCHES "\\[clang-diagnostic-error\\]$")
                set(_compile_errors TRUE)
            endif()
        endif()
        if(LINT_SOURCE_DIR)
            string(REPLACE "${LINT_SOURCE_DIR}/" "" _line "${_line}")
        endif()
        string(APPEND _report "${_line}\n")
    endforeach()

    if(MODE STREQUAL "tidy-report")
        if(_report)
            message(NOTICE "${_report}")
        endif()
        message(NOTICE "REPORT - ${_findings} finding(s) (advisory, does not fail).")
        return()
    endif()

    if(NOT _failed AND _findings EQUAL 0)
        message(NOTICE "PASS - all clang-tidy gate checks are clean.")
        return()
    endif()

    if(_report)
        message(NOTICE "${_report}")
    endif()
    if(_compile_errors)
        message(NOTICE "NOTE - some files failed to compile under clang-tidy. Build the project first so generated "
            "sources exist, and check that compile_commands.json matches the current sources.")
    endif()
    if(_findings EQUAL 0)
        message(NOTICE "FAIL - clang-tidy exited with an error (see output above).")
    else()
        message(NOTICE "FAIL - ${_findings} clang-tidy finding(s).")
    endif()
    set(TIDY_FAILED TRUE PARENT_SCOPE)
endfunction()

# ---------------------------------------------------------------------------
# pre-commit hook install
# ---------------------------------------------------------------------------
function(_lint_install_hook)
    if(NOT HOOK_SOURCE OR NOT EXISTS "${HOOK_SOURCE}")
        message(FATAL_ERROR "[Lint] Hook script not found: ${HOOK_SOURCE}")
    endif()
    find_program(_git git)
    if(NOT _git)
        message(FATAL_ERROR "[Lint] git not found")
    endif()
    execute_process(COMMAND "${_git}" rev-parse --show-toplevel
        WORKING_DIRECTORY "${LINT_SOURCE_DIR}" RESULT_VARIABLE _rc OUTPUT_VARIABLE _top OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET)
    if(NOT _rc EQUAL 0)
        message(FATAL_ERROR "[Lint] ${LINT_SOURCE_DIR} is not in a git repository")
    endif()
    execute_process(COMMAND "${_git}" rev-parse --git-path hooks
        WORKING_DIRECTORY "${LINT_SOURCE_DIR}" OUTPUT_VARIABLE _hooks OUTPUT_STRIP_TRAILING_WHITESPACE)
    file(TO_CMAKE_PATH "${_top}" _top)
    file(TO_CMAKE_PATH "${_hooks}" _hooks)
    if(NOT IS_ABSOLUTE "${_hooks}")
        set(_hooks "${LINT_SOURCE_DIR}/${_hooks}")
    endif()
    set(_dest "${_hooks}/pre-commit")
    set(_marker "idi-cmake pre-commit hook")

    if(EXISTS "${_dest}")
        file(READ "${_dest}" _existing)
        string(FIND "${_existing}" "${_marker}" _pos)
        if(_pos EQUAL -1)
            message(FATAL_ERROR "[Lint] ${_dest} already exists and was not installed by this target. "
                "Remove it, or call cmake/idi/tools/pre-commit from it yourself.")
        endif()
    endif()

    # A small shim that runs the hook from the repository, so framework updates reach it.
    file(RELATIVE_PATH _rel_hook "${_top}" "${HOOK_SOURCE}")
    file(MAKE_DIRECTORY "${_hooks}")
    file(WRITE "${_dest}" "#!/usr/bin/env bash
# ${_marker} (installed by the install-git-hooks target; safe to delete)
# Checks clang-format on staged C/C++ files. Skip once with: git commit --no-verify
hook=\"$(git rev-parse --show-toplevel)/${_rel_hook}\"
if [ -f \"$hook\" ]; then
    exec bash \"$hook\" \"$@\"
fi
echo \"pre-commit: $hook not found, skipping the format check\" >&2
exit 0
")
    file(CHMOD "${_dest}" PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
    message(NOTICE "Installed pre-commit hook: ${_dest}")
    message(NOTICE "It checks clang-format on staged files under: ${LINT_DIRS}")
endfunction()

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
if(MODE STREQUAL "format" OR MODE STREQUAL "format-check")
    _lint_format(${MODE})
    if(FORMAT_FAILED)
        message(FATAL_ERROR "clang-format check failed")
    endif()
elseif(MODE STREQUAL "tidy" OR MODE STREQUAL "tidy-report")
    _lint_tidy(${MODE})
    if(TIDY_FAILED)
        message(FATAL_ERROR "clang-tidy check failed")
    endif()
elseif(MODE STREQUAL "lint")
    _lint_format(format-check)
    message(NOTICE "")
    _lint_tidy(tidy)
    message(NOTICE "")
    if(FORMAT_FAILED OR TIDY_FAILED)
        message(FATAL_ERROR "Lint failed (format: ${FORMAT_FAILED}, tidy: ${TIDY_FAILED})")
    endif()
    message(NOTICE "All lint checks passed.")
elseif(MODE STREQUAL "install-hook")
    _lint_install_hook()
else()
    message(FATAL_ERROR "[Lint] Unknown MODE '${MODE}' (format, format-check, tidy, tidy-report, lint, install-hook)")
endif()
