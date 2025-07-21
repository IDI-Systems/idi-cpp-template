#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2025 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/idi/version.cmake)

include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/idi/updater/updater.cmake")

if(NOT IDICMAKE_DID_UPDATE AND NOT IDICMAKE_TEMPLATE_LOADED)
    if (IDICMAKE_ROOT_CML_V LESS IDICMAKE_ROOT_REQ_CML_V)
        message(FATAL_ERROR "The root CMakeLists.txt is not at the required version for the IDI CMake framework."
        "If you updated the template recently, also update the CMakeList.txt in the root directory")
    endif()

    if (IDICMAKE_SRC_CML_V LESS IDICMAKE_SRC_REQ_CML_V)
        message(FATAL_ERROR "The CMakeLists.txt in the src directory is not at the required version for the IDI CMake framework."
        "If you updated the template recently, also update the CMakeList.txt in the src directory")
    endif()

    if (IDICMAKE_BASE_CML_V LESS IDICMAKE_BASE_REQ_CML_V)
        message(FATAL_ERROR "The CMakeLists.txt in the src/base component directory is not at the required version for the IDI CMake framework."
        "If you updated the template recently, also update the CMakeList.txt in the src/base component directory")
    endif()

    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/idi/functions/idi_add_dependency.cmake)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/idi/functions/idi_add_sources.cmake)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/idi/functions/idi_add_subdirectory.cmake)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/idi/functions/idi_component_test.cmake)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/idi/functions/idi_component.cmake)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/idi/functions/idi_configure_file.cmake)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/idi/functions/idi_demo.cmake)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/idi/functions/idi_target_compile_settings.cmake)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/idi/functions/idi_platform_config.cmake)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/idi/functions/misc.cmake)

    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/idi/functions/framework/idi_configure_base_includes.cmake)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/idi/functions/framework/idi_init.cmake)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/idi/functions/framework/idi_load_platform_config.cmake)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/idi/functions/framework/idi_main.cmake)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/idi/functions/framework/idi_new_component.cmake)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/idi/functions/framework/idi_src.cmake)

    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/idi/third-party/code-coverage.cmake)

    set(IDICMAKE_TEMPLATE_LOADED true)
endif()
