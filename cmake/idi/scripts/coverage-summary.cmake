#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2025 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#
# Script mode helper for the coverage targets.
#
#   cmake -DACTION=zero    -DBUILD_DIR=<dir> -P coverage-summary.cmake
#       Deletes every .gcda file under BUILD_DIR (resets the counters without needing lcov).
#
#   cmake -DACTION=summary [-DINFO_FILE=<coverage.info>] [-DXML_FILE=<coverage.xml>] [-DFAIL_UNDER=<percent>] -P coverage-summary.cmake
#       Prints one line "Code Coverage: 87.25%" (line coverage) that CI can match with
#       /^Code Coverage: \d+(?:\.\d+)?%$/ and fails if the value is below FAIL_UNDER.
#       INFO_FILE (lcov) is preferred when both are given.
#

if(ACTION STREQUAL "zero")
    file(GLOB_RECURSE _gcda "${BUILD_DIR}/*.gcda")
    list(LENGTH _gcda _count)
    if(_gcda)
        file(REMOVE ${_gcda})
    endif()
    message(STATUS "[Coverage] Reset counters (${_count} .gcda files removed)")
    return()
endif()

if(NOT ACTION STREQUAL "summary")
    message(FATAL_ERROR "coverage-summary.cmake: unknown ACTION '${ACTION}' (expected zero or summary)")
endif()

# Percent is kept as an integer number of hundredths (8725 == 87.25%) since CMake math is integer only.
set(_hundredths "")
if(INFO_FILE AND EXISTS "${INFO_FILE}")
    file(STRINGS "${INFO_FILE}" _lf_lines REGEX "^LF:")
    file(STRINGS "${INFO_FILE}" _lh_lines REGEX "^LH:")
    set(_found 0)
    set(_hit 0)
    foreach(_l IN LISTS _lf_lines)
        string(SUBSTRING "${_l}" 3 -1 _n)
        math(EXPR _found "${_found} + ${_n}")
    endforeach()
    foreach(_l IN LISTS _lh_lines)
        string(SUBSTRING "${_l}" 3 -1 _n)
        math(EXPR _hit "${_hit} + ${_n}")
    endforeach()
    if(_found GREATER 0)
        math(EXPR _hundredths "(${_hit} * 10000) / ${_found}")
    else()
        set(_hundredths 0)
    endif()
elseif(XML_FILE AND EXISTS "${XML_FILE}")
    file(READ "${XML_FILE}" _xml LIMIT 4096)
    string(REGEX MATCH "<coverage[^>]* line-rate=\"([0-9.]+)\"" _m "${_xml}")
    if(NOT _m)
        message(FATAL_ERROR "[Coverage] Could not read line-rate from ${XML_FILE}")
    endif()
    # line-rate is a fraction like 0.8725 or 1.0; turn it into hundredths of a percent.
    string(REGEX MATCH "^([0-9]+)(\\.([0-9]*))?$" _m "${CMAKE_MATCH_1}")
    set(_int "${CMAKE_MATCH_1}")
    set(_frac "${CMAKE_MATCH_3}0000")
    string(SUBSTRING "${_frac}" 0 4 _frac)
    # Prefix with 1 and subtract to drop leading zeros ("0500" -> 500).
    math(EXPR _hundredths "${_int} * 10000 + 1${_frac} - 10000")
else()
    message(FATAL_ERROR "[Coverage] No coverage data to summarize (INFO_FILE='${INFO_FILE}' XML_FILE='${XML_FILE}')")
endif()

math(EXPR _whole "${_hundredths} / 100")
math(EXPR _part "${_hundredths} % 100")
if(_part LESS 10)
    set(_part "0${_part}")
endif()
# message(NOTICE) prints without the "-- " prefix so the line can be matched exactly.
message(NOTICE "Code Coverage: ${_whole}.${_part}%")

if(DEFINED FAIL_UNDER AND NOT FAIL_UNDER STREQUAL "")
    # Accept "80" or "80.5"
    string(REGEX MATCH "^([0-9]+)(\\.([0-9]*))?$" _m "${FAIL_UNDER}")
    if(NOT _m)
        message(FATAL_ERROR "[Coverage] IDICMAKE_COVERAGE_FAIL_UNDER must be a number, got '${FAIL_UNDER}'")
    endif()
    set(_t_int "${CMAKE_MATCH_1}")
    set(_t_frac "${CMAKE_MATCH_3}00")
    string(SUBSTRING "${_t_frac}" 0 2 _t_frac)
    math(EXPR _threshold "${_t_int} * 100 + 1${_t_frac} - 100")
    if(_hundredths LESS _threshold)
        message(FATAL_ERROR "[Coverage] Line coverage ${_whole}.${_part}% is below the required ${FAIL_UNDER}%")
    endif()
endif()
