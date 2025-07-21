/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * @copyright Copyright (c) 2025 International Development & Integration Systems LLC
 *
 */
#pragma once

#include <string>
#include <string_view>

#include "public/version.h"
#include "@PROJECT_NAME@/public/__build_info.out.h"
#include "@PROJECT_NAME@/public/idi_version.h"

#include <cstdint>

namespace @__idi_namespace@::base {
    /**
     * Get the major version number of the current version of the project.
     *
     * @return int32_t
     */
    uint32_t get_version_major();

    /**
     * Get the minor version number of the current version of the project.
     *
     * @return int32_t
     */
    uint32_t get_version_minor();

    /**
     * Get the patch version number of the current version of the project.
     *
     * @return int32_t
     */
    uint32_t get_version_patch();

    /**
     * Get the short version of the git hash
     *
     * @return std::string_view
     */
    std::string_view get_git_hash_short();

    /**
     * Get the long version of the git hash
     *
     * @return std::string_view
     */
    std::string_view get_git_hash_long();

    /**
     * Get the git branch at build time
     *
     * @return std::string_view
     */
    std::string_view get_git_branch();

    /**
     * Get if the git repo is dirty at build time.
     *
     * @return true If the git repo is dirty
     * @return false If the git repo is not dirty
     */
    bool get_git_is_dirty();

    /**
     * Gets the build timestamp in UTC time
     *
     * Ex: 2022-02-04T02:04:14Z
     *
     * @return std::string_view reference to timestamp.
     */
    std::string_view get_build_timestamp();
}
