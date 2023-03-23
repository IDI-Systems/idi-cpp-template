# IDI C++ Project Template

This is a template for starting new C++ projects that conform to the IDI C++ project structure requirements.

## Setup

### Requirements

- CMake >= 3.23
- GCC / Clang / MSVC (VS2019)

**Initialized submodules:**

```sh
$ git submodule init
$ git submodule update
```

### Build

In root of project, run the following commands:

```sh
$ mkdir build
$ cd build
$ cmake ..
$ cmake --build .   # or generated build system command (make, Visual Studio etc.)
```

**CMake arguments:**

- [Windows] `$ cmake .. -A x64` for 64-bit build (`-A Win32` for 32-bit build)
- [Windows] `$ cmake --build . --config Release` for Release mode build (`Debug` for Debug mode build)

**CMake IDI arguments:**

_Use with `cmake .. -D<argument>=<value>`._

- `IDI_PLATFORM_CONFIG` (default: `platform_config.cmake`) - Platform configuration file.
- `IDI_BUILD_DEMOS` (default: `0`) - Build demo applications if applicable.
- `IDI_BUILD_TESTS` (default: `1`) - Build unit tests. _(long)_
- `DO_TEMPLATE_COMPONENT_TEST` (default: `0`) - Generate unit test template component and build unit tests for template.
- `NEW_COMPONENT_NAME` - Create new component.

### Tests

```sh
$ ctest -C Debug
```

## License

Template is licensed under [MIT](https://github.com/IDI-Systems/idi-cpp-template/blob/master/LICENSE). When using the template, make sure you change the `LICENSE` file accordingly!
