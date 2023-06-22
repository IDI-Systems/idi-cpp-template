#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2023 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#

function(idi_target_compile_settings compile_target)
    idi_cmake_hook(pre-target-compile-options)
    if (MSVC)
        target_compile_options("${compile_target}" PRIVATE ${IDICMAKE_MSVC_PRIVATE_COMPILE_OPTIONS})
        target_compile_definitions("${compile_target}" PRIVATE ${IDICMAKE_MSVC_PRIVATE_COMPILE_DEFINITIONS})
    else()
        target_compile_options("${compile_target}" PRIVATE ${IDICMAKE_GNU_PRIVATE_COMPILE_OPTIONS})
    endif()
    target_compile_features("${compile_target}" PRIVATE ${IDICMAKE_PRIVATE_COMPILE_FEATURES})
    idi_cmake_hook(post-target-compile-options)
endfunction()
