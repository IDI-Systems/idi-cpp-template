/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * IDI version numbers shall follow Semantic Versioning 2.0.0 https://semver.org/
 *
 * @copyright Copyright (c) 2024 International Development & Integration Systems LLC
 *
 */
// NOLINTBEGIN
#pragma once

// Below here are defines configured via CMake

#ifndef @__idi_c_caps_namespace@_VERSION_GIT_HASH_SHORT
#define @__idi_c_caps_namespace@_VERSION_GIT_HASH_SHORT "@__idi_version_git_hash_short@"
#endif

#ifndef @__idi_c_caps_namespace@_VERSION_GIT_HASH_FULL
#define @__idi_c_caps_namespace@_VERSION_GIT_HASH_FULL "@__idi_version_git_hash_long@"
#endif

#ifndef @__idi_c_caps_namespace@_VERSION_GIT_BRANCH
#define @__idi_c_caps_namespace@_VERSION_GIT_BRANCH "@__idi_version_git_branch@"
#endif

#ifndef @__idi_c_caps_namespace@_VERSION_GIT_DIRTY
#define @__idi_c_caps_namespace@_VERSION_GIT_DIRTY @__idi_version_git_is_dirty@
#endif

#ifndef @__idi_c_caps_namespace@_BUILD_TIMESTAMP
#define @__idi_c_caps_namespace@_BUILD_TIMESTAMP "@__idi_build_timestamp@"
#endif
// NOLINTEND
