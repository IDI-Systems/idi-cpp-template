/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * Common defines for exporting to shared libraries.
 *
 * @copyright Copyright (c) 2026 International Development & Integration Systems LLC
 *
 */
// NOLINTBEGIN
#pragma once

#include "platform_config.h"

#ifdef _WIN32

// @__idi_c_caps_namespace@_BUILDING_LIBRARY is defined by the framework for this project's own
// targets; consumers of the DLL get dllimport.
#if defined(@__idi_c_caps_namespace@_IS_SHARED) && defined(@__idi_c_caps_namespace@_BUILDING_LIBRARY)
#define @__idi_c_caps_namespace@_EXPORT __declspec(dllexport)
#elif defined(@__idi_c_caps_namespace@_IS_SHARED)
#define @__idi_c_caps_namespace@_EXPORT __declspec(dllimport)
#else
#define @__idi_c_caps_namespace@_EXPORT
#endif

#elif defined(@__idi_c_caps_namespace@_IS_LIBRARY)

#define @__idi_c_caps_namespace@_EXPORT __attribute__((visibility("default")))

#else

#define @__idi_c_caps_namespace@_EXPORT

#endif // _WIN32
// NOLINTEND
