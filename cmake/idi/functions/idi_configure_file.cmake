#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2023 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

function(idi_configure_file return_configured_name file_name)
    get_filename_component(SOURCE_FILE_DIR ${file_name} DIRECTORY)
    get_filename_component(SOURCE_FILE_WLE ${file_name} NAME_WLE)
    get_filename_component(SOURCE_FILE_EXT ${file_name} LAST_EXT)
    set(configured_name "${SOURCE_FILE_DIR}/${SOURCE_FILE_WLE}.out${SOURCE_FILE_EXT}")
    set(${return_configured_name} ${configured_name} PARENT_SCOPE)
    configure_file(${file_name} ${configured_name})
endfunction()
