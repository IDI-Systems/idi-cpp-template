# cmake/gitversion.cmake
cmake_minimum_required(VERSION 3.0.0)

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
  message( STATUS "GIT dirty: ${__idi_version_git_is_dirty}")
  if(__idi_version_git_is_dirty)
    set(__idi_version_git_hash_short "${__idi_version_git_hash_short}-dirty")
  endif()
  message( STATUS "GIT hash (short): ${__idi_version_git_hash_short}")
  message( STATUS "GIT hash (long): ${__idi_version_git_hash_long}")
  message( STATUS "GIT branch name: ${__idi_version_git_branch}")
else()
  message(STATUS "GIT not found")
endif()

string(TIMESTAMP _time_stamp)

configure_file(${local_dir}/idi_version.h ${output_dir}/idi_version.h @ONLY)
