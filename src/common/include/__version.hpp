/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * @copyright Copyright (c) 2021 International Development & Integration Systems LLC
 *
 */
#pragma once

#include <string>

#include "version.h"

namespace @__idi_vendor_namespace@::@__idi_app_namespace@ {
    namespace common {
        /**
         * Get the major version number of the current version of the project.
         * 
         * @return int
         */
        int get_version_major();

        /**
         * Get the minor version number of the current version of the project.
         * 
         * @return int
         */
        int get_version_minor();

        /**
         * Get the patch version number of the current version of the project.
         * 
         * @return int
         */
        int get_version_patch();

        /**
         * Get the short version of the git hash
         * 
         * @return std::string 
         */
        const std::string& get_git_hash_short();

        /**
         * Get the long version of the git hash
         * 
         * @return std::string 
         */
        const std::string& get_git_hash_long();

        /**
         * Get the git branch at build time
         * 
         * @return std::string 
         */
        const std::string& get_git_branch();

        /**
         * Get if the git repo is dirty at build time.
         * 
         * @return true If the git repo is dirty
         * @return false If the git repo is not dirty
         */
        const bool get_git_is_dirty();
    }
}
