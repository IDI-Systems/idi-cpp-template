/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * IDI version numbers shall follow Semantic Versioning 2.0.0 https://semver.org/
 *
 * @copyright Copyright (c) 2023 International Development & Integration Systems LLC
 *
 */
#pragma once

// Below here are defines configured via CMake
#ifndef IDI_VERSION_MAJOR
#define IDI_VERSION_MAJOR @__idi_version_major@
#endif


#ifndef IDI_VERSION_MINOR
#define IDI_VERSION_MINOR @__idi_version_minor@
#endif

#ifndef IDI_VERSION_PATCH
#define IDI_VERSION_PATCH @__idi_version_patch@
#endif
