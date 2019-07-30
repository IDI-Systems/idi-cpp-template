/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 * 
 * @copyright Copyright (c) 2019 International Development & Integration Systems LLC
 * 
 */
#define CATCH_CONFIG_MAIN  // This tells Catch to provide a main() - only do this in one cpp file
#include <catch2/catch.hpp>

#include "version.h"

TEST_CASE("Version numbers are correctly set and returned.", "[common]") {
    SECTION("Public API calls.") {
        REQUIRE( idi_common_get_version_major() != -1 );
        REQUIRE( idi_common_get_version_minor() != -1 );
        REQUIRE( idi_common_get_version_patch() != -1 );
    }
}