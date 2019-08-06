/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * Common defines for exporting to dynamic linked libraries.
 *
 * @copyright Copyright (c) 2019 International Development & Integration Systems LLC
 *
 */
#pragma once

#include "platform_config.h"

#ifdef IDI_IS_DYNAMIC

#ifdef _WIN32
#define DLLEXPORT __declspec(dllexport)
#endif // _WIN32

#else

#define DLLEXPORT

#endif // IDI_IS_DYNAMIC
