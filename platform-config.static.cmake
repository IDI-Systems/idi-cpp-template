# EXAMPLE - Rename to platform-config.cmake to be used. This file can be deleted otherwise.
#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2025 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#
# This is a configuration file for the project platform. Set these values before
# configuration of the project. These values are also accessible via an included
# header file titled "platform_config.h"

# Set this to the name of the project. This will be the resultant binary name.
set(IDICMAKE_PROJECT_NAME "template_project")

# Set this to be the vendor namespace
set(IDICMAKE_VENDOR_NAMESPACE "idi")

# Set this to be the primary namespace within the vendor namespace
set(IDICMAKE_APP_NAMESPACE "app")

# If IDICMAKE_IS_LIBRARY is set to true the project will be built as a library.
set(IDICMAKE_IS_LIBRARY true)

# If IDICMAKE_IS_SHARED is set to true then the project will build as a shared library.
# If it is set to false it will build as a static library. This reequires
# IDICMAKE_IS_LIBRARY being set to true
set(IDICMAKE_IS_SHARED false)
