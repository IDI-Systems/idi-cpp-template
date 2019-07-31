set(IDI_PLATFORM_CONFIG "${CMAKE_SOURCE_DIR}/platform_config.cmake" CACHE FILEPATH "Platform configuration file.")
message("FUUUUUUUUUUUUUUUUUUUUUUUUUUU ${IDI_PLATFORM_CONFIG}")

if(NOT COMPONENT_NAME)
    message(FATAL_ERROR "The parameter COMPONENT_NAME needs to be set vis -DCOMPONENT_NAME=")
endif()

include(${IDI_PLATFORM_CONFIG})

set(src_dir "${CMAKE_SOURCE_DIR}/src/app/template_component")
set(dest_dir "${CMAKE_SOURCE_DIR}/src/app/${COMPONENT_NAME}")

message(STATUS "Configuring directory ${dest_dir}")
make_directory(${dest_dir})

file(GLOB template_files RELATIVE ${src_dir} ${src_dir}/*)
foreach(template_file ${template_files})
    set(src_template_path ${src_dir}/${template_file})
    if(NOT IS_DIRECTORY ${src_template_path})
        message(STATUS "Configuring file ${template_file}")
        configure_file(
                ${src_template_path}
                ${dest_dir}/${template_file}
                @ONLY)
    endif(NOT IS_DIRECTORY ${src_template_path})
endforeach(template_file)