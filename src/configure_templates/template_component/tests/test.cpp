/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 * 
 * @copyright Copyright (c) 2019 International Development & Integration Systems LLC
 * 
 */
#define CATCH_CONFIG_MAIN  // This tells Catch to provide a main() - only do this in one cpp file
#include <catch2/catch.hpp>

#include "@__idi_new_component_name@.h"

TEST_CASE("Template component test CHANGE ME!!!!!!!!!", "[@__idi_new_component_name@]") {
    SECTION("Internal API calls.") {
        REQUIRE( @__idi_vendor_namespace@::@__idi_app_namespace@::@__idi_new_component_name@::component_function() == 42 );
    }
}