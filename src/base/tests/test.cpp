/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * @copyright Copyright (c) 2024 International Development & Integration Systems LLC
 *
 */
// NOLINTBEGIN
#define CATCH_CONFIG_MAIN // This tells Catch to provide a main() - only do this in one cpp file
#include <catch2/catch_test_macros.hpp>
#include <catch2/matchers/catch_matchers_all.hpp>
#include <catch2/generators/catch_generators_all.hpp>

#include "@PROJECT_NAME@/public/idi_version.h"
#include "@PROJECT_NAME@/public/__build_info.out.h"
#include "@PROJECT_NAME@/version.hpp"

TEST_CASE("Version numbers are correctly set and returned.", "[base]") {
    SECTION("Internal API calls.") {
        REQUIRE(@__idi_namespace@::base::get_version_major() == @__idi_c_caps_namespace@_VERSION_MAJOR);
        REQUIRE(@__idi_namespace@::base::get_version_minor() == @__idi_c_caps_namespace@_VERSION_MINOR);
        REQUIRE(@__idi_namespace@::base::get_version_patch() == @__idi_c_caps_namespace@_VERSION_PATCH);
    }
}

TEST_CASE("Git information are correctly set and returned.", "[base]") {
    REQUIRE(@__idi_namespace@::base::get_git_hash_short().compare(@__idi_c_caps_namespace@_VERSION_GIT_HASH_SHORT) == 0);
    REQUIRE(@__idi_namespace@::base::get_git_hash_long().compare(@__idi_c_caps_namespace@_VERSION_GIT_HASH_FULL) == 0);
    REQUIRE(@__idi_namespace@::base::get_git_branch().compare(@__idi_c_caps_namespace@_VERSION_GIT_BRANCH) == 0);
    REQUIRE(@__idi_namespace@::base::get_git_is_dirty() == static_cast<bool>(@__idi_c_caps_namespace@_VERSION_GIT_DIRTY));
    REQUIRE(@__idi_namespace@::base::get_build_timestamp().compare(@__idi_c_caps_namespace@_BUILD_TIMESTAMP) == 0);
}
// NOLINTEND
