/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 *
 * Common defines for exporting to shared libraries.
 *
 * @copyright Copyright (c) 2025 International Development & Integration Systems LLC
 *
 */
// No #pragma once here, on purpose: this forwarding header is byte-identical in every project built on
// the IDI framework, and GCC treats identical #pragma once files with the same mtime as one file, so a
// translation unit including two projects' copies would silently skip the second. The configured
// header below is unique per project and carries the guard.

#include "__idi_version.out.h"
