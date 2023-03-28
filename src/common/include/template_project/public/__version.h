/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * Functions for getting the version number of the project
 *
 * @copyright Copyright (c) 2023 International Development & Integration Systems LLC
 *
 */
#pragma once

#include "export.h"

#ifdef __cplusplus
extern "C"
{
#endif

/**
 * Get the major version number of the current version of the project.
 * @return int
 */
IDI_EXPORT int @__idi_app_namespace@_get_version_major();

/**
 * Get the minor version number of the current version of the project.
 * @return int
 */
IDI_EXPORT int @__idi_app_namespace@_get_version_minor();

/**
 * Get the patch version number of the current version of the project.
 * @return int
 */
IDI_EXPORT int @__idi_app_namespace@_get_version_patch();

/**
 * Get the short version of the git hash
 *
 * @return const char *
 */
IDI_EXPORT const char * @__idi_app_namespace@_get_git_hash_short();

/**
 * Get the long version of the git hash
 *
 * @return const char *
 */
IDI_EXPORT const char * @__idi_app_namespace@_get_git_hash_long();

/**
 * Get the git branch at build time
 *
 * @return const char *
 */
IDI_EXPORT const char * @__idi_app_namespace@_get_git_branch();

/**
 * Get if the git repo is dirty at build time.
 *
 * @return true If the git repo is dirty
 * @return false If the git repo is not dirty
 */
IDI_EXPORT bool @__idi_app_namespace@_get_git_is_dirty();

/**
 * Gets the build timestamp in UTC time
 *
 * Ex: 2022-02-04T02:04:14Z
 *
 * @return std::string reference to timestamp.
 */
IDI_EXPORT const char * @__idi_app_namespace@_get_build_timestamp();

#ifdef __cplusplus
}
#endif
