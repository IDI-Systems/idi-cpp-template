/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * @copyright Copyright (c) 2021 International Development & Integration Systems LLC
 *
 */
#pragma once
#include "version.h"


namespace @__idi_vendor_namespace@::@__idi_app_namespace@ {
    namespace common {
        /**
         * Get the major version number of the current version of the project.
         * @return int
         */
        int get_version_major();

        /**
         * Get the minor version number of the current version of the project.
         * @return int
         */
        int get_version_minor();

        /**
         * Get the patch version number of the current version of the project.
         * @return int
         */
        int get_version_patch();
    }
}
