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
#include "@__idi_new_component_name@_public.h"

#include <catch2/catch.hpp>

TEST_CASE("Template public component test CHANGE ME!!!!!!!!!", "[@__idi_new_component_name@]") {
    SECTION("Public API calls.") {
        REQUIRE(@__idi_new_component_name@_component_function() == 42);
    }
}
