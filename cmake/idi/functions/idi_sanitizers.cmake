#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2026 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#
# Sanitizer builds: instrument everything the project builds (its components, tests, demos and the dependencies it
# adds) so ctest runs under the sanitizers.
#
# Variables (set with -D, or in cmake-hooks/post-options.cmake):
#   IDICMAKE_SANITIZERS  - sanitizers to enable, a list: address, undefined, leak, thread (empty = none)
#                          e.g. -DIDICMAKE_SANITIZERS="address;undefined" or -DIDICMAKE_SANITIZERS=thread
#
# Use a separate build folder for each set, e.g. build-asan and build-tsan:
#   cmake -B build-asan -DIDICMAKE_SANITIZERS="address;undefined" && cmake --build build-asan && ctest --test-dir build-asan
#
# GCC and Clang take any of them except thread together with address or leak. MSVC supports only address.
# Undefined behaviour stops the program (-fno-sanitize-recover), so a test with UB fails instead of printing a warning.
# Top-level builds only: a project added with add_subdirectory follows the parent project's flags.
#

include_guard(GLOBAL)

set(IDICMAKE_SANITIZERS "" CACHE STRING "Sanitizers for every target: address, undefined, leak, thread (a list; empty = none)")

# Called by the framework from idi_init() before the dependencies and src/ are added, so the flags reach every target.
macro(idi_sanitizers_setup)
    if(NOT IDICMAKE_IS_SUBDIRECTORY AND NOT "${IDICMAKE_SANITIZERS}" STREQUAL "")
        _idicmake_sanitizer_flags(_idicmake_san_compile _idicmake_san_link)
        add_compile_options(${_idicmake_san_compile})
        add_link_options(${_idicmake_san_link})
        list(JOIN _idicmake_san_compile " " _idicmake_san_shown)
        message(STATUS "[Sanitizers] *** Sanitizer build: ${_idicmake_san_shown} ***")
        unset(_idicmake_san_shown)
        unset(_idicmake_san_compile)
        unset(_idicmake_san_link)
    endif()
endmacro()

function(_idicmake_sanitizer_flags OUT_COMPILE OUT_LINK)
    set(_known address undefined leak thread)
    set(_list ${IDICMAKE_SANITIZERS})
    string(TOLOWER "${_list}" _list)
    string(REPLACE "," ";" _list "${_list}")
    list(REMOVE_DUPLICATES _list)
    foreach(_s IN LISTS _list)
        if(NOT _s IN_LIST _known)
            message(FATAL_ERROR "[Sanitizers] Unknown sanitizer '${_s}' in IDICMAKE_SANITIZERS (use: ${_known})")
        endif()
    endforeach()
    if("thread" IN_LIST _list AND ("address" IN_LIST _list OR "leak" IN_LIST _list))
        message(FATAL_ERROR "[Sanitizers] thread cannot be combined with address or leak; use a separate build folder")
    endif()

    if(MSVC)
        if(NOT _list STREQUAL "address")
            message(FATAL_ERROR "[Sanitizers] MSVC supports only IDICMAKE_SANITIZERS=address (got '${IDICMAKE_SANITIZERS}')")
        endif()
        set(${OUT_COMPILE} /fsanitize=address /Zi PARENT_SCOPE)
        set(${OUT_LINK} "" PARENT_SCOPE)
        return()
    endif()

    list(JOIN _list "," _joined)
    set(_compile "-fsanitize=${_joined}" -fno-omit-frame-pointer -g)
    set(_link "-fsanitize=${_joined}")
    if("undefined" IN_LIST _list)
        list(APPEND _compile -fno-sanitize-recover=undefined)
    endif()
    set(${OUT_COMPILE} ${_compile} PARENT_SCOPE)
    set(${OUT_LINK} ${_link} PARENT_SCOPE)
endfunction()
