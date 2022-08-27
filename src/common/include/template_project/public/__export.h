/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * Common defines for exporting to shared libraries.
 *
 * @copyright Copyright (c) 2022 International Development & Integration
 *
 * Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
 *
 * License explicitly allows for relicensing of this file.
 *
 */
#pragma once

#include "platform_config.h"

#ifdef IDI_IS_SHARED

#ifdef _WIN32
#define IDI_EXPORT __declspec(dllexport)
#else
#define IDI_EXPORT __attribute__((visibility("default")))
#endif // _WIN32

#else

#define IDI_EXPORT

#endif // IDI_IS_SHARED
