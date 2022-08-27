/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * IDI version numbers shall follow Semantic Versioning 2.0.0 https://semver.org/
 *
 * @copyright Copyright (c) 2022 International Development & Integration Systems LLC
 *
 */
#pragma once

// Below here are defines configured via CMake

#ifndef IDI_VERSION_GIT_HASH_SHORT
#define IDI_VERSION_GIT_HASH_SHORT "@__idi_version_git_hash_short@"
#endif

#ifndef IDI_VERSION_GIT_HASH_FULL
#define IDI_VERSION_GIT_HASH_FULL "@__idi_version_git_hash_long@"
#endif

#ifndef IDI_VERSION_GIT_BRANCH
#define IDI_VERSION_GIT_BRANCH "@__idi_version_git_branch@"
#endif

#ifndef IDI_VERSION_GIT_DIRTY
#define IDI_VERSION_GIT_DIRTY @__idi_version_git_is_dirty@
#endif

#ifndef IDI_BUILD_TIMESTAMP
#define IDI_BUILD_TIMESTAMP "@__idi_build_timestamp@"
#endif
