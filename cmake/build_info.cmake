# cmake/gitversion.cmake
cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

if (use_git_versioning)
    message(STATUS "Resolving GIT Version")

    set(__idi_version_git_hash_short "unknown")

    find_package(Git)
    if(GIT_FOUND)
        execute_process(
            COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
            WORKING_DIRECTORY "${local_dir}"
            OUTPUT_VARIABLE __idi_version_git_hash_short
            ERROR_QUIET
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        execute_process(
            COMMAND ${GIT_EXECUTABLE} rev-parse HEAD
            WORKING_DIRECTORY "${local_dir}"
            OUTPUT_VARIABLE __idi_version_git_hash_long
            ERROR_QUIET
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        execute_process(
            COMMAND ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
            WORKING_DIRECTORY "${local_dir}"
            OUTPUT_VARIABLE __idi_version_git_branch
            ERROR_QUIET
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        execute_process(
            COMMAND ${GIT_EXECUTABLE} diff --quiet
            WORKING_DIRECTORY "${local_dir}"
            RESULT_VARIABLE __idi_version_git_is_dirty
            ERROR_QUIET
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        if (git_branch_name AND (NOT git_branch_name STREQUAL __idi_version_git_branch))
            set(__idi_version_git_branch, "${git_branch_name}")
        endif()
        message( STATUS "GIT dirty: ${__idi_version_git_is_dirty}")
        message( STATUS "GIT hash (short): ${__idi_version_git_hash_short}")
        message( STATUS "GIT hash (long): ${__idi_version_git_hash_long}")
        message( STATUS "GIT branch name: ${__idi_version_git_branch}")
    else()
        message(STATUS "GIT not found")
        set(__idi_version_git_is_dirty 0)
        set(__idi_version_git_hash_short "")
        set(__idi_version_git_hash_long "")
        set(__idi_version_git_branch "")
    endif()
else()
    set(__idi_version_git_is_dirty 0)
    set(__idi_version_git_hash_short "")
    set(__idi_version_git_hash_long "")
    set(__idi_version_git_branch "")
endif()

if (use_build_timestamps)
    string(TIMESTAMP __idi_build_timestamp "%Y-%m-%dT%H:%M:%SZ" UTC)
else()
    set(__idi_build_timestamp "")
endif()

configure_file(${local_dir}/__build_info.h ${output_dir}/__build_info.out.h @ONLY)
