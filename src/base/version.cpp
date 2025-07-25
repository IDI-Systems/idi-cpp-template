/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * @copyright Copyright (c) 2025 International Development & Integration Systems LLC
 *
 */

#include "@PROJECT_NAME@/version.hpp"
#include "@PROJECT_NAME@/public/__build_info.out.h"
#include "@PROJECT_NAME@/public/idi_version.h"



namespace @__idi_namespace@::base {
    /**
     * Get the major version number of the current version of the project.
     *
     * @return int32_t
     */
    uint32_t get_version_major() {
        return @__idi_c_caps_namespace@_VERSION_MAJOR;
    }

    /**
     * Get the minor version number of the current version of the project.
     *
     * @return int32_t
     */
    uint32_t get_version_minor() {
        return @__idi_c_caps_namespace@_VERSION_MINOR;
    }

    /**
     * Get the patch version number of the current version of the project.
     *
     * @return int32_t
     */
    uint32_t get_version_patch() {
        return @__idi_c_caps_namespace@_VERSION_PATCH;
    }

    /**
     * Get the short version of the git hash
     *
     * @return std::string_view
     */
    std::string_view get_git_hash_short() {
        return @__idi_c_caps_namespace@_VERSION_GIT_HASH_SHORT;
    }

    /**
     * Get the long version of the git hash
     *
     * @return std::string_view
     */
    std::string_view get_git_hash_long() {
        return @__idi_c_caps_namespace@_VERSION_GIT_HASH_FULL;
    }

    /**
     * Get the git branch at build time
     *
     * @return std::string_view
     */
    std::string_view get_git_branch() {
        return @__idi_c_caps_namespace@_VERSION_GIT_BRANCH;
    }

    /**
     * Get if the git repo is dirty at build time.
     *
     * @return true If the git repo is dirty
     * @return false If the git repo is not dirty
     */
    bool get_git_is_dirty() {
        return (@__idi_c_caps_namespace@_VERSION_GIT_DIRTY == 1);
    }

    /**
     * Gets the build timestamp in UTC time
     *
     * Ex: 2022-02-04T02:04:14Z
     *
     * @return std::string_view reference to timestamp.
     */
    std::string_view get_build_timestamp() {
        return @__idi_c_caps_namespace@_BUILD_TIMESTAMP;
    }
}

/**
 * Get the major version number of the current version of the project.
 * @return int32_t
 */
@__idi_c_caps_namespace@_EXPORT uint32_t @__idi_c_namespace@_get_version_major() {
    return @__idi_c_caps_namespace@_VERSION_MAJOR;
}

/**
 * Get the minor version number of the current version of the project.
 * @return int32_t
 */
@__idi_c_caps_namespace@_EXPORT uint32_t @__idi_c_namespace@_get_version_minor() {
    return @__idi_c_caps_namespace@_VERSION_MINOR;
}

/**
 * Get the patch version number of the current version of the project.
 * @return int32_t
 */
@__idi_c_caps_namespace@_EXPORT uint32_t @__idi_c_namespace@_get_version_patch() {
    return @__idi_c_caps_namespace@_VERSION_PATCH;
}

/**
 * Get the short version of the git hash
 *
 * @return const char *
 */
@__idi_c_caps_namespace@_EXPORT const char * @__idi_c_namespace@_get_git_hash_short() {
    return @__idi_c_caps_namespace@_VERSION_GIT_HASH_SHORT;
}

/**
 * Get the long version of the git hash
 *
 * @return const char *
 */
@__idi_c_caps_namespace@_EXPORT const char * @__idi_c_namespace@_get_git_hash_long() {
    return @__idi_c_caps_namespace@_VERSION_GIT_HASH_FULL;
}


/**
 * Get the git branch at build time
 *
 * @return const char *
 */
@__idi_c_caps_namespace@_EXPORT const char * @__idi_c_namespace@_get_git_branch() {
    return @__idi_c_caps_namespace@_VERSION_GIT_BRANCH;
}

/**
 * Get if the git repo is dirty at build time.
 *
 * @return true If the git repo is dirty
 * @return false If the git repo is not dirty
 */
@__idi_c_caps_namespace@_EXPORT bool @__idi_c_namespace@_get_git_is_dirty() {
    return (@__idi_c_caps_namespace@_VERSION_GIT_DIRTY == 1);
}

/**
 * Gets the build timestamp in UTC time
 *
 * Ex: 2022-02-04T02:04:14Z
 *
 * @return std::string reference to timestamp.
 */
@__idi_c_caps_namespace@_EXPORT const char * @__idi_c_namespace@_get_build_timestamp() {
    return @__idi_c_caps_namespace@_BUILD_TIMESTAMP;
}
