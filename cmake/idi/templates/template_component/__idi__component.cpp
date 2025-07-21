/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * @copyright Copyright (c) 2025 International Development & Integration Systems LLC
 *
 */

#include "@PROJECT_NAME@/@__idi_new_component_name@.hpp"
#include "@PROJECT_NAME@/public/@__idi_new_component_name@_public.h"

using namespace @__idi_namespace@;

namespace @__idi_namespace@::@__idi_new_component_name@ {
    int32_t component_function() {
        return 42;
    }
}

int32_t @__idi_new_component_name@_component_function() {
    return @__idi_new_component_name@::component_function();
}
