#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2022 International Development & Integration Systems LLC
#
# These are platform compile options that will be applied to all cmake targets in the project.

list(APPEND IDI_MSVC_PRIVATE_COMPILE_OPTIONS /W4 /WX /Zc:__cplusplus /MP /std:c++latest)
list(APPEND IDI_MSVC_PRIVATE_COMPILE_DEFINITIONS _CRT_SECURE_NO_WARNINGS)
list(APPEND IDI_GNU_PRIVATE_COMPILE_OPTIONS -Wall -Wextra -Wshadow -pedantic -Werror -fno-exceptions)
list(APPEND IDI_PRIVATE_COMPILE_FEATURES cxx_std_20)
