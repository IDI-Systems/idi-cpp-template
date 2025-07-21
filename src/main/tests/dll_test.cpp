/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * @copyright Copyright (c) 2025 International Development & Integration Systems LLC
 *
 */
#define CATCH_CONFIG_MAIN // This tells Catch to provide a main() - only do this in one cpp file
#include "@PROJECT_NAME@/public/version.h"

#include <catch2/catch_test_macros.hpp>
#include <catch2/matchers/catch_matchers_all.hpp>
#include <catch2/generators/catch_generators_all.hpp>

TEST_CASE("Version number is valid.", "[main]") {
    SECTION("Public API calls.") {
        REQUIRE_FALSE((@__idi_c_namespace@_get_version_major() == 0
                    && @__idi_c_namespace@_get_version_minor() == 0
                    && @__idi_c_namespace@_get_version_patch() == 0));
    }
}
