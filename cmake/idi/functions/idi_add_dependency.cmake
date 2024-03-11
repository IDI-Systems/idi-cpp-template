#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2024 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

# cpm_parse_option is provided from the CPM library under an MIT license
#
# CPM.cmake - CMake's missing package manager
# ===========================================
# See https://github.com/cpm-cmake/CPM.cmake for usage and update instructions.
#
# MIT License

# splits a package option
function(cpm_parse_option OPTION)
  string(REGEX MATCH "^[^ ]+" OPTION_KEY "${OPTION}")
  string(LENGTH "${OPTION}" OPTION_LENGTH)
  string(LENGTH "${OPTION_KEY}" OPTION_KEY_LENGTH)
  if(OPTION_KEY_LENGTH STREQUAL OPTION_LENGTH)
    # no value for key provided, assume user wants to set option to "ON"
    set(OPTION_VALUE "ON")
  else()
    math(EXPR OPTION_KEY_LENGTH "${OPTION_KEY_LENGTH}+1")
    string(SUBSTRING "${OPTION}" "${OPTION_KEY_LENGTH}" "-1" OPTION_VALUE)
  endif()
  set(OPTION_KEY
      "${OPTION_KEY}"
      PARENT_SCOPE
  )
  set(OPTION_VALUE
      "${OPTION_VALUE}"
      PARENT_SCOPE
  )
endfunction()

function(idi_get_repo_information REPO_DIR)
    find_package(Git)
    if(NOT Git_FOUND)
        message(FATAL_ERROR "Git could not be found!")
    endif()
    execute_process(COMMAND ${GIT_EXECUTABLE} "status" "--porcelain" WORKING_DIRECTORY ${REPO_DIR} OUTPUT_VARIABLE IDI_TEST_REPO_PORCELAIN)
    if("${IDI_TEST_REPO_PORCELAIN}" STREQUAL "")
        set(IDI_REPO_IS_PORCELAIN
            true
            PARENT_SCOPE
        )
    else()
        set(IDI_REPO_IS_PORCELAIN
            false
            PARENT_SCOPE
        )
    endif()
    execute_process(COMMAND ${GIT_EXECUTABLE} "tag" "--points-at" "HEAD" WORKING_DIRECTORY ${REPO_DIR} OUTPUT_VARIABLE IDI_GET_REPO_TAG)
    string(STRIP "${IDI_GET_REPO_TAG}" IDI_GET_REPO_TAG)
    set(IDI_REPO_TAG
            "${IDI_GET_REPO_TAG}"
            PARENT_SCOPE
        )
    execute_process(COMMAND ${GIT_EXECUTABLE} "rev-parse" "HEAD" WORKING_DIRECTORY ${REPO_DIR} OUTPUT_VARIABLE IDI_GET_REPO_SHA1)
    string(STRIP "${IDI_GET_REPO_SHA1}" IDI_GET_REPO_SHA1)
    set(IDI_REPO_SHA1
            "${IDI_GET_REPO_SHA1}"
            PARENT_SCOPE
        )
    execute_process(COMMAND ${GIT_EXECUTABLE} "rev-parse" "--abbrev-ref" "HEAD" WORKING_DIRECTORY ${REPO_DIR} OUTPUT_VARIABLE IDI_GET_REPO_BRANCH)
    string(STRIP "${IDI_GET_REPO_BRANCH}" IDI_GET_REPO_BRANCH)
    set(IDI_REPO_BRANCH
            "${IDI_GET_REPO_BRANCH}"
            PARENT_SCOPE
        )

    execute_process(COMMAND ${GIT_EXECUTABLE} "branch" "--show-current" WORKING_DIRECTORY ${REPO_DIR} OUTPUT_VARIABLE IDI_TEST_IS_TRACKING_BRANCH)
    if("${IDI_TEST_IS_TRACKING_BRANCH}" STREQUAL "")
        set(IDI_REPO_IS_TRACKING_BRANCH
                false
                PARENT_SCOPE
            )
    else()
        set(IDI_REPO_IS_TRACKING_BRANCH
            true
            PARENT_SCOPE
        )
    endif()
    set(IDI_REPO_BRANCH_IS_AHEAD
            false
            PARENT_SCOPE
        )
    if(IDI_REPO_IS_TRACKING_BRANCH)
        execute_process(COMMAND ${GIT_EXECUTABLE} "fetch" WORKING_DIRECTORY ${REPO_DIR} OUTPUT_VARIABLE JUNK)
        execute_process(COMMAND ${GIT_EXECUTABLE} "status" "-sb" WORKING_DIRECTORY ${REPO_DIR} OUTPUT_VARIABLE IDI_TEST_IS_UP_TO_DATE)
        string(REGEX MATCHALL "##.*\[behind [0-9]+\]$" IDI_TEST_BEHIND ${IDI_TEST_IS_UP_TO_DATE})
        if (IDI_TEST_BEHIND)
            set(IDI_REPO_BRANCH_IS_AHEAD
                    true
                    PARENT_SCOPE
                )
        else()
            set(IDI_REPO_BRANCH_IS_AHEAD
                false
                PARENT_SCOPE
            )
        endif()
    endif()
endfunction()

function(idi_commit_starts_with ACTUAL_SHA1 CHECK_SHA1)
    set(IDI_REPO_SHA1_SAME false)
    string(FIND "${ACTUAL_SHA1}" "${CHECK_SHA1}" IDI_STARTS_WITH_SHA1)
    if("${IDI_STARTS_WITH_SHA1}" EQUAL 0)
        set(IDI_REPO_SHA1_SAME true)
    endif()
    return(PROPAGATE IDI_REPO_SHA1_SAME)
endfunction()

function(__idi_add_dependency IDI_DEP_NAME IDI_DEP_URL IDI_DEP_TAG IDI_DEP_THIRD_PARTY)
    set(options DOWNLOAD_ONLY)
    set(multiValueArgs DEP_OPTIONS)
    cmake_parse_arguments(IDI "${options}" "${oneValueArgs}"
    "${multiValueArgs}" ${ARGN} )

    string(TOLOWER ${IDI_DEP_NAME} IDI_DEP_NAME_LOWER)

    if(TARGET ${IDI_DEP_NAME})
        message(STATUS "${IDI_DEP_NAME} already added, skipping.")
        return()
    endif()

    set(IDI_DO_POPULATE false)

    if(IDI_DEP_THIRD_PARTY)
        set(IDI_DEP_SOURCE_DIR "${CMAKE_SOURCE_DIR}/lib/third-party/${IDI_DEP_NAME}")
        set(IDI_DEP_BINARY_DIR "${CMAKE_BINARY_DIR}/_deps/${IDI_DEP_NAME_LOWER}")
        if(EXISTS ${IDI_DEP_SOURCE_DIR} AND EXISTS "${IDI_DEP_SOURCE_DIR}/.git")

            idi_get_repo_information(${IDI_DEP_SOURCE_DIR})

            message(DEBUG "${IDI_DEP_NAME} IDI_DEP_TAG: ${IDI_DEP_TAG}")
            message(DEBUG "${IDI_DEP_NAME} IDI_REPO_IS_PORCELAIN: ${IDI_REPO_IS_PORCELAIN}")
            message(DEBUG "${IDI_DEP_NAME} IDI_REPO_TAG: ${IDI_REPO_TAG}")
            message(DEBUG "${IDI_DEP_NAME} IDI_REPO_SHA1: ${IDI_REPO_SHA1}")
            message(DEBUG "${IDI_DEP_NAME} IDI_REPO_BRANCH: ${IDI_REPO_BRANCH}")
            message(DEBUG "${IDI_DEP_NAME} IDI_REPO_IS_TRACKING_BRANCH: ${IDI_REPO_IS_TRACKING_BRANCH}")
            message(DEBUG "${IDI_DEP_NAME} IDI_REPO_BRANCH_IS_AHEAD: ${IDI_REPO_BRANCH_IS_AHEAD}")

            if(NOT IDI_REPO_IS_PORCELAIN)
                message(WARNING "Third-party dependency '${IDI_DEP_NAME}' has uncomitted or untracked files.")
            endif()

            idi_commit_starts_with("${IDI_REPO_SHA1}" "${IDI_DEP_TAG}")

            if (
                (NOT ("${IDI_REPO_TAG}" STREQUAL "${IDI_DEP_TAG}")) AND
                (NOT IDI_REPO_SHA1_SAME) AND
                (NOT ("${IDI_REPO_BRANCH}" STREQUAL "${IDI_DEP_TAG}"))
                )
                set(IDI_DO_POPULATE true)
            endif()

            if(IDI_REPO_IS_PORCELAIN AND IDI_REPO_IS_TRACKING_BRANCH AND IDI_REPO_BRANCH_IS_AHEAD)
                message(STATUS "Updating ${IDI_DEP_NAME} to current head of branch '${IDI_DEP_TAG}'")
                set(IDI_DO_POPULATE true)
            endif()

        else()
            set(IDI_DO_POPULATE true)
        endif()
    else()
        set(IDI_DEP_SOURCE_DIR "${CMAKE_SOURCE_DIR}/lib/first-party/${IDI_DEP_NAME}")
        set(IDI_DEP_BINARY_DIR "${CMAKE_BINARY_DIR}/_deps/${IDI_DEP_NAME_LOWER}")
        if(EXISTS ${IDI_DEP_SOURCE_DIR} AND EXISTS "${IDI_DEP_SOURCE_DIR}/.git")

            idi_get_repo_information(${IDI_DEP_SOURCE_DIR})

            message(DEBUG "${IDI_DEP_NAME} IDI_DEP_TAG: ${IDI_DEP_TAG}")
            message(DEBUG "${IDI_DEP_NAME} IDI_REPO_IS_PORCELAIN: ${IDI_REPO_IS_PORCELAIN}")
            message(DEBUG "${IDI_DEP_NAME} IDI_REPO_TAG: ${IDI_REPO_TAG}")
            message(DEBUG "${IDI_DEP_NAME} IDI_REPO_SHA1: ${IDI_REPO_SHA1}")
            message(DEBUG "${IDI_DEP_NAME} IDI_REPO_BRANCH: ${IDI_REPO_BRANCH}")
            message(DEBUG "${IDI_DEP_NAME} IDI_REPO_IS_TRACKING_BRANCH: ${IDI_REPO_IS_TRACKING_BRANCH}")
            message(DEBUG "${IDI_DEP_NAME} IDI_REPO_BRANCH_IS_AHEAD: ${IDI_REPO_BRANCH_IS_AHEAD}")

            if(NOT IDI_REPO_IS_PORCELAIN)
                message(WARNING "First-party dependency '${IDI_DEP_NAME}' has uncomitted or untracked files.")
            endif()

            idi_commit_starts_with("${IDI_REPO_SHA1}" "${IDI_DEP_TAG}")

            set(IDI_REPO_SAME_COMMIT true)

            if (
                (NOT ("${IDI_REPO_TAG}" STREQUAL "${IDI_DEP_TAG}")) AND
                (NOT IDI_REPO_SHA1_SAME) AND
                (NOT ("${IDI_REPO_BRANCH}" STREQUAL "${IDI_DEP_TAG}"))
                )
                message(WARNING "First-party dependency '${IDI_DEP_NAME}' is not on the same commit as defined by configuration. ${IDI_DEP_TAG} != ${IDI_REPO_TAG}|${IDI_REPO_SHA1}|${IDI_REPO_BRANCH}")
                set(IDI_REPO_SAME_COMMIT false)
            endif()

            if(IDI_REPO_IS_PORCELAIN AND IDI_REPO_IS_TRACKING_BRANCH AND IDI_REPO_BRANCH_IS_AHEAD)
                message(STATUS "Updating ${IDI_DEP_NAME} to current head of branch '${IDI_DEP_TAG}'")
                set(IDI_DO_POPULATE true)
            endif()


            if(IDI_SYNC_DEPENDENCIES)
                if(NOT IDI_REPO_IS_PORCELAIN)
                    message(FATAL_ERROR "Attempted to sync dependencies but first-party dependency '${IDI_DEP_NAME}' has uncomitted or untracked files, commit or stash changes and try again.")
                else()
                    set(IDI_DO_POPULATE true)
                endif()
            endif()

        else()
            set(IDI_DO_POPULATE true)
        endif()
    endif()

    if(${IDI_DO_POPULATE})
        message(STATUS "Populating dependency '${IDI_DEP_NAME}' from ${IDI_DEP_URL} at ref ${IDI_DEP_TAG}")
        FetchContent_Declare(
            ${IDI_DEP_NAME}
            GIT_REPOSITORY ${IDI_DEP_URL}
            GIT_TAG        ${IDI_DEP_TAG}
            SOURCE_DIR ${IDI_DEP_SOURCE_DIR}
            EXCLUDE_FROM_ALL
            SYSTEM
        )

        if(${${IDI_DEP_NAME_LOWER}_POPULATED})
            message(DEBUG "${IDI_DEP_NAME} already populated, skipping.")
            return()
        endif()

        FetchContent_Populate(${IDI_DEP_NAME})
    else()
        message(DEBUG "${IDI_DEP_NAME} already exists, skipping download.")
    endif()

    foreach(OPTION ${IDI_DEP_OPTIONS})
        cpm_parse_option("${OPTION}")
        set(${OPTION_KEY} "${OPTION_VALUE}")
    endforeach()

    if(NOT IDI_DOWNLOAD_ONLY)
        if (IDI_DEP_THIRD_PARTY)
            add_subdirectory(${IDI_DEP_SOURCE_DIR} ${IDI_DEP_BINARY_DIR} EXCLUDE_FROM_ALL SYSTEM)
        else()
            add_subdirectory(${IDI_DEP_SOURCE_DIR} ${IDI_DEP_BINARY_DIR})
        endif()
    endif()
    message(STATUS "Added dependency ${IDI_DEP_NAME}")
endfunction()

function(idi_add_third_party_dependency IDI_DEP_NAME IDI_DEP_URL IDI_DEP_TAG)
    __idi_add_dependency(${IDI_DEP_NAME} ${IDI_DEP_URL} ${IDI_DEP_TAG} true ${ARGN})
endfunction()

function(idi_add_first_party_dependency IDI_DEP_NAME IDI_DEP_URL IDI_DEP_TAG)
    __idi_add_dependency(${IDI_DEP_NAME} ${IDI_DEP_URL} ${IDI_DEP_TAG} false ${ARGN})
endfunction()
