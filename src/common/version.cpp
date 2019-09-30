/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * @copyright Copyright (c) 2019 International Development & Integration Systems LLC
 *
 */

#include "version.hpp"
#include "idi_version.h"

using namespace @__idi_vendor_namespace@::@__idi_app_namespace@;

int common::get_version_major() {
    return IDI_VERSION_MAJOR;
}

int common::get_version_minor() {
    return IDI_VERSION_MINOR;
}

int common::get_version_patch() {
    return IDI_VERSION_PATCH;
}

int @__idi_app_namespace@_get_version_major() {
    return common::get_version_major();
}

int @__idi_app_namespace@_get_version_minor() {
    return common::get_version_minor();
}

int @__idi_app_namespace@_get_version_patch() {
    return common::get_version_patch();
}
