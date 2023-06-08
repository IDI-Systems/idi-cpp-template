/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * @copyright Copyright (c) 2023 International Development & Integration Systems LLC
 *
 */
#pragma once

#include <string>

#include "public/version.h"
#include "@PROJECT_NAME@/public/idi_version.h"

namespace @__idi_namespace@::base {
    /**
     * Get the major version number of the current version of the project.
     *
     * @return int32_t
     */
    consteval int32_t get_version_major() noexcept {
       return @__idi_c_caps_namespace@_VERSION_MAJOR;
    }

    /**
     * Get the minor version number of the current version of the project.
     *
     * @return int32_t
     */
    consteval int32_t get_version_minor() noexcept {
        return @__idi_c_caps_namespace@_VERSION_MINOR;
    }

    /**
     * Get the patch version number of the current version of the project.
     *
     * @return int32_t
     */
    consteval int32_t get_version_patch() noexcept {
        return @__idi_c_caps_namespace@_VERSION_PATCH;
    }

    /**
     * Get the short version of the git hash
     *
     * @return std::string
     */
    const std::string& get_git_hash_short() noexcept;

    /**
     * Get the long version of the git hash
     *
     * @return std::string
     */
    const std::string& get_git_hash_long() noexcept;

    /**
     * Get the git branch at build time
     *
     * @return std::string
     */
    const std::string& get_git_branch() noexcept;

    /**
     * Get if the git repo is dirty at build time.
     *
     * @return true If the git repo is dirty
     * @return false If the git repo is not dirty
     */
    bool get_git_is_dirty() noexcept;

    /**
     * Gets the build timestamp in UTC time
     *
     * Ex: 2022-02-04T02:04:14Z
     *
     * @return std::string reference to timestamp.
     */
    const std::string& get_build_timestamp() noexcept;
}
