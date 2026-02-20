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
# Cache Options:
#   CODE_COVERAGE - Enable code coverage instrumentation (default: OFF)
#
# Custom Build Targets (created when CODE_COVERAGE=ON):
#   ccov-all       - Run all registered tests and generate aggregate HTML coverage report
#   ccov-all-xml   - Generate Cobertura XML coverage report (requires gcovr, for CI)
#   ccov-clean     - Remove generated coverage data and reports
#
# Report output directory: ${CMAKE_BINARY_DIR}/reports/coverage/
#
# Supported compilers: GCC, Clang
# Supported report tools: lcov + genhtml, gcovr (at least one recommended)
#

include_guard(GLOBAL)

# CODE_COVERAGE is intentionally NOT cached so it must be explicitly passed
# each time: cmake .. -DCODE_COVERAGE=ON
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

# ---------------------------------------------------------------------------
# target_code_coverage(<target> [ALL] [OBJECTS <targets...>] [EXCLUDE <patterns...>])
#
# Instruments a target with code coverage compile and link flags.
#
# Arguments:
#   <target>  - The CMake target to instrument
#   ALL       - Register this executable target for the aggregate 'ccov-all' report
#   OBJECTS   - Additional library/object targets to also instrument for coverage
#   EXCLUDE   - File patterns to exclude from coverage analysis for this target
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

    # Parse arguments
    set(_options ALL)
    set(_multi OBJECTS EXCLUDE)
    cmake_parse_arguments(COV "${_options}" "" "${_multi}" ${ARGN})

    # Validate target
    if(NOT TARGET ${TARGET_NAME})
        message(WARNING "[Coverage] Target '${TARGET_NAME}' does not exist. Skipping.")
        return()
    endif()

    get_target_property(_target_type ${TARGET_NAME} TYPE)

    # Skip interface libraries
    if(_target_type STREQUAL "INTERFACE_LIBRARY")
        return()
    endif()

    # Add coverage compile flags
    target_compile_options(${TARGET_NAME} PRIVATE --coverage)

    # Add coverage link flags for targets that link
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

    # Register executable targets for aggregate coverage
    if(COV_ALL AND _target_type STREQUAL "EXECUTABLE")
        set_property(GLOBAL APPEND PROPERTY IDICMAKE_COVERAGE_TARGETS ${TARGET_NAME})
    endif()

    # Store exclude patterns globally
    foreach(_pattern ${COV_EXCLUDE})
        set_property(GLOBAL APPEND PROPERTY IDICMAKE_COVERAGE_EXCLUDES "${_pattern}")
    endforeach()
endfunction()

# ---------------------------------------------------------------------------
# add_code_coverage_all_targets([EXCLUDE <patterns...>])
#
# Schedules creation of aggregate coverage targets. The actual target creation
# is deferred to the end of root directory processing so that all
# target_code_coverage(ALL) registrations have been processed.
#
# Arguments:
#   EXCLUDE - Additional glob patterns to exclude from the aggregate report
# ---------------------------------------------------------------------------
function(add_code_coverage_all_targets)
    if(NOT CODE_COVERAGE)
        return()
    endif()

    # Parse arguments
    set(_multi EXCLUDE)
    cmake_parse_arguments(COV "" "" "${_multi}" ${ARGN})

    foreach(_pattern ${COV_EXCLUDE})
        set_property(GLOBAL APPEND PROPERTY IDICMAKE_COVERAGE_EXCLUDES "${_pattern}")
    endforeach()

    # Schedule deferred target creation (once only)
    get_property(_scheduled GLOBAL PROPERTY _IDICMAKE_COVERAGE_ALL_SCHEDULED)
    if(NOT _scheduled)
        set_property(GLOBAL PROPERTY _IDICMAKE_COVERAGE_ALL_SCHEDULED TRUE)
        cmake_language(DEFER DIRECTORY ${CMAKE_SOURCE_DIR} CALL _idicmake_create_coverage_targets)
    endif()
endfunction()

# ---------------------------------------------------------------------------
# Internal helper: Convert a glob pattern to a regex pattern for gcovr.
# Only handles * -> .* conversion which covers the patterns used in this project.
# ---------------------------------------------------------------------------
function(_idicmake_glob_to_regex OUT_VAR GLOB_PATTERN)
    string(REPLACE "." "\\." _regex "${GLOB_PATTERN}")
    string(REPLACE "*" ".*" _regex "${_regex}")
    set(${OUT_VAR} "${_regex}" PARENT_SCOPE)
endfunction()

# ---------------------------------------------------------------------------
# Internal: Deferred creation of aggregate coverage targets.
# Runs at the end of root directory processing after all targets are registered.
# ---------------------------------------------------------------------------
function(_idicmake_create_coverage_targets)
    # Verify compiler support
    if(NOT (CMAKE_C_COMPILER_ID MATCHES "GNU|Clang" OR CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang"))
        message(WARNING "[Coverage] Code coverage requires GCC or Clang (found: ${CMAKE_CXX_COMPILER_ID}). Coverage targets not created.")
        return()
    endif()

    # Locate coverage tools
    find_program(GCOV_PATH gcov)
    find_program(LCOV_PATH lcov)
    find_program(GENHTML_PATH genhtml)
    find_program(GCOVR_PATH gcovr)

    if(NOT GCOV_PATH)
        message(WARNING "[Coverage] gcov not found! Coverage report targets will not be created.")
        return()
    endif()

    # Report tool availability
    message(STATUS "[Coverage] Code coverage enabled (compiler: ${CMAKE_CXX_COMPILER_ID})")
    message(STATUS "[Coverage]   gcov:    ${GCOV_PATH}")
    message(STATUS "[Coverage]   lcov:    ${LCOV_PATH}")
    message(STATUS "[Coverage]   genhtml: ${GENHTML_PATH}")
    message(STATUS "[Coverage]   gcovr:   ${GCOVR_PATH}")

    # Retrieve registered targets and exclude patterns
    get_property(_coverage_targets GLOBAL PROPERTY IDICMAKE_COVERAGE_TARGETS)
    get_property(_coverage_excludes GLOBAL PROPERTY IDICMAKE_COVERAGE_EXCLUDES)
    if(_coverage_excludes)
        list(REMOVE_DUPLICATES _coverage_excludes)
    endif()

    if(NOT _coverage_targets)
        message(STATUS "[Coverage] No test targets registered for aggregate coverage.")
        return()
    endif()

    message(STATUS "[Coverage] Registered test targets:")
    foreach(_target ${_coverage_targets})
        message(STATUS "[Coverage]   - ${_target}")
    endforeach()

    # Build the list of test execution commands and dependencies
    set(_run_commands "")
    set(_depends_list "")
    foreach(_target ${_coverage_targets})
        list(APPEND _run_commands COMMAND $<TARGET_FILE:${_target}>)
        list(APPEND _depends_list ${_target})
    endforeach()

    # Combine user excludes with standard exclusion patterns
    set(_all_excludes ${_coverage_excludes})
    list(APPEND _all_excludes
        "/usr/*"
        "*/Catch2/*"
        "*/catch2/*"
        "*/_deps/*"
    )
    list(REMOVE_DUPLICATES _all_excludes)

    set(_report_dir "${CMAKE_BINARY_DIR}/reports/coverage")

    # -----------------------------------------------------------------
    # Create ccov-all target based on available tools
    # Preference: lcov+genhtml > gcovr > basic (gcov data only)
    # -----------------------------------------------------------------
    if(LCOV_PATH AND GENHTML_PATH)
        # --- lcov + genhtml path ---
        set(_lcov_remove_args "")
        foreach(_pattern ${_all_excludes})
            list(APPEND _lcov_remove_args "${_pattern}")
        endforeach()

        add_custom_target(ccov-all
            # Create report directory
            COMMAND ${CMAKE_COMMAND} -E make_directory "${_report_dir}"
            # Zero counters from any previous run
            COMMAND ${LCOV_PATH} --directory ${CMAKE_BINARY_DIR} --zerocounters
            --gcov-tool ${GCOV_PATH}
            # Run all test executables
            ${_run_commands}
            # Capture coverage data
            COMMAND ${LCOV_PATH} --directory ${CMAKE_BINARY_DIR} --capture
            --output-file "${_report_dir}/coverage.info"
            --gcov-tool ${GCOV_PATH}
            # Remove excluded paths (--ignore-errors unused: lcov 2.0+ errors on patterns that match nothing)
            COMMAND ${LCOV_PATH} --remove "${_report_dir}/coverage.info"
            ${_lcov_remove_args}
            --output-file "${_report_dir}/coverage.info"
            --gcov-tool ${GCOV_PATH}
            --ignore-errors unused,unused
            # Generate HTML report
            COMMAND ${GENHTML_PATH} "${_report_dir}/coverage.info"
            --output-directory "${_report_dir}/html"
            COMMAND ${CMAKE_COMMAND} -E echo
            "[Coverage] HTML report: ${_report_dir}/html/index.html"
            COMMAND ${CMAKE_COMMAND} -E echo
            "[Coverage] LCOV info:   ${_report_dir}/coverage.info"
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            DEPENDS ${_depends_list}
            COMMENT "Generating aggregate code coverage report (lcov + genhtml)"
            VERBATIM
        )

        # If gcovr is also available, add an XML report target for CI integration
        if(GCOVR_PATH)
            set(_gcovr_excludes "")
            foreach(_pattern ${_all_excludes})
                _idicmake_glob_to_regex(_regex "${_pattern}")
                list(APPEND _gcovr_excludes -e "${_regex}")
            endforeach()

            add_custom_target(ccov-all-xml
                COMMAND ${CMAKE_COMMAND} -E make_directory "${_report_dir}"
                ${_run_commands}
                COMMAND ${GCOVR_PATH} -r ${CMAKE_SOURCE_DIR} ${_gcovr_excludes}
                --xml-pretty -o "${_report_dir}/coverage.xml"
                COMMAND ${CMAKE_COMMAND} -E echo
                "[Coverage] Cobertura XML: ${_report_dir}/coverage.xml"
                WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
                DEPENDS ${_depends_list}
                COMMENT "Generating Cobertura XML code coverage report (gcovr)"
                VERBATIM
            )
        endif()

    elseif(GCOVR_PATH)
        # --- gcovr path (HTML + XML) ---
        set(_gcovr_excludes "")
        foreach(_pattern ${_all_excludes})
            _idicmake_glob_to_regex(_regex "${_pattern}")
            list(APPEND _gcovr_excludes -e "${_regex}")
        endforeach()

        add_custom_target(ccov-all
            COMMAND ${CMAKE_COMMAND} -E make_directory "${_report_dir}/html"
            ${_run_commands}
            # Generate HTML report
            COMMAND ${GCOVR_PATH} -r ${CMAKE_SOURCE_DIR} ${_gcovr_excludes}
            --html --html-details
            -o "${_report_dir}/html/index.html"
            # Generate XML report
            COMMAND ${GCOVR_PATH} -r ${CMAKE_SOURCE_DIR} ${_gcovr_excludes}
            --xml-pretty -o "${_report_dir}/coverage.xml"
            COMMAND ${CMAKE_COMMAND} -E echo
            "[Coverage] HTML report:   ${_report_dir}/html/index.html"
            COMMAND ${CMAKE_COMMAND} -E echo
            "[Coverage] Cobertura XML: ${_report_dir}/coverage.xml"
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            DEPENDS ${_depends_list}
            COMMENT "Generating aggregate code coverage report (gcovr)"
            VERBATIM
        )

    else()
        # --- Basic: no report tools, just run tests to generate .gcda files ---
        add_custom_target(ccov-all
            ${_run_commands}
            COMMAND ${CMAKE_COMMAND} -E echo
            "[Coverage] Raw coverage data (.gcda/.gcno) generated in ${CMAKE_BINARY_DIR}"
            COMMAND ${CMAKE_COMMAND} -E echo
            "[Coverage] Install lcov+genhtml or gcovr for HTML/XML report generation:"
            COMMAND ${CMAKE_COMMAND} -E echo
            "[Coverage]   apt install lcov   OR   pip install gcovr"
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            DEPENDS ${_depends_list}
            COMMENT "Running tests for coverage data collection (no report tools found)"
            VERBATIM
        )
        message(STATUS "[Coverage] WARNING: Neither lcov+genhtml nor gcovr found.")
        message(STATUS "[Coverage]   Install one for HTML/XML coverage reports:")
        message(STATUS "[Coverage]     apt install lcov   OR   pip install gcovr")
    endif()

    # --- Always create ccov-clean target ---
    add_custom_target(ccov-clean
        COMMAND ${CMAKE_COMMAND} -E rm -rf "${_report_dir}"
        COMMENT "Removing coverage reports from ${_report_dir}"
    )

    if(_coverage_excludes)
        message(STATUS "[Coverage] Exclude patterns:")
        foreach(_pattern ${_coverage_excludes})
            message(STATUS "[Coverage]   - ${_pattern}")
        endforeach()
    endif()
    message(STATUS "[Coverage] Report directory: ${_report_dir}/")
endfunction()
