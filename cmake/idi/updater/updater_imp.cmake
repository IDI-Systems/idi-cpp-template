

macro(do_replace_dir)
    message(STATUS "\tFramework update - Updating ${ARGV0}")
    file(REMOVE_RECURSE "${PROJECT_SOURCE_DIR}/${ARGV0}")
    file(COPY "${FRAMEWORK_UPDATE_DIR}/${ARGV0}" DESTINATION "${PROJECT_SOURCE_DIR}/${ARGV0}")
endmacro()

macro(do_replace_file)
    message(STATUS "\tFramework update - Updating ${ARGV0}")
    file(REMOVE "${PROJECT_SOURCE_DIR}/${ARGV0}")
    file(COPY_FILE "${FRAMEWORK_UPDATE_DIR}/${ARGV0}" "${PROJECT_SOURCE_DIR}/${ARGV0}")
endmacro()

do_replace_dir("cmake/idi/")
do_replace_dir("src/base/")
do_replace_file("CMakeLists.txt")
do_replace_file("src/CMakeLists.txt")
