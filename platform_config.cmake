#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2019 International Development & Integration Systems LLC
#
# This is a configuration file for the project platform. Set these values before
# configuration of the project. These values are also accessible via an included
# header file titled "platform_config.h"

# Set this to the name of the project. This will be the resultant binary name.
set(IDI_PROJECT_NAME "template_project")

# Set this to be the vendor namespace
set(IDI_VENDOR_NAMESPACE "idi")

# Set this to be the primary namespace within the vendor namespace
set(IDI_APP_NAMESPACE "app")

# If IDI_IS_LIBRARY is set to 1 the project will be build as a library.
set(IDI_IS_LIBRARY 0)

# If IDI_IS_DYNAMIC is set to 1 then the project will build as a shared library.
# If it is set to 0 it will build as a static library.
set(IDI_IS_DYNAMIC 0)
