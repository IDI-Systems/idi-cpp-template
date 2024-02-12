#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2024 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

function(idi_platform_config variable type)

    set(HAS_VAR true)
    set(PLATFORM_VALUE ${${variable}})
    if(NOT ${variable})
        if (ARGC GREATER 2)
            set(PLATFORM_VALUE ${ARGV2})
        else()
            set(HAS_VAR false)
        endif()
    endif()

    set(PLATFORM_CONFIG ${${IDICMAKE_PROJECT_NAME}_PLATFORM_CONFIG_OUTPUT})

    if (NOT HAS_VAR)
        string(APPEND PLATFORM_CONFIG "// #define ${variable}\n\n")
        set("${IDICMAKE_PROJECT_NAME}_PLATFORM_CONFIG_OUTPUT" ${PLATFORM_CONFIG} PARENT_SCOPE)
        return()
    endif()



    if (type STREQUAL "RAW")
        string(APPEND PLATFORM_CONFIG "#define ${variable} ${PLATFORM_VALUE}\n\n")
    elseif (type STREQUAL "STRING")
        string(APPEND PLATFORM_CONFIG "#define ${variable} \"${PLATFORM_VALUE}\"\n\n")
    elseif (type STREQUAL "BOOL")
        if (${PLATFORM_VALUE})
            string(APPEND PLATFORM_CONFIG "#define ${variable}\n\n")
        else()
            string(APPEND PLATFORM_CONFIG "// #define ${variable}\n\n")
        endif()
    else()
        message(FATAL_ERROR "The platform configuration type: ${type} is not valid.")
    endif()

    set("${IDICMAKE_PROJECT_NAME}_PLATFORM_CONFIG_OUTPUT" ${PLATFORM_CONFIG} PARENT_SCOPE)
endfunction()
