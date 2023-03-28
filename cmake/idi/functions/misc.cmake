#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2022 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

function(idi_add_additional_files)
    foreach(var IN LISTS ARGN)
        get_filename_component(ADDITIONAL_FILE_NAME ${var} NAME)
        configure_file("${var}" "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${ADDITIONAL_FILE_NAME}" COPYONLY)
    endforeach()
endfunction()

macro(idi_cmake_hook_abs hook_path)
    include(${hook_path} OPTIONAL)
endmacro()

macro(idi_cmake_hook hook_name)
    idi_cmake_hook_abs(${PROJECT_SOURCE_DIR}/cmake-hooks/${hook_name}.cmake)
endmacro()
