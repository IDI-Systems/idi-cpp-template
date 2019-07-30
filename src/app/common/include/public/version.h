/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 * 
 * Functions for getting the version number of the ACRE Core Library
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
 * Get the major version number of the current version of the ACRE core library.
 * @return int 
 */
DLLEXPORT int idi_common_get_version_major();

/**
 * Get the minor version number of the current version of the ACRE core library.
 * @return int 
 */
DLLEXPORT int idi_common_get_version_minor();

/**
 * Get the patch version number of the current version of the ACRE core library.
 * @return int 
 */
DLLEXPORT int idi_common_get_version_patch();

#ifdef __cplusplus
}
#endif