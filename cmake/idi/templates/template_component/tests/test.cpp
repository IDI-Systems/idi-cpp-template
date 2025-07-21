/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * @copyright Copyright (c) 2025 International Development & Integration Systems LLC
 *
 * Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
 *
 * License explicitly allows for relicensing of this file.
 *
 */

#define CATCH_CONFIG_MAIN // This tells Catch to provide a main() - only do this in one cpp file
#include "@PROJECT_NAME@/@__idi_new_component_name@.hpp"

#include <catch2/catch_test_macros.hpp>

TEST_CASE("Template component test CHANGE ME!!!!!!!!!", "[@__idi_new_component_name@]") {
    SECTION("Internal API calls.") {
        REQUIRE(@__idi_namespace@::@__idi_new_component_name@::component_function() == 42);
    }
}
