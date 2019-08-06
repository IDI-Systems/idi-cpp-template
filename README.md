# IDI C++ Project Template

This is a template for starting new C++ projects that conform to the IDI C++ project structure requirements.

## Build Instructions

### Requirements

- CMake >= 3.12
- GCC / Clang / MSVC (VS2019)

Make sure you have initialized submodules:
```
$ git submodule init
$ git submodule update
```

From root directory of project checkout run the following commands:
```
$ mkdir build
$ cd build
$ cmake ..
$ cmake --build .   # or generated build system command (make, Visual Studio etc.)
```

Run tests:
```
$ ctest -C Debug
```
