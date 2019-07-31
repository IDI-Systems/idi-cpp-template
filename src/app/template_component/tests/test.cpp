/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 * 
 * @copyright Copyright (c) 2019 International Development & Integration Systems LLC
 * 
 */
#define CATCH_CONFIG_MAIN  // This tells Catch to provide a main() - only do this in one cpp file
#include <catch2/catch.hpp>

#include "template_component.h"

TEST_CASE("Template component test CHANGE ME!!!!!!!!!", "[template_component_change_me]") {
    SECTION("Internal API calls.") {
        REQUIRE( idi::app::template_component::component_function() == 42 );
    }
}