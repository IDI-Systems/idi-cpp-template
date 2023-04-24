#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2023 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#
# This is a configuration file for the project platform. Set these values before
# configuration of the project. These values are also accessible via an included
# header file titled "platform_config.h"

# Set this to the name of the project. This will be the resultant binary name.
set(IDI_PROJECT_NAME "template_project")

# Set this to be the vendor namespace
set(IDI_VENDOR_NAMESPACE "idi")

# Set this to be the primary namespace within the vendor namespace
# If this is set to an empty string the vendor namespace will only be used
set(IDI_APP_NAMESPACE "app")

# If IDI_IS_LIBRARY is set to true the project will be built as a library.
set(IDI_IS_LIBRARY false)

# If IDI_IS_SHARED is set to true then the project will build as a shared library.
# If it is set to false it will build as a static library. This requires
# IDI_IS_LIBRARY being set to true
set(IDI_IS_SHARED false)

# If IDI_DECONFLICT_MULTIPLE is set to true, then projects that include this library
# and also use this framework will deconflict multiple versions, chosing the latest
# version.
set(IDI_DECONFLICT_MULTIPLE false)
