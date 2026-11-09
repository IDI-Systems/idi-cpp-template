#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2025 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#
# Applies a staged framework update from FRAMEWORK_UPDATE_DIR to the project. Runs from the incoming
# framework whenever its updater version differs from the project's (see updater.cmake).

macro(do_replace_dir)
    message(STATUS "\tFramework update - Updating ${ARGV0}")
    file(REMOVE_RECURSE "${CMAKE_CURRENT_SOURCE_DIR}/${ARGV0}")
    file(COPY "${FRAMEWORK_UPDATE_DIR}/${ARGV0}" DESTINATION "${CMAKE_CURRENT_SOURCE_DIR}/${ARGV0}")
    message(STATUS "\tFramework update - Done Updating ${ARGV0}")
endmacro()

macro(do_replace_file)
    message(STATUS "\tFramework update - Updating ${ARGV0}")
    file(REMOVE "${CMAKE_CURRENT_SOURCE_DIR}/${ARGV0}")
    file(COPY_FILE "${FRAMEWORK_UPDATE_DIR}/${ARGV0}" "${CMAKE_CURRENT_SOURCE_DIR}/${ARGV0}")
    message(STATUS "\tFramework update - Done Updating ${ARGV0}")
endmacro()

include("${FRAMEWORK_UPDATE_DIR}/cmake/idi/updater/managed_paths.cmake")

foreach(__idi_managed_dir IN LISTS IDICMAKE_UPDATER_MANAGED_DIRS)
    # file(COPY <dir> DESTINATION <dir>) copies into a sub folder unless the source ends with a slash
    do_replace_dir("${__idi_managed_dir}/")
endforeach()

set(IDICMAKE_PLATFORM_CONFIG "${CMAKE_CURRENT_SOURCE_DIR}/platform-config.cmake")
include("${IDICMAKE_PLATFORM_CONFIG}")
if(DEFINED IDI_PROJECT_NAME)
    message(WARNING "Attention! It appears that your project contains files using the old IDI_ prefix instead of the new IDICMAKE_ prefix in files such a platform-config.cmake and other .cmake files! Please update these manually or problems may occur!")
    set(IDICMAKE_PROJECT_NAME ${IDI_PROJECT_NAME})
endif()
if(NOT IDICMAKE_PROJECT_NAME STREQUAL "template_project")
    file(RENAME "${CMAKE_CURRENT_SOURCE_DIR}/src/base/include/template_project" "${CMAKE_CURRENT_SOURCE_DIR}/src/base/include/${IDICMAKE_PROJECT_NAME}")
endif()

foreach(__idi_managed_file IN LISTS IDICMAKE_UPDATER_MANAGED_FILES)
    do_replace_file("${__idi_managed_file}")
endforeach()
