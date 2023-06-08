/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * @copyright Copyright (c) 2023 International Development & Integration Systems LLC
 *
 */

#include "@PROJECT_NAME@/version.hpp"
#include "@PROJECT_NAME@/public/__build_info.out.h"

#include <string>

namespace @__idi_namespace@::base {
    const std::string git_hash_short = @__idi_c_caps_namespace@_VERSION_GIT_HASH_SHORT;
    const std::string git_hash_long = @__idi_c_caps_namespace@_VERSION_GIT_HASH_FULL;
    const std::string git_branch = @__idi_c_caps_namespace@_VERSION_GIT_BRANCH;
    constexpr bool git_is_dirty = static_cast<bool>(@__idi_c_caps_namespace@_VERSION_GIT_DIRTY);

    const std::string build_timestamp = @__idi_c_caps_namespace@_BUILD_TIMESTAMP;

    const std::string& get_git_hash_short() noexcept {
        return git_hash_short;
    }

    const std::string& get_git_hash_long() noexcept {
        return git_hash_long;
    }

    const std::string& get_git_branch() noexcept {
        return git_branch;
    }

    bool get_git_is_dirty() noexcept {
        return git_is_dirty;
    }

    const std::string& get_build_timestamp() noexcept {
        return build_timestamp;
    }
}



using namespace @__idi_namespace@;

#ifdef __cplusplus
extern "C"
{
#endif
int32_t @__idi_c_namespace@_get_version_major() {
    return base::get_version_major();
}

int32_t @__idi_c_namespace@_get_version_minor() {
    return base::get_version_minor();
}

int32_t @__idi_c_namespace@_get_version_patch() {
    return base::get_version_patch();
}

const char * @__idi_c_namespace@_get_git_hash_short() {
    return base::git_hash_short.c_str();
}

const char * @__idi_c_namespace@_get_git_hash_long() {
    return base::git_hash_long.c_str();
}

const char * @__idi_c_namespace@_get_git_branch() {
    return base::git_branch.c_str();
}

bool @__idi_c_namespace@_get_git_is_dirty() {
    return base::git_is_dirty;
}

const char * @__idi_c_namespace@_get_build_timestamp() {
    return base::build_timestamp.c_str();
}

#ifdef __cplusplus
}
#endif
