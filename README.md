# IDI C++ Project Template

This is a template for starting new C++ projects that conform to the IDI C++ project structure requirements.

## Build Instructions

### Requirements

- CMake >= 3.14
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

## License

Template is licensed under [MIT](https://github.com/IDI-Systems/idi-cpp-template/blob/master/LICENSE). When using the template, you are free to license your project including the derived template as you see fit.
