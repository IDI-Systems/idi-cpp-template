#
# Code Coverage Module for the IDI CMake Framework
#
# Provides functions to instrument build targets with code coverage flags
# and generate coverage reports using gcov with lcov/genhtml or gcovr.
#
# Functions:
#   target_code_coverage(<target> [ALL] [OBJECTS <targets...>] [EXCLUDE <patterns...>])
#   add_code_coverage_all_targets([EXCLUDE <patterns...>])
#
# Variables (set with -D, or in a cmake hook):
#   CODE_COVERAGE                 - Enable code coverage instrumentation (default: OFF)
#   IDICMAKE_COVERAGE_FAIL_UNDER  - Fail ccov-all / ccov-all-xml when line coverage is below this percent (default: unset)
#   IDICMAKE_COVERAGE_CTEST_ARGS  - Extra arguments for the ctest run (e.g. --timeout;120)
#
# Custom Build Targets (created when CODE_COVERAGE=ON):
#   ccov-all       - Reset counters, run every ctest test, then write the HTML report (+ Cobertura XML if gcovr
#                    is found) and print "Code Coverage: NN.NN%"
#   ccov-all-xml   - Same test run, Cobertura XML only (requires gcovr, for CI)
#   ccov-clean     - Remove generated coverage data and reports
#
# Report output directory: ${CMAKE_BINARY_DIR}/reports/coverage/
#
# Exclude patterns are globs. Absolute patterns and patterns starting with '*' are used as is;
# any other pattern is taken relative to the project root (e.g. "protobuf/*" -> "<root>/protobuf/*").
#
# Supported compilers: GCC (gcov-<major>), Clang (llvm-cov-<major> gcov)
# Supported report tools: lcov + genhtml, gcovr (at least one recommended)
#

include_guard(GLOBAL)

# CODE_COVERAGE is intentionally NOT an option() so it must be explicitly passed: cmake .. -DCODE_COVERAGE=ON
if(NOT DEFINED CODE_COVERAGE)
    set(CODE_COVERAGE OFF)
endif()

# Force Debug build type for accurate coverage results
if(CODE_COVERAGE)
    if(NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
        message(STATUS "[Coverage] CODE_COVERAGE is ON — forcing CMAKE_BUILD_TYPE to Debug (was: '${CMAKE_BUILD_TYPE}')")
        set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build type forced to Debug for coverage" FORCE)
    endif()
    message(STATUS "[Coverage] *** CODE COVERAGE BUILD ENABLED — Debug mode, no optimizations (-O0 -g) ***")
endif()

# --- Internal global properties for tracking coverage state ---

define_property(GLOBAL PROPERTY IDICMAKE_COVERAGE_TARGETS
    BRIEF_DOCS "Test targets registered for coverage"
    FULL_DOCS "List of test executable targets registered for aggregate coverage reporting"
)
set_property(GLOBAL PROPERTY IDICMAKE_COVERAGE_TARGETS "")

define_property(GLOBAL PROPERTY IDICMAKE_COVERAGE_EXCLUDES
    BRIEF_DOCS "Coverage exclude patterns"
    FULL_DOCS "Glob patterns for files to exclude from coverage reports"
)
set_property(GLOBAL PROPERTY IDICMAKE_COVERAGE_EXCLUDES "")

set_property(GLOBAL PROPERTY _IDICMAKE_COVERAGE_ALL_SCHEDULED FALSE)
set_property(GLOBAL PROPERTY _IDICMAKE_COVERAGE_SCRIPT "${CMAKE_CURRENT_LIST_DIR}/../scripts/coverage-summary.cmake")

# ---------------------------------------------------------------------------
# Internal: make a relative exclude glob absolute (relative to the project root).
# ---------------------------------------------------------------------------
function(_idicmake_coverage_normalize_pattern OUT_VAR PATTERN)
    if(IS_ABSOLUTE "${PATTERN}" OR PATTERN MATCHES "^\\*")
        set(${OUT_VAR} "${PATTERN}" PARENT_SCOPE)
    else()
        set(${OUT_VAR} "${PROJECT_SOURCE_DIR}/${PATTERN}" PARENT_SCOPE)
    endif()
endfunction()

function(_idicmake_coverage_add_excludes)
    foreach(_pattern IN LISTS ARGN)
        _idicmake_coverage_normalize_pattern(_abs "${_pattern}")
        set_property(GLOBAL APPEND PROPERTY IDICMAKE_COVERAGE_EXCLUDES "${_abs}")
    endforeach()
endfunction()

# ---------------------------------------------------------------------------
# target_code_coverage(<target> [ALL] [OBJECTS <targets...>] [EXCLUDE <patterns...>])
#
# Instruments a target with code coverage compile and link flags.
#
# Arguments:
#   <target>  - The CMake target to instrument
#   ALL       - Register this executable target for the aggregate 'ccov-all' report
#   OBJECTS   - Additional library/object targets to also instrument for coverage
#   EXCLUDE   - File patterns to exclude from the coverage reports
#
# Behavior by target type:
#   OBJECT_LIBRARY / STATIC_LIBRARY : adds --coverage compile flag
#   EXECUTABLE / SHARED_LIBRARY     : adds --coverage compile and link flags
#   INTERFACE_LIBRARY               : no-op
# ---------------------------------------------------------------------------
function(target_code_coverage TARGET_NAME)
    if(NOT CODE_COVERAGE)
        return()
    endif()

    # Only supported on GCC and Clang
    if(NOT (CMAKE_C_COMPILER_ID MATCHES "GNU|Clang" OR CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang"))
        return()
    endif()

    set(_options ALL)
    set(_multi OBJECTS EXCLUDE)
    cmake_parse_arguments(COV "${_options}" "" "${_multi}" ${ARGN})

    if(NOT TARGET ${TARGET_NAME})
        message(WARNING "[Coverage] Target '${TARGET_NAME}' does not exist. Skipping.")
        return()
    endif()

    get_target_property(_target_type ${TARGET_NAME} TYPE)

    if(_target_type STREQUAL "INTERFACE_LIBRARY")
        return()
    endif()

    target_compile_options(${TARGET_NAME} PRIVATE --coverage)

    if(_target_type STREQUAL "EXECUTABLE" OR _target_type STREQUAL "SHARED_LIBRARY")
        target_link_options(${TARGET_NAME} PRIVATE --coverage)
    endif()

    # Also instrument OBJECTS targets (idempotent; duplicate flags are harmless)
    foreach(_obj_target ${COV_OBJECTS})
        if(TARGET ${_obj_target})
            get_target_property(_obj_type ${_obj_target} TYPE)
            if(NOT _obj_type STREQUAL "INTERFACE_LIBRARY")
                target_compile_options(${_obj_target} PRIVATE --coverage)
                if(_obj_type STREQUAL "EXECUTABLE" OR _obj_type STREQUAL "SHARED_LIBRARY")
                    target_link_options(${_obj_target} PRIVATE --coverage)
                endif()
            endif()
        endif()
    endforeach()

    if(COV_ALL AND _target_type STREQUAL "EXECUTABLE")
        set_property(GLOBAL APPEND PROPERTY IDICMAKE_COVERAGE_TARGETS ${TARGET_NAME})
    endif()

    _idicmake_coverage_add_excludes(${COV_EXCLUDE})
endfunction()

# ---------------------------------------------------------------------------
# add_code_coverage_all_targets([EXCLUDE <patterns...>])
#
# Schedules creation of aggregate coverage targets. The actual target creation
# is deferred to the end of root directory processing so that all
# target_code_coverage(ALL) registrations have been processed.
# ---------------------------------------------------------------------------
function(add_code_coverage_all_targets)
    if(NOT CODE_COVERAGE)
        return()
    endif()

    set(_multi EXCLUDE)
    cmake_parse_arguments(COV "" "" "${_multi}" ${ARGN})

    _idicmake_coverage_add_excludes(${COV_EXCLUDE})

    # Schedule deferred target creation (once only)
    get_property(_scheduled GLOBAL PROPERTY _IDICMAKE_COVERAGE_ALL_SCHEDULED)
    if(NOT _scheduled)
        set_property(GLOBAL PROPERTY _IDICMAKE_COVERAGE_ALL_SCHEDULED TRUE)
        cmake_language(DEFER DIRECTORY ${CMAKE_SOURCE_DIR} CALL _idicmake_create_coverage_targets)
    endif()
endfunction()

# ---------------------------------------------------------------------------
# Internal helper: convert a glob pattern to a regex for gcovr's --exclude.
# ---------------------------------------------------------------------------
function(_idicmake_glob_to_regex OUT_VAR GLOB_PATTERN)
    string(REGEX REPLACE "([][.+?^$(){}|\\\\])" "\\\\\\1" _regex "${GLOB_PATTERN}")
    string(REPLACE "*" ".*" _regex "${_regex}")
    set(${OUT_VAR} "${_regex}" PARENT_SCOPE)
endfunction()

# ---------------------------------------------------------------------------
# Internal: find the gcov tool that matches the compiler.
#   GCC N needs gcov-N; Clang needs "llvm-cov gcov" from the same LLVM version.
# Sets _gcov_tool (single executable, for lcov) and _gcovr_gcov (string for gcovr) in the caller.
# ---------------------------------------------------------------------------
function(_idicmake_find_gcov_tool)
    string(REGEX MATCH "^[0-9]+" _major "${CMAKE_CXX_COMPILER_VERSION}")
    get_filename_component(_compiler_dir "${CMAKE_CXX_COMPILER}" DIRECTORY)

    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        find_program(IDICMAKE_LLVM_COV_PATH NAMES llvm-cov-${_major} llvm-cov HINTS "${_compiler_dir}")
        if(IDICMAKE_LLVM_COV_PATH)
            if(WIN32)
                # lcov is not used on Windows; gcovr accepts a command with arguments.
                set(_gcov_tool "" PARENT_SCOPE)
                set(_gcovr_gcov "${IDICMAKE_LLVM_COV_PATH} gcov" PARENT_SCOPE)
            else()
                # lcov's --gcov-tool takes a single executable, so wrap "llvm-cov gcov" in a script.
                set(_wrapper "${CMAKE_BINARY_DIR}/coverage/llvm-gcov.sh")
                file(WRITE "${_wrapper}" "#!/bin/sh\nexec \"${IDICMAKE_LLVM_COV_PATH}\" gcov \"$@\"\n")
                file(CHMOD "${_wrapper}" PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
                set(_gcov_tool "${_wrapper}" PARENT_SCOPE)
                set(_gcovr_gcov "${_wrapper}" PARENT_SCOPE)
            endif()
            return()
        endif()
        message(WARNING "[Coverage] Clang compiler but llvm-cov not found; falling back to gcov, which may not read Clang's coverage files.")
    endif()

    find_program(GCOV_PATH NAMES gcov-${_major} gcov HINTS "${_compiler_dir}")
    set(_gcov_tool "${GCOV_PATH}" PARENT_SCOPE)
    set(_gcovr_gcov "${GCOV_PATH}" PARENT_SCOPE)
endfunction()

# ---------------------------------------------------------------------------
# Internal: Deferred creation of aggregate coverage targets.
# Runs at the end of root directory processing after all targets are registered.
# ---------------------------------------------------------------------------
function(_idicmake_create_coverage_targets)
    if(NOT (CMAKE_C_COMPILER_ID MATCHES "GNU|Clang" OR CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang"))
        message(WARNING "[Coverage] Code coverage requires GCC or Clang (found: ${CMAKE_CXX_COMPILER_ID}). Coverage targets not created.")
        return()
    endif()

    _idicmake_find_gcov_tool()
    find_program(LCOV_PATH lcov)
    find_program(GENHTML_PATH genhtml)
    find_program(GCOVR_PATH gcovr)

    if(NOT _gcovr_gcov)
        message(WARNING "[Coverage] gcov not found! Coverage report targets will not be created.")
        return()
    endif()

    # lcov needs a single gcov executable (no Windows "llvm-cov gcov" string form)
    if(NOT _gcov_tool)
        set(LCOV_PATH "")
    endif()

    # lcov 2.x reports problems that 1.x ignored and needs them suppressed explicitly; 1.x rejects these names.
    set(_lcov_capture_ignore "")
    set(_lcov_remove_ignore "")
    set(_lcov_rc "")
    if(LCOV_PATH)
        execute_process(COMMAND ${LCOV_PATH} --version OUTPUT_VARIABLE _lcov_version_out ERROR_QUIET)
        string(REGEX MATCH "version ([0-9]+)" _m "${_lcov_version_out}")
        if(CMAKE_MATCH_1 GREATER_EQUAL 2)
            if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
                # llvm-cov gcov output has no function end lines and reports line 0 for static initializers.
                set(_lcov_rc --rc derive_function_end_line=0)
                set(_lcov_capture_ignore --ignore-errors negative,negative,inconsistent,inconsistent,format,format,unsupported,unsupported)
                set(_lcov_remove_ignore --ignore-errors unused,unused,inconsistent,inconsistent,unsupported,unsupported)
            else()
                set(_lcov_capture_ignore --ignore-errors negative,negative,inconsistent,inconsistent)
                set(_lcov_remove_ignore --ignore-errors unused,unused)
            endif()
        endif()
    endif()

    message(STATUS "[Coverage] Code coverage enabled (compiler: ${CMAKE_CXX_COMPILER_ID})")
    message(STATUS "[Coverage]   gcov:    ${_gcovr_gcov}")
    message(STATUS "[Coverage]   lcov:    ${LCOV_PATH}")
    message(STATUS "[Coverage]   genhtml: ${GENHTML_PATH}")
    message(STATUS "[Coverage]   gcovr:   ${GCOVR_PATH}")

    get_property(_coverage_targets GLOBAL PROPERTY IDICMAKE_COVERAGE_TARGETS)
    get_property(_coverage_excludes GLOBAL PROPERTY IDICMAKE_COVERAGE_EXCLUDES)
    get_property(_summary_script GLOBAL PROPERTY _IDICMAKE_COVERAGE_SCRIPT)

    if(NOT _coverage_targets)
        message(STATUS "[Coverage] No test targets registered for aggregate coverage.")
        return()
    endif()

    message(STATUS "[Coverage] Registered test targets:")
    foreach(_target ${_coverage_targets})
        message(STATUS "[Coverage]   - ${_target}")
    endforeach()

    # Patterns appended to the property directly (e.g. from a hook) may still be relative
    set(_all_excludes "")
    foreach(_pattern IN LISTS _coverage_excludes)
        _idicmake_coverage_normalize_pattern(_abs "${_pattern}")
        list(APPEND _all_excludes "${_abs}")
    endforeach()
    list(APPEND _all_excludes
        "/usr/*"
        "*/Catch2/*"
        "*/catch2/*"
        "*/_deps/*"
    )
    list(REMOVE_DUPLICATES _all_excludes)

    set(_report_dir "${CMAKE_BINARY_DIR}/reports/coverage")

    # Steps shared by every report target: reset counters, then run all tests through ctest so tests a project
    # registers with plain add_test() (scripts, system tests) count too. A failing test fails the target.
    set(_reset_and_run
        COMMAND ${CMAKE_COMMAND} -E make_directory "${_report_dir}"
        COMMAND ${CMAKE_COMMAND} -DACTION=zero -DBUILD_DIR=${CMAKE_BINARY_DIR} -P "${_summary_script}"
        COMMAND ${CMAKE_CTEST_COMMAND} --test-dir ${CMAKE_BINARY_DIR} -C $<CONFIG> --output-on-failure ${IDICMAKE_COVERAGE_CTEST_ARGS}
    )

    set(_gcovr_args "")
    if(GCOVR_PATH)
        set(_gcovr_args -r ${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR}
            --gcov-executable "${_gcovr_gcov}"
            --gcov-ignore-parse-errors=negative_hits.warn_once_per_file)
        foreach(_pattern ${_all_excludes})
            _idicmake_glob_to_regex(_regex "${_pattern}")
            list(APPEND _gcovr_args -e "${_regex}")
        endforeach()
    endif()

    set(_fail_under "")
    if(DEFINED IDICMAKE_COVERAGE_FAIL_UNDER AND NOT IDICMAKE_COVERAGE_FAIL_UNDER STREQUAL "")
        set(_fail_under "-DFAIL_UNDER=${IDICMAKE_COVERAGE_FAIL_UNDER}")
    endif()

    # -----------------------------------------------------------------
    # ccov-all — preference: lcov+genhtml > gcovr > basic (gcov data only)
    # -----------------------------------------------------------------
    if(LCOV_PATH AND GENHTML_PATH)
        set(_xml_commands "")
        if(GCOVR_PATH)
            set(_xml_commands
                COMMAND ${GCOVR_PATH} ${_gcovr_args} --xml-pretty -o "${_report_dir}/coverage.xml"
                COMMAND ${CMAKE_COMMAND} -E echo "[Coverage] Cobertura XML: ${_report_dir}/coverage.xml"
            )
        endif()

        add_custom_target(ccov-all
            ${_reset_and_run}
            COMMAND ${LCOV_PATH} --directory ${CMAKE_BINARY_DIR} --capture --quiet
                --output-file "${_report_dir}/coverage.info"
                --gcov-tool ${_gcov_tool}
                ${_lcov_rc} ${_lcov_capture_ignore}
            COMMAND ${LCOV_PATH} --remove "${_report_dir}/coverage.info" ${_all_excludes} --quiet
                --output-file "${_report_dir}/coverage.info"
                --gcov-tool ${_gcov_tool}
                ${_lcov_rc} ${_lcov_remove_ignore}
            COMMAND ${GENHTML_PATH} "${_report_dir}/coverage.info" --quiet ${_lcov_rc}
                --output-directory "${_report_dir}/html"
            ${_xml_commands}
            COMMAND ${CMAKE_COMMAND} -E echo "[Coverage] HTML report: ${_report_dir}/html/index.html"
            COMMAND ${CMAKE_COMMAND} -E echo "[Coverage] LCOV info:   ${_report_dir}/coverage.info"
            COMMAND ${CMAKE_COMMAND} -DACTION=summary "-DINFO_FILE=${_report_dir}/coverage.info" ${_fail_under} -P "${_summary_script}"
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            DEPENDS ${_coverage_targets}
            COMMENT "Generating aggregate code coverage report (lcov + genhtml)"
            VERBATIM
        )
    elseif(GCOVR_PATH)
        add_custom_target(ccov-all
            ${_reset_and_run}
            COMMAND ${CMAKE_COMMAND} -E make_directory "${_report_dir}/html"
            COMMAND ${GCOVR_PATH} ${_gcovr_args}
                --html-details "${_report_dir}/html/index.html"
                --xml-pretty -o "${_report_dir}/coverage.xml"
            COMMAND ${CMAKE_COMMAND} -E echo "[Coverage] HTML report:   ${_report_dir}/html/index.html"
            COMMAND ${CMAKE_COMMAND} -E echo "[Coverage] Cobertura XML: ${_report_dir}/coverage.xml"
            COMMAND ${CMAKE_COMMAND} -DACTION=summary "-DXML_FILE=${_report_dir}/coverage.xml" ${_fail_under} -P "${_summary_script}"
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            DEPENDS ${_coverage_targets}
            COMMENT "Generating aggregate code coverage report (gcovr)"
            VERBATIM
        )
    else()
        add_custom_target(ccov-all
            ${_reset_and_run}
            COMMAND ${CMAKE_COMMAND} -E echo "[Coverage] Raw coverage data (.gcda/.gcno) generated in ${CMAKE_BINARY_DIR}"
            COMMAND ${CMAKE_COMMAND} -E echo "[Coverage] Install lcov+genhtml or gcovr for HTML/XML report generation:"
            COMMAND ${CMAKE_COMMAND} -E echo "[Coverage]   apt install lcov   OR   pip install gcovr"
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            DEPENDS ${_coverage_targets}
            COMMENT "Running tests for coverage data collection (no report tools found)"
            VERBATIM
        )
        message(STATUS "[Coverage] WARNING: Neither lcov+genhtml nor gcovr found.")
        message(STATUS "[Coverage]   Install one for HTML/XML coverage reports:")
        message(STATUS "[Coverage]     apt install lcov   OR   pip install gcovr")
    endif()

    # XML-only target for CI
    if(GCOVR_PATH)
        add_custom_target(ccov-all-xml
            ${_reset_and_run}
            COMMAND ${GCOVR_PATH} ${_gcovr_args} --xml-pretty -o "${_report_dir}/coverage.xml"
            COMMAND ${CMAKE_COMMAND} -E echo "[Coverage] Cobertura XML: ${_report_dir}/coverage.xml"
            COMMAND ${CMAKE_COMMAND} -DACTION=summary "-DXML_FILE=${_report_dir}/coverage.xml" ${_fail_under} -P "${_summary_script}"
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            DEPENDS ${_coverage_targets}
            COMMENT "Generating Cobertura XML code coverage report (gcovr)"
            VERBATIM
        )
    endif()

    add_custom_target(ccov-clean
        COMMAND ${CMAKE_COMMAND} -E rm -rf "${_report_dir}"
        COMMAND ${CMAKE_COMMAND} -DACTION=zero -DBUILD_DIR=${CMAKE_BINARY_DIR} -P "${_summary_script}"
        COMMENT "Removing coverage reports from ${_report_dir} and resetting counters"
        VERBATIM
    )

    message(STATUS "[Coverage] Exclude patterns:")
    foreach(_pattern ${_all_excludes})
        message(STATUS "[Coverage]   - ${_pattern}")
    endforeach()
    message(STATUS "[Coverage] Report directory: ${_report_dir}/")
endfunction()
