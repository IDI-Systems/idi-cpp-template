/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * @copyright Copyright (c) 2021 International Development & Integration Systems LLC
 *
 */
#define CATCH_CONFIG_MAIN  // This tells Catch to provide a main() - only do this in one cpp file
#include <catch2/catch.hpp>

#include "idi_version.h"
#include "version.hpp"

TEST_CASE("Version numbers are correctly set and returned.", "[common]") {
    SECTION("Internal API calls.") {
        REQUIRE( @__idi_vendor_namespace@::@__idi_app_namespace@::common::get_version_major() == IDI_VERSION_MAJOR );
        REQUIRE( @__idi_vendor_namespace@::@__idi_app_namespace@::common::get_version_minor() == IDI_VERSION_MINOR );
        REQUIRE( @__idi_vendor_namespace@::@__idi_app_namespace@::common::get_version_patch() == IDI_VERSION_PATCH );
    }
}
