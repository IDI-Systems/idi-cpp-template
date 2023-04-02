#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2022 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

macro(idi_configure_common_includes)
    set(IDI_PROJECT_NAME_STR ${IDI_PROJECT_NAME})

    #configure_file(${PROJECT_SOURCE_DIR}/idi_version.h ${CMAKE_CURRENT_LIST_DIR}/__idi_version.out.h)
    message( STATUS "Configured CI Branch Name: ${IDI_CI_GIT_BRANCH_NAME}")
    add_custom_target("${IDI_PROJECT_NAME}GetBuildInfo" COMMAND ${CMAKE_COMMAND}
        -Dlocal_dir="${CMAKE_CURRENT_LIST_DIR}"
        -Doutput_dir="${CMAKE_CURRENT_LIST_DIR}"
        -Duse_git_versioning="${IDI_USE_GIT_VERSIONING}"
        -Duse_build_timestamps="${IDI_USE_BUILD_TIMESTAMPS}"
        -Dgit_branch_name="${IDI_CI_GIT_BRANCH_NAME}"
        -P "${PROJECT_SOURCE_DIR}/cmake/idi/scripts/build-info.cmake"
        )

    add_dependencies("${IDI_PROJECT_NAME}_base" "${IDI_PROJECT_NAME}GetBuildInfo")
endmacro()
