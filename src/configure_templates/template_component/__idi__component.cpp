/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 * 
 * @copyright Copyright (c) 2019 International Development & Integration Systems LLC
 * 
 */

#include "template_component.h"
#include "public_template_component.h"

using namespace @__idi_vendor_namespace@::@__idi_app_namespace@;

namespace @__idi_vendor_namespace@::@__idi_app_namespace@::@__idi_new_component_name@ {
    int component_function() {
        return 42;
    }
}

int @__idi_new_component_name@_component_function() {
    return @__idi_new_component_name@::component_function();
}