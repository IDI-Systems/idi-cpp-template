

macro(do_replace)
    file(REMOVE_RECURSE ${ARGV0})
    file(COPY ${ARGV1})
endmacro()
