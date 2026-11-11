/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * @copyright Copyright (c) 2026 International Development & Integration Systems LLC
 *
 */
#pragma once

// ABI note: this header is the C ABI of a shared-library boundary and is consumed from C++ only. extern "C" gives
// unmangled names and plain struct layouts that stay stable across compilers and library versions. It is not meant
// to compile as C: C++ inside it (default member initializers, bool, nullptr) is intended. Keep the structs
// standard-layout and trivially copyable.

#include "@PROJECT_NAME@/public/export.h"

#include <cstdint>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Export the template component function.
 * @return int32_t
 */
@__idi_c_caps_namespace@_EXPORT int32_t @__idi_new_component_name@_component_function();

#ifdef __cplusplus
}
#endif
