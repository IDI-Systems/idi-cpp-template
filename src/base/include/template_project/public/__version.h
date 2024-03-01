/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * Functions for getting the version number of the project
 *
 * @copyright Copyright (c) 2024 International Development & Integration Systems LLC
 *
 */
#pragma once

#include "export.h"
#include "@PROJECT_NAME@/public/__build_info.out.h"
#include "@PROJECT_NAME@/public/idi_version.h"

#include <stdint.h>

#ifdef __cplusplus
extern "C"
{
#endif

/**
 * Get the major version number of the current version of the project.
 * @return int32_t
 */
inline @__idi_c_caps_namespace@_EXPORT uint32_t @__idi_c_namespace@_get_version_major() {
    return @__idi_c_caps_namespace@_VERSION_MAJOR;
}

/**
 * Get the minor version number of the current version of the project.
 * @return int32_t
 */
inline @__idi_c_caps_namespace@_EXPORT uint32_t @__idi_c_namespace@_get_version_minor() {
    return @__idi_c_caps_namespace@_VERSION_MINOR;
}

/**
 * Get the patch version number of the current version of the project.
 * @return int32_t
 */
inline @__idi_c_caps_namespace@_EXPORT uint32_t @__idi_c_namespace@_get_version_patch() {
    return @__idi_c_caps_namespace@_VERSION_PATCH;
}

/**
 * Get the short version of the git hash
 *
 * @return const char *
 */
inline @__idi_c_caps_namespace@_EXPORT const char * @__idi_c_namespace@_get_git_hash_short() {
    return @__idi_c_caps_namespace@_VERSION_GIT_HASH_SHORT;
}

/**
 * Get the long version of the git hash
 *
 * @return const char *
 */
inline @__idi_c_caps_namespace@_EXPORT const char * @__idi_c_namespace@_get_git_hash_long() {
    return @__idi_c_caps_namespace@_VERSION_GIT_HASH_FULL;
}


/**
 * Get the git branch at build time
 *
 * @return const char *
 */
inline @__idi_c_caps_namespace@_EXPORT const char * @__idi_c_namespace@_get_git_branch() {
    return @__idi_c_caps_namespace@_VERSION_GIT_BRANCH;
}

/**
 * Get if the git repo is dirty at build time.
 *
 * @return true If the git repo is dirty
 * @return false If the git repo is not dirty
 */
inline @__idi_c_caps_namespace@_EXPORT bool @__idi_c_namespace@_get_git_is_dirty() {
    return (@__idi_c_caps_namespace@_VERSION_GIT_DIRTY == 1);
}

/**
 * Gets the build timestamp in UTC time
 *
 * Ex: 2022-02-04T02:04:14Z
 *
 * @return std::string reference to timestamp.
 */
inline @__idi_c_caps_namespace@_EXPORT const char * @__idi_c_namespace@_get_build_timestamp() {
    return @__idi_c_caps_namespace@_BUILD_TIMESTAMP;
}

#ifdef __cplusplus
}
#endif
