# IDI C++ Project Template

This is a template for starting new C++ projects that conform to the IDI C++ project structure requirements.

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