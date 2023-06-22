#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2023 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#
# These are platform compile options that will be applied to all cmake targets in the project.

set(IDICMAKE_MSVC_PRIVATE_COMPILE_OPTIONS /W4 /WX /Zc:__cplusplus /MP /std:c++latest)
set(IDICMAKE_MSVC_PRIVATE_COMPILE_DEFINITIONS _CRT_SECURE_NO_WARNINGS)
set(IDICMAKE_GNU_PRIVATE_COMPILE_OPTIONS -Wall -Wextra -Wshadow -pedantic -Werror -fno-exceptions)
set(IDICMAKE_PRIVATE_COMPILE_FEATURES cxx_std_20)
