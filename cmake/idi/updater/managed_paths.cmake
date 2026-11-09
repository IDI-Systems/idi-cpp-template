#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2026 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#
# The paths the framework owns. The updater replaces exactly these (directories wholesale, files one by one);
# everything else in a project is left alone. Used by updater_imp.cmake and update_workflow.cmake.
#
# Changing this list changes what the updater writes: bump IDICMAKE_CPP_UPDATER_VERSION.

set(IDICMAKE_UPDATER_MANAGED_DIRS
    "cmake/idi"
    "src/base"
    ".claude/skills/idi-cmake"
)

set(IDICMAKE_UPDATER_MANAGED_FILES
    "CMakeLists.txt"
    "src/CMakeLists.txt"
    "lib/.gitignore"
)
