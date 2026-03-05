# IDI C++ Project Template

This is a template for starting new C++ projects that conform to the IDI C++ project structure requirements.

## Setup

### Requirements

- CMake >= 3.26
- GCC 11+ / Clang 11+ / MSVC (VS2019+)

_Dependencies are automatically fetched during CMake configuration._

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

- `IDICMAKE_PLATFORM_CONFIG` (default: `platform_config.cmake`) - Platform configuration file (only for top-level project)
- `IDICMAKE_BUILD_DEMOS` (default: `0`) - Build demo applications if applicable.
- `IDICMAKE_BUILD_TESTS` (default: `1`) - Build unit tests. _(long)_
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

The include folder in each component contains exactly one subfolder that is named after the CMake `IDICMAKE_PROJECT_NAME` configuration value. Inside that folder exists any interface header files that can be used with **static** libraries. In addition, a folder called `public` contains any headers that are used as header interfaces to a **shared** library. These generally will be C exported interfaces for shared object ABI compatibility.

Any header files that are not to be consumed by end-users should _not_ be included in the `include` folder structure. Those headers will remain private to the project and it's components (there is currently no way to restrict headers to _just_ the component in which it lives).

```
src/
 |--- some_component/
   |--- some_implementation.cpp         # built as part of the object
     |--- include/
       |--- project_name/               # actual folder name via the IDICMAKE_PROJECT_NAME var
         |--- some_implementation.hpp   # static library avaialable header
         |--- public/
           |--- exported_impl.h         # C exported function headers for shared lib
 ```

 ### Component Include Files

The `include/project_name` folder will also include a `include.cmake` file that declares the header files. This file also includes the `public/public.cmake` file. See the documentation below for `idi_add_includes` and `idi_add_public_includes` respectively for more information.

### Tests

Tests are contained in the component's `tests` folder. See `idi_component_test` and `idi_component_test_public` function documentation below for more information on how tests can be added. Tests are built around CTest and use Catch2 by default.

## Code Coverage

The framework includes built-in support for code coverage instrumentation and reporting via GCC/Clang's `--coverage` flag.

### Requirements

- **Compiler:** GCC or Clang (MSVC is not supported for coverage)
- **Report tools (at least one recommended):**
  - `lcov` + `genhtml` — generates HTML reports (preferred)
  - `gcovr` — generates HTML and/or Cobertura XML reports (useful for CI)

Install on Debian/Ubuntu:

```sh
$ sudo apt install lcov        # lcov + genhtml
$ pip install gcovr             # gcovr (alternative / CI XML reports)
```

### Usage

Enable coverage by passing `-DCODE_COVERAGE=ON` at configure time:

```sh
$ cd build
$ cmake .. -DCODE_COVERAGE=ON
```

Then run one of the coverage build targets:

| Target | Description |
|---|---|
| `ccov-all` | Run all tests and generate an aggregate HTML coverage report |
| `ccov-all-xml` | Generate a Cobertura XML report (requires `gcovr`, available when `lcov` is also present) |
| `ccov-clean` | Remove all generated coverage data and reports |

```sh
$ cmake --build . --target ccov-all
```

Reports are written to `build/reports/coverage/`:

- **HTML report:** `build/reports/coverage/html/index.html`
- **LCOV info file:** `build/reports/coverage/coverage.info`
- **Cobertura XML:** `build/reports/coverage/coverage.xml` (when using `gcovr`)

### How It Works

Coverage is integrated into the framework's component system automatically. The existing `idi_component`, `idi_component_test`, and `idi_component_test_public` functions call `target_code_coverage()` on their targets. When `CODE_COVERAGE=ON`:

1. All component object libraries and test executables are compiled with `--coverage`.
2. Test executables registered with the `ALL` flag are collected for the aggregate report.
3. At the end of configuration, the `ccov-all` target is created which runs all registered tests and produces a filtered coverage report excluding test files, third-party libraries, and system headers.

When `CODE_COVERAGE=OFF` (the default), all coverage functions are no-ops and no build overhead is added.

### Tool Priority

The report generation strategy depends on which tools are available:

1. **lcov + genhtml** — HTML report via `ccov-all`; if `gcovr` is also available, `ccov-all-xml` is added for Cobertura XML.
2. **gcovr only** — `ccov-all` produces both HTML and XML reports.
3. **Neither** — `ccov-all` runs the tests and generates raw `.gcda`/`.gcno` data files only.

## Updating the Framework

The CMake framework includes a self-update mechanism that can pull in new versions of the framework files without overwriting your project-specific code (components, configuration, etc.).

### Update Sources

The updater supports three source modes:

| Mode | Description | Required Variable |
|---|---|---|
| `url` (default) | Downloads a zip archive from a URL | `FRAMEWORK_UPDATE_URL` (defaults to the IDI template master branch on GitHub) |
| `file` | Extracts from a local zip archive | `FRAMEWORK_UPDATE_FILE_LOC` — path to the archive relative to the project root |
| `folder` | Copies from a local folder | `FRAMEWORK_UPDATE_FOLDER_LOC` — absolute path to a template project folder |

### Running an Update

Trigger an update by passing `-DDO_FRAMEWORK_UPDATE=ON` during CMake configuration:

```sh
$ cd build
$ cmake .. -DDO_FRAMEWORK_UPDATE=ON
```

This will:

1. Download/extract/copy the update source into a temporary `.idi-framework-update` directory.
2. Compare the incoming framework version against the current one.
3. If an update is available, replace the framework files (`cmake/idi/`, `src/base/`, root `CMakeLists.txt`, `src/CMakeLists.txt`, and `lib/.gitignore`).
4. Rename the base component's include directory to match your `IDICMAKE_PROJECT_NAME`.
5. Clean up the temporary directory and set `IDICMAKE_DID_UPDATE` so the rest of configuration is skipped — you must re-run `cmake ..` after an update to configure normally.

**If the framework is already up-to-date**, the updater will error out. To force a re-application of the same version:

```sh
$ cmake .. -DDO_FRAMEWORK_UPDATE=ON -DFRAMEWORK_UPDATE_FORCE=ON
```

### Specifying a Source

**From a URL (default — GitHub master):**

```sh
$ cmake .. -DDO_FRAMEWORK_UPDATE=ON
```

**From a custom URL:**

```sh
$ cmake .. -DDO_FRAMEWORK_UPDATE=ON -DFRAMEWORK_UPDATE_MODE=url \
    -DFRAMEWORK_UPDATE_URL=https://example.com/framework-v6.zip
```

**From a local zip file:**

```sh
$ cmake .. -DDO_FRAMEWORK_UPDATE=ON -DFRAMEWORK_UPDATE_MODE=file \
    -DFRAMEWORK_UPDATE_FILE_LOC=path/to/framework-update.zip
```

**From a local folder (useful during framework development):**

```sh
$ cmake .. -DDO_FRAMEWORK_UPDATE=ON -DFRAMEWORK_UPDATE_MODE=folder \
    -DFRAMEWORK_UPDATE_FOLDER_LOC=/absolute/path/to/template-project
```

### What Gets Updated

The updater replaces only the framework-managed files:

| Path | Content |
|---|---|
| `cmake/idi/` | Entire framework directory (functions, updater, templates, scripts) |
| `src/base/` | Base component boilerplate (include directory is renamed to match your project) |
| `CMakeLists.txt` | Root CMake file |
| `src/CMakeLists.txt` | Source directory CMake file |
| `lib/.gitignore` | Library gitignore |

Your project-specific files are **not touched**: `platform-config.cmake`, `platform-compile-options.cmake`, `version.cmake`, `components.cmake`, custom components, `cmake-hooks/`, `lib/libraries.cmake`, and `demo/`.

### Version Checks

After updating, the framework validates that your root and `src/` CMakeLists.txt files meet the minimum required version numbers (`IDICMAKE_ROOT_REQ_CML_V`, `IDICMAKE_SRC_REQ_CML_V`, `IDICMAKE_BASE_REQ_CML_V`). If the update replaced these files, they will already be at the correct version. If a major framework update changes the required versions, the updater will replace these files automatically.

## License

Template is licensed under a modified MIT License. See the `TEMPLATE_LICENSE` file for more information!
