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
#ifndef @__idi_c_caps_namespace@_VERSION_MAJOR
#define @__idi_c_caps_namespace@_VERSION_MAJOR @__idi_version_major@
#endif


#ifndef @__idi_c_caps_namespace@_VERSION_MINOR
#define @__idi_c_caps_namespace@_VERSION_MINOR @__idi_version_minor@
#endif

#ifndef @__idi_c_caps_namespace@_VERSION_PATCH
#define @__idi_c_caps_namespace@_VERSION_PATCH @__idi_version_patch@
#endif
