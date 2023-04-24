include(FetchContent)

macro(move_var)
    set(${ARGV1} ${${ARGV0}})
    unset(${ARGV0} CACHE)
endmacro()

macro(do_error)
    file(REMOVE_RECURSE ${FRAMEWORK_UPDATE_DIR})
    message(FATAL_ERROR ${ARGN})
endmacro()

if(DO_FRAMEWORK_UPDATE)
    include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/idi/updater/updater_version.cmake")
    unset(DO_FRAMEWORK_UPDATE CACHE)

    move_var(FRAMEWORK_UPDATE_MODE __framework_update_mode)
    move_var(FRAMEWORK_UPDATE_FILE_LOC __framework_update_file_loc)
    move_var(FRAMEWORK_UPDATE_FOLDER_LOC __framework_update_folder_loc)
    move_var(FRAMEWORK_UPDATE_FORCE __framework_update_force)
    move_var(FRAMEWORK_UPDATE_URL __framework_update_url)

    message(STATUS "Updating IDI CMake Framework!")

    set(FRAMEWORK_UPDATE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/.idi-framework-update")

    file(REMOVE_RECURSE ${FRAMEWORK_UPDATE_DIR})
    file(MAKE_DIRECTORY ${FRAMEWORK_UPDATE_DIR})


    if(NOT __framework_update_mode)
        set(__framework_update_mode "url")
        set(__framework_update_url "https://github.com/IDI-Systems/idi-cpp-template/archive/refs/heads/master.zip")
    endif()

    message(STATUS "Framework update mode: ${__framework_update_mode}")

    if(__framework_update_mode STREQUAL "folder")
        if (NOT __framework_update_folder_loc)
            do_error("FRAMEWORK_UPDATE_MODE is 'folder', but FRAMEWORK_UPDATE_FOLDER_LOC is not defined!")
        endif()

        file(COPY "${__framework_update_folder_loc}/" DESTINATION ${FRAMEWORK_UPDATE_DIR}
            PATTERN ".idi-framework-update" EXCLUDE
            PATTERN "build" EXCLUDE
            PATTERN ".git" EXCLUDE
            )

        if(NOT (EXISTS "${FRAMEWORK_UPDATE_DIR}/cmake/idi/updater/updater_version.cmake"))
            do_error("The folder provided via FRAMEWORK_UPDATE_FOLDER_LOC does not appear to be a valid template update!")
        endif()
    elseif(__framework_update_mode STREQUAL "file")
        if (NOT __framework_update_file_loc)
            do_error("FRAMEWORK_UPDATE_MODE is 'file', but FRAMEWORK_UPDATE_FILE_LOC is not defined!")
        endif()

        file(ARCHIVE_EXTRACT INPUT "${CMAKE_CURRENT_SOURCE_DIR}/${__framework_update_file_loc}" DESTINATION ${FRAMEWORK_UPDATE_DIR})

        if(NOT (EXISTS "${FRAMEWORK_UPDATE_DIR}/cmake/idi/updater/updater_version.cmake"))
            do_error("The file provided via FRAMEWORK_UPDATE_FILE_LOC does not appear to be a valid template update!")
        endif()
    elseif(__framework_update_mode STREQUAL "url")
        file(DOWNLOAD ${__framework_update_url} "${CMAKE_CURRENT_SOURCE_DIR}/.idi_framework_dl")

        file(ARCHIVE_EXTRACT INPUT "${CMAKE_CURRENT_SOURCE_DIR}/.idi_framework_dl" DESTINATION ${FRAMEWORK_UPDATE_DIR})

        if(NOT (EXISTS "${FRAMEWORK_UPDATE_DIR}/cmake/idi/updater/updater_version.cmake"))
            do_error("The downloaded file provided via FRAMEWORK_UPDATE_URL does not appear to be a valid template update!")
        endif()
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
        include("${FRAMEWORK_UPDATE_DIR}/cmake/idi/updater/updater_imp.cmake")
    else()
        include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/idi/updater/updater_imp.cmake")
    endif()

    file(REMOVE_RECURSE ${FRAMEWORK_UPDATE_DIR})


    set(IDI_DID_UPDATE true)

endif()

