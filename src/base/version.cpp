/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * @copyright Copyright (c) 2023 International Development & Integration Systems LLC
 *
 */

#include "version.hpp"
#include "public/__build_info.out.h"
#include "public/idi_version.h"

#include <string>

namespace @__idi_namespace@::base {

    int get_version_major() {
        return IDI_VERSION_MAJOR;
    }

    int get_version_minor() {
        return IDI_VERSION_MINOR;
    }

    int get_version_patch() {
        return IDI_VERSION_PATCH;
    }


    const std::string git_hash_short = IDI_VERSION_GIT_HASH_SHORT;
    const std::string git_hash_long = IDI_VERSION_GIT_HASH_FULL;
    const std::string git_branch = IDI_VERSION_GIT_BRANCH;
    const bool git_is_dirty = IDI_VERSION_GIT_DIRTY;

    const std::string build_timestamp = IDI_BUILD_TIMESTAMP;

    const std::string& get_git_hash_short() {
        return git_hash_short;
    }

    const std::string& get_git_hash_long() {
        return git_hash_long;
    }

    const std::string& get_git_branch() {
        return git_branch;
    }

    bool get_git_is_dirty() {
        return git_is_dirty;
    }

    const std::string& get_build_timestamp() {
        return build_timestamp;
    }
}



using namespace @__idi_namespace@;

#ifdef __cplusplus
extern "C"
{
#endif
int @__idi_app_namespace@_get_version_major() {
    return base::get_version_major();
}

int @__idi_app_namespace@_get_version_minor() {
    return base::get_version_minor();
}

int @__idi_app_namespace@_get_version_patch() {
    return base::get_version_patch();
}

const char * @__idi_app_namespace@_get_git_hash_short() {
    return base::git_hash_short.c_str();
}

const char * @__idi_app_namespace@_get_git_hash_long() {
    return base::git_hash_long.c_str();
}

const char * @__idi_app_namespace@_get_git_branch() {
    return base::git_branch.c_str();
}

bool @__idi_app_namespace@_get_git_is_dirty() {
    return base::git_is_dirty;
}

const char * @__idi_app_namespace@_get_build_timestamp() {
    return base::build_timestamp.c_str();
}

#ifdef __cplusplus
}
#endif
