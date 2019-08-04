/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 * 
 * @copyright Copyright (c) 2019 International Development & Integration Systems LLC
 * 
 */
#define CATCH_CONFIG_MAIN  // This tells Catch to provide a main() - only do this in one cpp file
#include <catch2/catch.hpp>

#include "unit_test_component_public.h"

TEST_CASE("Template public component test CHANGE ME!!!!!!!!!", "[unit_test_component]") {
    SECTION("Public API calls.") {
        REQUIRE( unit_test_component_component_function() == 42 );
    }
}
