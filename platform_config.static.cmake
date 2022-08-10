#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2021 International Development & Integration Systems LLC
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

# If IDI_IS_LIBRARY is set to true the project will be built as a library.
set(IDI_IS_LIBRARY true)

# If IDI_IS_SHARED is set to true then the project will build as a shared library.
# If it is set to false it will build as a static library. This reequires
# IDI_IS_LIBRARY being set to true
set(IDI_IS_SHARED false)

# Platform compiler options can be set here.
list(APPEND IDI_MSVC_PRIVATE_COMPILE_OPTIONS /W4 /WX /Zc:__cplusplus /MP /std:c++latest)
list(APPEND IDI_MSVC_PRIVATE_COMPILE_DEFINITIONS _CRT_SECURE_NO_WARNINGS)
list(APPEND IDI_GNU_PRIVATE_COMPILE_OPTIONS -Wall -Wextra -Wshadow -pedantic -Werror -fno-exceptions)
list(APPEND IDI_PRIVATE_COMPILE_FEATURES cxx_std_20)
