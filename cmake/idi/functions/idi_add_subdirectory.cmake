macro(idi_add_subdirectory src_directory expected_target)
    if(TARGET ${expected_target})
        get_target_property(__source_dir ${expected_target} SOURCE_DIR)
        message(STATUS "------- The target \"${expected_target} was already defined at ${__source_dir}")
    else()
        add_subdirectory(${src_directory} ${ARGN})
    endif()
endmacro(idi_add_subdirectory)
