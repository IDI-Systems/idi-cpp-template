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
    constexpr int get_version_major() {
        return @__idi_c_caps_namespace@_VERSION_MAJOR;
    }

    constexpr int get_version_minor() {
        return @__idi_c_caps_namespace@_VERSION_MINOR;
    }

    constexpr int get_version_patch() {
        return @__idi_c_caps_namespace@_VERSION_PATCH;
    }

    std::string_view get_git_hash_short() {
        return @__idi_c_caps_namespace@_VERSION_GIT_HASH_SHORT;
    }

    std::string_view get_git_hash_long() {
        return @__idi_c_caps_namespace@_VERSION_GIT_HASH_FULL;
    }

    std::string_view get_git_branch() {
        return @__idi_c_caps_namespace@_VERSION_GIT_BRANCH;
    }

    constexpr bool get_git_is_dirty() {
        return (@__idi_c_caps_namespace@_VERSION_GIT_DIRTY == 1);
    }

    std::string_view get_build_timestamp() {
        return @__idi_c_caps_namespace@_BUILD_TIMESTAMP;
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
    return @__idi_c_caps_namespace@_VERSION_GIT_HASH_SHORT;
}

const char * @__idi_c_namespace@_get_git_hash_long() {
    return @__idi_c_caps_namespace@_VERSION_GIT_HASH_FULL;
}

const char * @__idi_c_namespace@_get_git_branch() {
    return @__idi_c_caps_namespace@_VERSION_GIT_BRANCH;
}

bool @__idi_c_namespace@_get_git_is_dirty() {
    return base::get_git_is_dirty();
}

const char * @__idi_c_namespace@_get_build_timestamp() {
    return @__idi_c_caps_namespace@_BUILD_TIMESTAMP;
}

#ifdef __cplusplus
}
#endif
