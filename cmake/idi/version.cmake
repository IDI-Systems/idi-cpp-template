#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2022 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#
# This is the _framework_ version number, and is NOT related to the underlying project.
#
# Follow https://semver.org/ rules!

# Major version is required to change if there is API breaking changes!
set(IDI_CPP_FRAMEWORK_VERSION_MAJOR 1)

# Minor increments on backwards compat updates!
set(IDI_CPP_FRAMEWORK_VERSION_MINOR 0)

# Hot fixes, which should be rare in this case.
set(IDI_CPP_FRAMEWORK_VERSION_HOTFIX 0)

# The following are version numbers for the ideally static CMakeList.txt files in the root
# and src folders. If they are changed this SHALL induce a framework major version update
# as well, since it means that the framework itself is no longer a unitary update, but requires
# actions outside of the cmake folder in root.
set(IDI_ROOT_REQ_CML_V 1)
set(IDI_SRC_REQ_CML_V 1)
