#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2024 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

function(__idi_copy_template component_name src_dir dest_dir)
    file(GLOB template_files RELATIVE ${src_dir} ${src_dir}/*)
    foreach(template_file ${template_files})
        set(src_template_path ${src_dir}/${template_file})
        if(NOT IS_DIRECTORY ${src_template_path})
            string(REPLACE "__idi__component" ${component_name} configured_filename ${template_file})
            message(STATUS "Configuring file ${dest_dir}/${configured_filename}")
            configure_file(
                ${src_template_path}
                ${dest_dir}/${configured_filename}
                @ONLY)
        else()
            if(${template_file} MATCHES "include")
            __idi_copy_template(${component_name} ${src_template_path} ${dest_dir}/${template_file}/${IDICMAKE_PROJECT_NAME})
            else()
            __idi_copy_template(${component_name} ${src_template_path} ${dest_dir}/${template_file})
            endif()
        endif()
    endforeach()
endfunction()

macro(idi_new_component)
    if(DO_TEMPLATE_COMPONENT_TEST)
        set(NEW_COMPONENT_NAME "unit_test_component" CACHE INTERNAL "" FORCE)
    endif()

    if(NEW_COMPONENT_NAME)
        set(__idi_new_component_name "${NEW_COMPONENT_NAME}")
        set(NEW_COMPONENT_NAME 0 CACHE INTERNAL "" FORCE)
        set(template_src_dir "${PROJECT_SOURCE_DIR}/cmake/idi/templates/template_component")
        set(template_dest_dir "${PROJECT_SOURCE_DIR}/src/${__idi_new_component_name}")
        message(STATUS "Creating a new component called ${__idi_new_component_name} in ${template_dest_dir}")
        make_directory(${template_dest_dir})
        message(STATUS "Configuring directory...")
        __idi_copy_template(${__idi_new_component_name} ${template_src_dir} ${template_dest_dir})
        message(STATUS "")
        message(STATUS "Remember to add the new component subdirectorty to src/components.cmake!")
    endif()
endmacro()
