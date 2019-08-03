/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 * 
 * Functions for getting the version number of the project
 * 
 * @copyright Copyright (c) 2019 International Development & Integration Systems LLC
 * 
 */
#pragma once

#include "export.h"

#ifdef __cplusplus
extern "C"
{
#endif

/**
 * Get the major version number of the current version of the project.
 * @return int 
 */
DLLEXPORT int @__idi_vendor_namespace@_@__idi_app_namespace@_get_version_major();

/**
 * Get the minor version number of the current version of the project.
 * @return int 
 */
DLLEXPORT int @__idi_vendor_namespace@_@__idi_app_namespace@_get_version_minor();

/**
 * Get the patch version number of the current version of the project.
 * @return int 
 */
DLLEXPORT int @__idi_vendor_namespace@_@__idi_app_namespace@_get_version_patch();

#ifdef __cplusplus
}
#endif