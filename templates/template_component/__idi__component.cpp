/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * @copyright Copyright (c) 2021 International Development & Integration Systems LLC
 *
 */

#include "@__idi_new_component_name@.h"
#include "@__idi_new_component_name@_public.h"

using namespace @__idi_vendor_namespace@::@__idi_app_namespace@;

namespace @__idi_vendor_namespace@::@__idi_app_namespace@::@__idi_new_component_name@ {
    int component_function() {
        return 42;
    }
}

int @__idi_new_component_name@_component_function() {
    return @__idi_new_component_name@::component_function();
}
