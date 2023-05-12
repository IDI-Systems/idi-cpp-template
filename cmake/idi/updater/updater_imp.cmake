

macro(do_replace_dir)
    message(STATUS "\tFramework update - Updating ${ARGV0}")
    file(REMOVE_RECURSE "${CMAKE_CURRENT_SOURCE_DIR}/${ARGV0}")
    file(COPY "${FRAMEWORK_UPDATE_DIR}/${ARGV0}" DESTINATION "${CMAKE_CURRENT_SOURCE_DIR}/${ARGV0}")
endmacro()

macro(do_replace_file)
    message(STATUS "\tFramework update - Updating ${ARGV0}")
    file(REMOVE "${CMAKE_CURRENT_SOURCE_DIR}/${ARGV0}")
    file(COPY_FILE "${FRAMEWORK_UPDATE_DIR}/${ARGV0}" "${CMAKE_CURRENT_SOURCE_DIR}/${ARGV0}")
endmacro()

do_replace_dir("cmake/idi/")
do_replace_dir("src/base/")
set(IDICMAKE_PLATFORM_CONFIG "${CMAKE_CURRENT_SOURCE_DIR}/platform-config.cmake")
include("${IDICMAKE_PLATFORM_CONFIG}")
file(RENAME "${CMAKE_CURRENT_SOURCE_DIR}/src/base/include/template_project" "${CMAKE_CURRENT_SOURCE_DIR}/src/base/include/${IDICMAKE_PROJECT_NAME}")
do_replace_file("CMakeLists.txt")
do_replace_file("src/CMakeLists.txt")
