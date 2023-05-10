/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * @copyright Copyright (c) 2023 International Development & Integration Systems LLC
 *
 */
#pragma once

#include "@PROJECT_NAME@/public/export.h"

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Export the template component function.
 * @return int
 */
@__idi_c_caps_namespace@_EXPORT int @__idi_new_component_name@_component_function();

#ifdef __cplusplus
}
#endif
