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

TEST_CASE("Git information are correctly set and returned.", "[common]") {
    SECTION("Internal API calls.") {
        REQUIRE_THAT( @__idi_vendor_namespace@::@__idi_app_namespace@::common::get_git_hash_short(), Catch::Equals(IDI_VERSION_GIT_HASH_SHORT) );
        REQUIRE_THAT( @__idi_vendor_namespace@::@__idi_app_namespace@::common::get_git_hash_long(), Catch::Equals(IDI_VERSION_GIT_HASH_FULL) );
        REQUIRE_THAT( @__idi_vendor_namespace@::@__idi_app_namespace@::common::get_git_branch(), Catch::Equals(IDI_VERSION_GIT_BRANCH) );
        REQUIRE( @__idi_vendor_namespace@::@__idi_app_namespace@::common::get_git_is_dirty() == static_cast<const bool>(IDI_VERSION_GIT_DIRTY) );
    }
}
