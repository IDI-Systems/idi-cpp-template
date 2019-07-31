cmake_minimum_required(VERSION 3.12 FATAL_ERROR)
#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2019 International Development & Integration Systems LLC
#
cmake_policy(SET CMP0079 NEW)

set(IDI_PLATFORM_CONFIG "${CMAKE_CURRENT_LIST_DIR}/platform_config.cmake" CACHE FILEPATH "Platform configuration file.")
set(IDI_BUILD_DEMOS 0 CACHE BOOL "Build demo applications if applicable.")
set(IDI_BUILD_TESTS 1 CACHE BOOL "Build unit tests.")

include("${IDI_PLATFORM_CONFIG}")

set(__idi_vendor_namespace ${IDI_VENDOR_NAMESPACE})
message("VENDOR NAMESPACE ${IDI_VENDOR_NAMESPACE}")
set(__idi_app_namespace ${IDI_APP_NAMESPACE})



# Basic configuration and pass through to src folder.
project(${IDI_PROJECT_NAME} C CXX)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/install CACHE PATH "Set the default installation path." FORCE)


include(CTest)
include("${CMAKE_CURRENT_LIST_DIR}/cmake/component.cmake")

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/reports)

function(copy_template component_name src_dir dest_dir)
    file(GLOB template_files RELATIVE ${src_dir} ${src_dir}/*)
    foreach(template_file ${template_files})
        set(src_template_path ${src_dir}/${template_file})
        if(NOT IS_DIRECTORY ${src_template_path})
            message(STATUS "Configuring file ${template_file}")
            string(REPLACE "__idi__component" ${component_name} configured_filename)
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

add_subdirectory("src")

# Needs to be wrapped in a define for building the demos or not.
if(IDI_BUILD_DEMOS) 
    add_subdirectory("demo")
endif()

