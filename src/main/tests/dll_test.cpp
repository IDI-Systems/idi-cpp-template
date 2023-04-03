/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * @copyright Copyright (c) 2023 International Development & Integration Systems LLC
 *
 */
#define CATCH_CONFIG_MAIN // This tells Catch to provide a main() - only do this in one cpp file
#include "version.h"

#include <catch2/catch.hpp>

TEST_CASE("Version numbers are correctly set and returned.", "[base]") {
    SECTION("Public API calls.") {
        REQUIRE(@__idi_c_namespace@_get_version_major() != -1);
        REQUIRE(@__idi_c_namespace@_get_version_minor() != -1);
        REQUIRE(@__idi_c_namespace@_get_version_patch() != -1);
    }
}
