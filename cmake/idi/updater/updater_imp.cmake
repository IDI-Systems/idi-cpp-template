

macro(do_replace)
    file(REMOVE_RECURSE ${ARGV0})
    file(COPY ${ARGV1} DESTINATION ${ARGV0})
endmacro()

do_replace("${PROJECT_SOURCE_DIR}/cmake/idi/" "${FRAMEWORK_UPDATE_DIR}/cmake/idi/")

