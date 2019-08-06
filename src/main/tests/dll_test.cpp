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

#define JOIN_VENDOR_APP(A,B,C) A ## _ ## B ## _ ## C

#define __MAJOR_VERSION_CALL(VENDOR,APP)  JOIN_VENDOR_APP(VENDOR,APP,get_version_major)
#define MAJOR_VERSION_CALL __MAJOR_VERSION_CALL(IDI_VENDOR_NAMESPACE,IDI_APP_NAMESPACE)

#define __MINOR_VERSION_CALL(VENDOR,APP)  JOIN_VENDOR_APP(VENDOR,APP,get_version_minor)
#define MINOR_VERSION_CALL __MINOR_VERSION_CALL(IDI_VENDOR_NAMESPACE,IDI_APP_NAMESPACE)

#define __PATCH_VERSION_CALL(VENDOR,APP)  JOIN_VENDOR_APP(VENDOR,APP,get_version_patch)
#define PATCH_VERSION_CALL __PATCH_VERSION_CALL(IDI_VENDOR_NAMESPACE,IDI_APP_NAMESPACE)

TEST_CASE("Version numbers are correctly set and returned.", "[common]") {
    SECTION("Public API calls.") {
        REQUIRE( MAJOR_VERSION_CALL() != -1 );
        REQUIRE( MINOR_VERSION_CALL() != -1 );
        REQUIRE( PATCH_VERSION_CALL() != -1 );
    }
}
