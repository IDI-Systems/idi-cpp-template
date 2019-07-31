/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 * 
 * @copyright Copyright (c) 2019 International Development & Integration Systems LLC
 * 
 */

#include "template_component.h"
#include "public_template_component.h"

using namespace idi::app;

namespace idi::app::template_component {
    int component_function() {
        return 42;
    }
}

int idi_component_function() {
    return template_component::component_function();
}