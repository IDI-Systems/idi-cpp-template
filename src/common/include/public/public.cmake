#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2021 International Development & Integration Systems LLC
#

# This is the list of all files that should be included in the core build.
# You _should_ include .h/.hpp files here so they properly show up in IDEs.
# They should be marked as INTERFACE so that other libraries consuming the core
# can access them.
idi_add_public_includes(
    "${CMAKE_CURRENT_LIST_DIR}/export.h"
    "${CMAKE_CURRENT_LIST_DIR}/version.h"
    EXTERNAL
    "${CMAKE_BINARY_DIR}/configured_templates/platform_config.h"
    INTERNAL_CONFIGURE
    "${CMAKE_CURRENT_LIST_DIR}/__version.h"
)

configure_file(${CMAKE_SOURCE_DIR}/templates/platform_config.in.h ${CMAKE_BINARY_DIR}/configured_templates/platform_config.h)
configure_file(${CMAKE_SOURCE_DIR}/idi_version.h ${CMAKE_BINARY_DIR}/configured_templates/idi_version.h)
add_custom_target(GetBuildInfo COMMAND ${CMAKE_COMMAND}
    -Dlocal_dir="${CMAKE_CURRENT_LIST_DIR}"
    -Doutput_dir="${CMAKE_CURRENT_LIST_DIR}"
    -Duse_git_versioning="${IDI_USE_GIT_VERSIONING}"
    -Duse_build_timestamps="${IDI_USE_BUILD_TIMESTAMPS}"
    -Dgit_branch_name="${IDI_GIT_BRANCH_NAME}"
    -P "${CMAKE_SOURCE_DIR}/cmake/build_info.cmake"
    )

add_dependencies(common GetBuildInfo)

target_include_directories("${CURRENT_LIBRARY_NAME}" PUBLIC "${CMAKE_BINARY_DIR}/configured_templates")
target_include_directories("${IDI_CORE}" PUBLIC "${CMAKE_BINARY_DIR}/configured_templates")
target_include_directories("${IDI_CORE}" INTERFACE "${CMAKE_BINARY_DIR}/configured_templates")
