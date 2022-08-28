#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2022 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/version.cmake)

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/functions/idi_add_sources.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/functions/idi_component_test.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/functions/idi_component.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/functions/idi_configure_file.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/functions/idi_demo.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/functions/idi_target_compile_settings.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/functions/misc.cmake)

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/functions/framework/idi_configure_common_includes.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/functions/framework/idi_init.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/functions/framework/idi_load_platform_config.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/functions/framework/idi_main.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/functions/framework/idi_new_component.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/functions/framework/idi_src.cmake)

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/third-party/code-coverage.cmake)
