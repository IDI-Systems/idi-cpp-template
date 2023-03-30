/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * @copyright Copyright (c) 2022 International Development & Integration
 *
 * Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
 *
 * License explicitly allows for relicensing of this file.
 *
 */

#define CATCH_CONFIG_MAIN // This tells Catch to provide a main() - only do this in one cpp file
#include "@__idi_new_component_name@.hpp"

#include <catch2/catch.hpp>

TEST_CASE("Template component test CHANGE ME!!!!!!!!!", "[@__idi_new_component_name@]") {
    SECTION("Internal API calls.") {
        REQUIRE(@__idi_namespace@::@__idi_new_component_name@::component_function() == 42);
    }
}
