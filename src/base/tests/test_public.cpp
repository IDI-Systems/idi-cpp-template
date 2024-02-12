/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * @copyright Copyright (c) 2024 International Development & Integration Systems LLC
 *
 */
// NOLINTBEGIN
#define CATCH_CONFIG_MAIN  // This tells Catch to provide a main() - only do this in one cpp file
#include <catch2/catch.hpp>

#include "@PROJECT_NAME@/public/idi_version.h"
#include "@PROJECT_NAME@/public/version.h"
#include "@PROJECT_NAME@/public/__build_info.out.h"

TEST_CASE("Version numbers are correctly set and returned.", "[base]") {
    SECTION("Public API calls.") {
        REQUIRE( @__idi_c_namespace@_get_version_major() == @__idi_c_caps_namespace@_VERSION_MAJOR );
        REQUIRE( @__idi_c_namespace@_get_version_minor() == @__idi_c_caps_namespace@_VERSION_MINOR );
        REQUIRE( @__idi_c_namespace@_get_version_patch() == @__idi_c_caps_namespace@_VERSION_PATCH );
    }
}

TEST_CASE("Git information are correctly set and returned.", "[base]") {
    SECTION("Internal API calls.") {
        REQUIRE_THAT( @__idi_c_namespace@_get_git_hash_short(), Catch::Equals(@__idi_c_caps_namespace@_VERSION_GIT_HASH_SHORT) );
        REQUIRE_THAT( @__idi_c_namespace@_get_git_hash_long(), Catch::Equals(@__idi_c_caps_namespace@_VERSION_GIT_HASH_FULL) );
        REQUIRE_THAT( @__idi_c_namespace@_get_git_branch(), Catch::Equals(@__idi_c_caps_namespace@_VERSION_GIT_BRANCH) );
        REQUIRE( @__idi_c_namespace@_get_git_is_dirty() == static_cast<bool>(@__idi_c_caps_namespace@_VERSION_GIT_DIRTY) );
        REQUIRE_THAT( @__idi_c_namespace@_get_build_timestamp(), Catch::Equals(@__idi_c_caps_namespace@_BUILD_TIMESTAMP) );
    }
}
// NOLINTEND
