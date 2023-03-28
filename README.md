# IDI C++ Project Template

This is a template for starting new C++ projects that conform to the IDI C++ project structure requirements.

## Setup

### Requirements

- CMake >= 3.23
- GCC 11+ / Clang 11+ / MSVC (VS2019+)

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

## Concepts

The template is based on around a very generalized and flexible CMake framework for building executables, shared libraries, and static libraries that are cross platform for Linux and Windows (Mac OS support is possible in the near future).

### Target Construction

Targets are built around collections of object libaries that are then combined into a static or shared library depending on the project's main type. If the target is an executable, then all object files are still built to a core shared library and the final executable linked against it.

### Components

The object libraries that are used to build these final targets are called "components" in the language of the framework. There is one defualt component called `common` that provides boilerplate versioning and other useful information related to project configuration. Additional components can be added via calling CMake configuration with the `-DNEW_COMPONENT_NAME=component_name` flag. This will generate a boilerplate new component that can be built up and added to the `components.cmake` file in the `src` folder.

#### Component Files

A component includes a `CMakeLists.txt` file that contains the component definition call. See the documentation below on the CMake `idi_component` function for more details.

Alongside the `CMakeLists.txt` file is is an `objects.cmake`. This file is where source files for the object library are added. See the documentation on the CMake function `idi_add_sources` for more information.

### Component Includes

Includes are structured in a specific way to easily enable the installation or inclusion of headers from the project in other projects.

The include folder in each component contains exactly one subfolder that is named after the CMake `IDI_PROJECT_NAME` configuration value. Inside that folder exists any interface header files that can be used with **static** libraries. In addition, a folder called `public` contains any headers that are used as header interfaces to a **shared** library. These generally will be C exported interfaces for shared object ABI compatibility.

Any header files that are not to be consumed by end-users should _not_ be included in the `include` folder structure. Those headers will remain private to the project and it's components (there is currently no way to restrict headers to _just_ the component in which it lives).

```
src/
 |--- some_component/
   |--- some_implementation.cpp         # built as part of the object
     |--- include/
       |--- project_name/               # actual folder name via the IDI_PROJECT_NAME var
         |--- some_implementation.hpp   # static library avaialable header
         |--- public/
           |--- exported_impl.h         # C exported function headers for shared lib
 ```

 ### Component Include Files

The `include/project_name` folder will also include a `include.cmake` file that declares the header files. This file also includes the `public/public.cmake` file. See the documentation below for `idi_add_includes` and `idi_add_public_includes` respectively for more information.

### Tests

Tests are contained in the component's `tests` folder. See `idi_component_test` and `idi_component_test_public` function documentation below for more information on how tests can be added. Tests are built around CTest and use Catch2 by default.

## Documentation

WIP

## License

Template is licensed under a modified MIT License. See the `TEMPLATE_LICENSE` file for more information!
