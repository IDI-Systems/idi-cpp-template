/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * @copyright Copyright (c) 2019 International Development & Integration Systems LLC
 *
 */
#define CATCH_CONFIG_MAIN  // This tells Catch to provide a main() - only do this in one cpp file
#include <catch2/catch.hpp>

#include "@__idi_new_component_name@_public.h"

TEST_CASE("Template public component test CHANGE ME!!!!!!!!!", "[@__idi_new_component_name@]") {
    SECTION("Public API calls.") {
        REQUIRE( @__idi_new_component_name@_component_function() == 42 );
    }
}
