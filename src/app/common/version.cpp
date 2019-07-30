/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 * 
 * @copyright Copyright (c) 2019 International Development & Integration Systems LLC
 * 
 */

#include "app_version.h"
#include "idi_version.h"

using namespace idi::app;

int common::get_version_major() {
    return IDI_VERSION_MAJOR;
}

int common::get_version_minor() {
    return IDI_VERSION_MINOR;
}

int common::get_version_patch() {
    return IDI_VERSION_PATCH;
}

int idi_common_get_version_major() {
    return common::get_version_major();
}

int idi_common_get_version_minor() {
    return common::get_version_minor();
}

int idi_common_get_version_patch() {
    return common::get_version_patch();
}