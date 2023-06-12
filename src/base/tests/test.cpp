/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * @copyright Copyright (c) 2023 International Development & Integration Systems LLC
 *
 */
// NOLINTBEGIN
#define CATCH_CONFIG_MAIN // This tells Catch to provide a main() - only do this in one cpp file
#include "@PROJECT_NAME@/public/idi_version.h"
#include "@PROJECT_NAME@/public/__build_info.out.h"
#include "@PROJECT_NAME@/version.hpp"

#include <catch2/catch.hpp>

TEST_CASE("Version numbers are correctly set and returned.", "[base]") {
    SECTION("Internal API calls.") {
        REQUIRE(@__idi_namespace@::base::get_version_major() == @__idi_c_caps_namespace@_VERSION_MAJOR);
        REQUIRE(@__idi_namespace@::base::get_version_minor() == @__idi_c_caps_namespace@_VERSION_MINOR);
        REQUIRE(@__idi_namespace@::base::get_version_patch() == @__idi_c_caps_namespace@_VERSION_PATCH);
    }
}

TEST_CASE("Git information are correctly set and returned.", "[base]") {
    REQUIRE(@__idi_namespace@::base::get_git_hash_short() == @__idi_c_caps_namespace@_VERSION_GIT_HASH_SHORT);
    REQUIRE(@__idi_namespace@::base::get_git_hash_long() == @__idi_c_caps_namespace@_VERSION_GIT_HASH_FULL);
    REQUIRE(@__idi_namespace@::base::get_git_branch() == @__idi_c_caps_namespace@_VERSION_GIT_BRANCH);
    REQUIRE(@__idi_namespace@::base::get_git_is_dirty() == @__idi_c_caps_namespace@_VERSION_GIT_DIRTY);
    REQUIRE(@__idi_namespace@::base::get_build_timestamp() == @__idi_c_caps_namespace@_BUILD_TIMESTAMP);
}
// NOLINTEND
