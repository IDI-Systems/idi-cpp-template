# TODO: remove this set after developing
set(FRAMEWORK_UPDATE_FILE_LOC ${PROJECT_SOURCE_DIR})

macro(move_var)
    set(${ARGV1} ${${ARGV0}})
    unset(${ARGV0} CACHE)
endmacro()

macro(do_error)
    file(REMOVE_RECURSE ${__framework_update_dir})
    message(FATAL_ERROR ${ARGN})
endmacro()

set(DO_FRAMEWORK_UPDATE true)
set(FRAMEWORK_UPDATE_FORCE true)
if(DO_FRAMEWORK_UPDATE)
    include("${PROJECT_SOURCE_DIR}/cmake/idi/updater/updater_version.cmake")
    unset(DO_FRAMEWORK_UPDATE CACHE)

    move_var(FRAMEWORK_UPDATE_MODE __framework_update_mode)
    move_var(FRAMEWORK_UPDATE_FILE_LOC __framework_update_file_loc)
    move_var(FRAMEWORK_UPDATE_ALLOW_REMOTE __framework_update_allow_remote)
    move_var(FRAMEWORK_UPDATE_FORCE __framework_update_force)

    message(STATUS "Updating IDI CMake Framework!")

    set(FRAMEWORK_UPDATE_DIR "${PROJECT_SOURCE_DIR}/.idi-framework-update")

    file(REMOVE_RECURSE ${FRAMEWORK_UPDATE_DIR})
    file(MAKE_DIRECTORY ${FRAMEWORK_UPDATE_DIR})


    if(NOT __framework_update_mode)
        set(__framework_update_mode "file")
    endif()

    message(STATUS "Framework update mode: ${__framework_update_mode}")

    if(__framework_update_mode STREQUAL "file")
        if (NOT __framework_update_file_loc)
            do_error("FRAMEWORK_UPDATE_MODE is 'file', but FRAMEWORK_UPDATE_FILE_LOC is not defined!")
        endif()

        file(COPY "${__framework_update_file_loc}/" DESTINATION ${FRAMEWORK_UPDATE_DIR}
            PATTERN ".idi-framework-update" EXCLUDE
            PATTERN "build" EXCLUDE
            PATTERN ".git" EXCLUDE
            )
    elseif(__framework_update_mode STREQUAL "url")
        do_error("FRAMEWORK_UPDATE_MODE is 'url' but it is not implemented yet!")
    elseif(__framework_update_mode STREQUAL "git")
        do_error("FRAMEWORK_UPDATE_MODE is 'git' but it is not implemented yet!")
    else()
        do_error("Unknown FRAMEWORK_UPDATE_MODE '${__framework_update_mode}'!")
    endif()

    set(OLD_IDI_CPP_UPDATER_VERSION ${IDI_CPP_UPDATER_VERSION})
    set(OLD_IDI_CPP_FRAMEWORK_VERSION_MAJOR ${IDI_CPP_FRAMEWORK_VERSION_MAJOR})
    set(OLD_IDI_CPP_FRAMEWORK_VERSION_MINOR ${IDI_CPP_FRAMEWORK_VERSION_MINOR})
    set(OLD_IDI_CPP_FRAMEWORK_VERSION_HOTFIX ${IDI_CPP_FRAMEWORK_VERSION_HOTFIX})
    set(OLD_IDI_ROOT_REQ_CML_V ${IDI_ROOT_REQ_CML_V})
    set(OLD_IDI_SRC_REQ_CML_V ${IDI_SRC_REQ_CML_V})
    set(OLD_IDI_BASE_REQ_CML_V ${IDI_BASE_REQ_CML_V})

    include("${FRAMEWORK_UPDATE_DIR}/cmake/idi/updater/updater_version.cmake")
    include("${FRAMEWORK_UPDATE_DIR}/cmake/idi/updater/updater_version.cmake")

    if ((OLD_IDI_CPP_UPDATER_VERSION EQUAL IDI_CPP_UPDATER_VERSION) AND
        (OLD_IDI_CPP_FRAMEWORK_VERSION_MAJOR EQUAL IDI_CPP_FRAMEWORK_VERSION_MAJOR) AND
        (OLD_IDI_CPP_FRAMEWORK_VERSION_MINOR EQUAL IDI_CPP_FRAMEWORK_VERSION_MINOR) AND
        (OLD_IDI_CPP_FRAMEWORK_VERSION_HOTFIX EQUAL IDI_CPP_FRAMEWORK_VERSION_HOTFIX) AND
        (OLD_IDI_ROOT_REQ_CML_V EQUAL IDI_ROOT_REQ_CML_V) AND
        (OLD_IDI_SRC_REQ_CML_V EQUAL IDI_SRC_REQ_CML_V) AND
        (OLD_IDI_BASE_REQ_CML_V EQUAL IDI_BASE_REQ_CML_V)
        )
        if(NOT __framework_update_force)
            do_error("Framework is already up-to-date! Run with FRAMEWORK_UPDATE_FORCE to force an update.")
        endif()
    endif()

    if(NOT OLD_IDI_CPP_UPDATER_VERSION EQUAL IDI_CPP_UPDATER_VERSION)
        if(__framework_update_allow_remote)
            include("${__framework_update_dir}/cmake/idi/updater/updater_imp.cmake")
        else()
            do_error("The update uses a newer updater ${OLD_IDI_CPP_UPDATER_VERSION} != ${IDI_CPP_UPDATER_VERSION} "
                "and require you to execute a "
                "potentially unsafe update script. If you trust this update script please "
                "re-run the update with the FRAMEWORK_UPDATE_ALLOW_REMOTE set.")
        endif()
    else()
        include("${PROJECT_SOURCE_DIR}/cmake/idi/updater/updater_imp.cmake")
    endif()

    file(REMOVE_RECURSE ${FRAMEWORK_UPDATE_DIR})
endif()


