/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * @copyright Copyright (c) 2023 International Development & Integration Systems LLC
 *
 */

#include "@PROJECT_NAME@/version.hpp"
#include "@PROJECT_NAME@/public/__build_info.out.h"
#include "@PROJECT_NAME@/public/idi_version.h"

#include <string>

namespace @__idi_namespace@::base {

    int get_version_major() {
        return @__idi_c_caps_namespace@_VERSION_MAJOR;
    }

    int get_version_minor() {
        return @__idi_c_caps_namespace@_VERSION_MINOR;
    }

    int get_version_patch() {
        return @__idi_c_caps_namespace@_VERSION_PATCH;
    }


    constexpr std::string_view git_hash_short = @__idi_c_caps_namespace@_VERSION_GIT_HASH_SHORT;
    constexpr std::string_view git_hash_long = @__idi_c_caps_namespace@_VERSION_GIT_HASH_FULL;
    constexpr std::string_view git_branch = @__idi_c_caps_namespace@_VERSION_GIT_BRANCH;
    constexpr bool git_is_dirty = @__idi_c_caps_namespace@_VERSION_GIT_DIRTY == 1;

    constexpr std::string_view build_timestamp = @__idi_c_caps_namespace@_BUILD_TIMESTAMP; //NOLINT

    std::string_view get_git_hash_short() {
        return git_hash_short;
    }

    std::string_view get_git_hash_long() {
        return git_hash_long;
    }

    std::string_view get_git_branch() {
        return git_branch;
    }

    bool get_git_is_dirty() {
        return git_is_dirty;
    }

    std::string_view get_build_timestamp() {
        return build_timestamp;
    }
}



using namespace @__idi_namespace@;

#ifdef __cplusplus
extern "C"
{
#endif
int @__idi_c_namespace@_get_version_major() {
    return base::get_version_major();
}

int @__idi_c_namespace@_get_version_minor() {
    return base::get_version_minor();
}

int @__idi_c_namespace@_get_version_patch() {
    return base::get_version_patch();
}

const char * @__idi_c_namespace@_get_git_hash_short() {
    return base::git_hash_short.data();
}

const char * @__idi_c_namespace@_get_git_hash_long() {
    return base::git_hash_long.data();
}

const char * @__idi_c_namespace@_get_git_branch() {
    return base::git_branch.data();
}

bool @__idi_c_namespace@_get_git_is_dirty() {
    return base::git_is_dirty;
}

const char * @__idi_c_namespace@_get_build_timestamp() {
    return base::build_timestamp.data();
}

#ifdef __cplusplus
}
#endif
