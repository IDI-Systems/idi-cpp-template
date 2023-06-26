#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2023 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

macro(idi_configure_common_includes)

    #configure_file(${PROJECT_SOURCE_DIR}/idi_version.h ${CMAKE_CURRENT_LIST_DIR}/__idi_version.out.h)
    message( STATUS "Configured CI Branch Name: ${IDICMAKE_CI_GIT_BRANCH_NAME}")
    add_custom_target("${IDICMAKE_PROJECT_NAME}_GetBuildInfo" COMMAND ${CMAKE_COMMAND}
        -Dlocal_dir="${CMAKE_CURRENT_LIST_DIR}"
        -Doutput_dir="${CMAKE_CURRENT_LIST_DIR}"
        -Duse_git_versioning="${IDICMAKE_USE_GIT_VERSIONING}"
        -Duse_build_timestamps="${IDICMAKE_USE_BUILD_TIMESTAMPS}"
        -Dgit_branch_name="${IDICMAKE_CI_GIT_BRANCH_NAME}"
        -Didi_c_caps_namespace="${__idi_c_caps_namespace}"
        -P "${PROJECT_SOURCE_DIR}/cmake/idi/scripts/build-info.cmake"
        )

    add_dependencies("${IDICMAKE_PROJECT_NAME}_base" "${IDICMAKE_PROJECT_NAME}_GetBuildInfo")
endmacro()
