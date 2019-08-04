/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * @copyright Copyright (c) 2019 International Development & Integration Systems LLC
 *
 */

#include "unit_test_component.h"
#include "unit_test_component_public.h"

using namespace idi::app;

namespace idi::app::unit_test_component {
    int component_function() {
        return 42;
    }
}

int unit_test_component_component_function() {
    return unit_test_component::component_function();
}
