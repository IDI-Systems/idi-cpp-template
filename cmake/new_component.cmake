if(DO_TEMPLATE_COMPONENT_TEST)
    set(NEW_COMPONENT_NAME "unit_test_component" CACHE INTERNAL "" FORCE)
endif()

function(copy_template component_name src_dir dest_dir)
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
            copy_template(${component_name} ${src_template_path} ${dest_dir}/${template_file})
        endif()
    endforeach()
endfunction()

if(NEW_COMPONENT_NAME)
    set(__idi_new_component_name "${NEW_COMPONENT_NAME}")
    set(NEW_COMPONENT_NAME 0 CACHE INTERNAL "" FORCE)
    message("THIS IS THE NEW COMPONENT NAME: ${__idi_new_component_name}")
    set(template_src_dir "${CMAKE_SOURCE_DIR}/src/configure_templates/template_component")
    set(template_dest_dir "${CMAKE_SOURCE_DIR}/src/app/${__idi_new_component_name}")
    
    message(STATUS "Configuring directory ${template_dest_dir}")
    make_directory(${template_dest_dir})
    copy_template(${__idi_new_component_name} ${template_src_dir} ${template_dest_dir})
endif()