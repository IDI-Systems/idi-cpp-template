#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2023 International Development & Integration Systems LLC
#

# This is the list of all files that should be included in the core build.
# You _should_ include .h/.hpp files here so they properly show up in IDEs.
# They should be marked as INTERFACE so that other libraries consuming the core
# can access them.
set(IDI_PROJECT_NAME_STR ${IDI_PROJECT_NAME})

configure_file(${CMAKE_SOURCE_DIR}/idi_version.h ${CMAKE_CURRENT_LIST_DIR}/__idi_version.out.h)

idi_add_public_includes(
    "${CMAKE_CURRENT_LIST_DIR}/export.h"
    "${CMAKE_CURRENT_LIST_DIR}/version.h"
    "${CMAKE_CURRENT_LIST_DIR}/platform_config.h"
    "${CMAKE_CURRENT_LIST_DIR}/idi_version.h"
    "${CMAKE_CURRENT_LIST_DIR}/__idi_version.out.h"
    INTERNAL_CONFIGURE
    "${CMAKE_CURRENT_LIST_DIR}/__version.h"
    "${CMAKE_CURRENT_LIST_DIR}/__export.h"
    "${CMAKE_CURRENT_LIST_DIR}/__platform_config.h"

)

message( STATUS "Configured CI Branch Name: ${IDI_CI_GIT_BRANCH_NAME}")
add_custom_target("${IDI_PROJECT_NAME}GetBuildInfo" COMMAND ${CMAKE_COMMAND}
    -Dlocal_dir="${CMAKE_CURRENT_LIST_DIR}"
    -Doutput_dir="${CMAKE_CURRENT_LIST_DIR}"
    -Duse_git_versioning="${IDI_USE_GIT_VERSIONING}"
    -Duse_build_timestamps="${IDI_USE_BUILD_TIMESTAMPS}"
    -Dgit_branch_name="${IDI_CI_GIT_BRANCH_NAME}"
    -P "${CMAKE_SOURCE_DIR}/cmake/build_info.cmake"
    )

add_dependencies("${IDI_PROJECT_NAME}_common" "${IDI_PROJECT_NAME}GetBuildInfo")
