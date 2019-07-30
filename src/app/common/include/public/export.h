/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 * 
 * Common defines for exporting to dynamic linked libraries.
 * 
 * @copyright Copyright (c) 2019 International Development & Integration Systems LLC
 * 
 */
#pragma once

#define IDI_DYNAMIC_LIBRARY

#ifdef IDI_DYNAMIC_LIBRARY

#ifdef _WIN32
#define DLLEXPORT __declspec(dllexport)
#endif // _WIN32

#else

#define DLLEXPORT

#endif // ACRE_CORE_DYNAMIC_LINKING