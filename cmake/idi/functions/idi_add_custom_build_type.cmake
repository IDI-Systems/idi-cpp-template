#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2023 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

function(idi_add_custom_build_type config_name)

    set(oneValueArgs CONFIG_BASE CONFIG_SCRIPT)
    set(multiValueArgs CONFIG_C_FLAGS CONFIG_CXX_FLAGS CONFIG_EXE_FLAGS CONFIG_LINKER_FLAGS)
    cmake_parse_arguments(CUSTOM_TYPE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})


    string(TOUPPER ${config_name} config_name_upper)

    get_property(is_multi GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
    if(NOT is_multi)
        string(TOUPPER ${CMAKE_BUILD_TYPE} build_type_upper)
    endif()

    if(CUSTOM_TYPE_CONFIG_BASE)
        string(TOUPPER ${CUSTOM_TYPE_CONFIG_BASE} base_config_upper)
    endif()

    if(NOT "${config_name}" IN_LIST CMAKE_CONFIGURATION_TYPES)
        list(APPEND CMAKE_CONFIGURATION_TYPES ${config_name})
        set(CMAKE_CONFIGURATION_TYPES ${CMAKE_CONFIGURATION_TYPES} PARENT_SCOPE)
    endif()

    set("CMAKE_C_FLAGS_${config_name_upper}"
    "${CMAKE_C_FLAGS_${base_config_upper}} ${CUSTOM_TYPE_CONFIG_C_FLAGS}"
    PARENT_SCOPE)

    set("CMAKE_CXX_FLAGS_${config_name_upper}"
    "${CMAKE_CXX_FLAGS_${base_config_upper}} ${CUSTOM_TYPE_CONFIG_CXX_FLAGS}"
    PARENT_SCOPE)

    set("CMAKE_EXE_LINKER_FLAGS_${config_name_upper}"
    "${CMAKE_EXE_LINKER_FLAGS_${base_config_upper}} ${CUSTOM_TYPE_CONFIG_EXE_FLAGS}"
    PARENT_SCOPE)

    set("CMAKE_SHARED_LINKER_FLAGS_${config_name_upper}"
        "${CMAKE_SHARED_LINKER_FLAGS_${base_config_upper}} ${CUSTOM_TYPE_CONFIG_LINKER_FLAGS}"
    PARENT_SCOPE)

    if(CUSTOM_TYPE_CONFIG_SCRIPT)
        include(${CUSTOM_TYPE_CONFIG_SCRIPT})
    endif()

endfunction()
