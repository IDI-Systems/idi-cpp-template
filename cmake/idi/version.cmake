#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2024 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#
# This is the _framework_ version number, and is NOT related to the underlying project.
#
# Follow https://semver.org/ rules!

# Major version is required to change if there is API breaking changes!
set(IDICMAKE_CPP_FRAMEWORK_VERSION_MAJOR 4)

# Minor increments on backwards compat updates!
set(IDICMAKE_CPP_FRAMEWORK_VERSION_MINOR 0)

# Hot fixes, which should be rare in this case.
set(IDICMAKE_CPP_FRAMEWORK_VERSION_HOTFIX 0)

# The following are version numbers for the ideally static CMakeList.txt files in the root
# and src folders. If they are changed this SHALL induce a framework major version update
# as well, since it means that the framework itself is no longer a unitary update, but requires
# actions outside of the cmake folder in root.
set(IDICMAKE_ROOT_REQ_CML_V 2)
set(IDICMAKE_SRC_REQ_CML_V 1)
set(IDICMAKE_BASE_REQ_CML_V 1)
