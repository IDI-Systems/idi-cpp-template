/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 * 
 * @copyright Copyright (c) 2019 International Development & Integration Systems LLC
 * 
 */
#define CATCH_CONFIG_MAIN  // This tells Catch to provide a main() - only do this in one cpp file
#include <catch2/catch.hpp>
#include "platform_config.h"
#include "version.h"

#define JOIN(A,B) A ##_## B

#define MAJOR_VERSION_CALL(VENDOR,APP)  JOIN(VENDOR, APP)_get_version_major()
#define MINOR_VERSION_CALL(VENDOR,APP)  JOIN(VENDOR, APP)_get_version_minor()
#define PATCH_VERSION_CALL(VENDOR,APP)  JOIN(VENDOR, APP)_get_version_patch()

TEST_CASE("Version numbers are correctly set and returned.", "[common]") {
    SECTION("Public API calls.") {
        REQUIRE( MAJOR_VERSION_CALL(IDI_VENDOR_NAMESPACE, IDI_APP_NAMESPACE) != -1 );
        REQUIRE( MINOR_VERSION_CALL(IDI_VENDOR_NAMESPACE, IDI_APP_NAMESPACE) != -1 );
        REQUIRE( PATCH_VERSION_CALL(IDI_VENDOR_NAMESPACE, IDI_APP_NAMESPACE) != -1 );
    }
}