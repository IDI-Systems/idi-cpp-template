#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2024 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

function(__process_source_files)
    set(__INTERNAL_FILE_LIST "${INTERNAL_FILE_LIST}")
    set(__FILE_LIST "${FILE_LIST}")
    set(ADD_MODE "INTERNAL")
    foreach(var IN LISTS ARGN)
        if(var STREQUAL "INTERNAL")
            set(ADD_MODE "INTERNAL")
        elseif(var STREQUAL "EXTERNAL")
            set(ADD_MODE "EXTERNAL")
        elseif(var STREQUAL "INTERNAL_CONFIGURE")
            set(ADD_MODE "INTERNAL_CONFIGURE")
        elseif(var STREQUAL "EXTERNAL_CONFIGURE")
            set(ADD_MODE "EXTERNAL_CONFIGURE")
        else()

            if(ADD_MODE STREQUAL "INTERNAL" OR ADD_MODE STREQUAL "INTERNAL_CONFIGURE")
                list(APPEND __INTERNAL_FILE_LIST ${var})
            endif()

            target_sources("${CURRENT_LIBRARY_NAME}" PRIVATE ${var})

            if((ADD_MODE STREQUAL "INTERNAL_CONFIGURE") OR (ADD_MODE STREQUAL "EXTERNAL_CONFIGURE"))
                idi_configure_file(CONFIGURED_FILENAME ${var})
                target_sources("${CURRENT_LIBRARY_NAME}" PRIVATE ${CONFIGURED_FILENAME})
                if(ADD_MODE STREQUAL "INTERNAL_CONFIGURE")
                    list(APPEND __INTERNAL_FILE_LIST ${CONFIGURED_FILENAME})
                    list(APPEND __FILE_LIST ${CONFIGURED_FILENAME})
                endif()
                set_source_files_properties(${var} PROPERTIES HEADER_FILE_ONLY TRUE)
            else()
                list(APPEND __FILE_LIST ${var})
            endif()

        endif()
    endforeach()

    set(INTERNAL_FILE_LIST "${__INTERNAL_FILE_LIST}" CACHE INTERNAL "INTERNAL_FILE_LIST")
    set(FILE_LIST "${__FILE_LIST}" PARENT_SCOPE)
endfunction()

macro(idi_add_sources)
    set(FILE_LIST "")
    __process_source_files(${ARGN})
endmacro()

macro(idi_add_includes)
    set(FILE_LIST "")
    __process_source_files(${ARGN})
    target_sources("${CURRENT_LIBRARY_NAME}" PUBLIC FILE_SET core_includes TYPE HEADERS BASE_DIRS ${CURRENT_LIBRARY_DIR}/include FILES ${FILE_LIST})
endmacro()

function(idi_add_public_includes)
    set(FILE_LIST "")
    __process_source_files(${ARGN})
    target_sources("${CURRENT_LIBRARY_NAME}" PUBLIC FILE_SET core_includes TYPE HEADERS BASE_DIRS ${CURRENT_LIBRARY_DIR}/include FILES ${FILE_LIST})
endfunction()
