/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * IDI version numbers shall follow Semantic Versioning 2.0.0 https://semver.org/
 *
 * @copyright Copyright (c) 2021 International Development & Integration Systems LLC
 *
 */
#pragma once

#ifndef IDI_VERSION_MAJOR
#define IDI_VERSION_MAJOR 0
#endif

#ifndef IDI_VERSION_MINOR
#define IDI_VERSION_MINOR 1
#endif

#ifndef IDI_VERSION_PATCH
#define IDI_VERSION_PATCH 0
#endif

// Below here are defines configured via CMake

#ifdef IDI_USE_GIT_VERSIONING

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
#define IDI_VERSION_GIT_DIRTY @__idi_version_git_is_dirty @
#endif

#else

#ifndef IDI_VERSION_GIT_HASH_SHORT
#define IDI_VERSION_GIT_HASH_SHORT ""
#endif

#ifndef IDI_VERSION_GIT_HASH_FULL
#define IDI_VERSION_GIT_HASH_FULL ""
#endif

#ifndef IDI_VERSION_GIT_BRANCH
#define IDI_VERSION_GIT_BRANCH ""
#endif

#ifndef IDI_VERSION_GIT_DIRTY
#define IDI_VERSION_GIT_DIRTY 0
#endif

#endif
