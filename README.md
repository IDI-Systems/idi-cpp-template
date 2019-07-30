# ACRE Core

This is the core library for ACRE.

## Build Instructions

### Requirements:
* CMake >= 3.12
* MSVC Visual Studio 2019 or newer

Make sure you have initialized submodules.

From root directory of project checkout run the following commands:
```
mkdir build
cd build
cmake ..
cmake --build .
ctest -C Debug
```