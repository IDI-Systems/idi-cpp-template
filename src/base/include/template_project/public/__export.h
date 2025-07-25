/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * Common defines for exporting to shared libraries.
 *
 * @copyright Copyright (c) 2025 International Development & Integration Systems LLC
 *
 */
// NOLINTBEGIN
#pragma once

#include "platform_config.h"

#ifdef @__idi_c_caps_namespace@_IS_LIBRARY

#ifdef _WIN32
#define @__idi_c_caps_namespace@_EXPORT __declspec(dllexport)
#else
#define @__idi_c_caps_namespace@_EXPORT __attribute__((visibility("default")))
#endif // _WIN32

#else

#define @__idi_c_caps_namespace@_EXPORT

#endif // @__idi_c_caps_namespace@_IS_LIBRARY
// NOLINTEND
