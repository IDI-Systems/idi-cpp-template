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

_`<P>` is the upper-case project name (`IDICMAKE_PROJECT_NAME`), e.g. `TEMPLATE_PROJECT_BUILD_TESTS`._

- `IDICMAKE_PLATFORM_CONFIG` (default: `platform_config.cmake`) - Platform configuration file (only for top-level project)
- `<P>_BUILD_DEMOS` (default: `1`, `0` as a subproject) - Build demo applications if applicable.
- `<P>_BUILD_TESTS` (default: `1`, `0` as a subproject) - Build unit tests. _(long)_
- `<P>_BUILD_DOCS` (default: `1`, `0` as a subproject) - Add the `docs` target when Doxygen is found.
- `DO_TEMPLATE_COMPONENT_TEST` (default: `0`) - Generate unit test template component and build unit tests for template.
- `NEW_COMPONENT_NAME` - Create new component (or use `./new_component.sh <name>`).
- `CODE_COVERAGE` (default: `OFF`) - Coverage build, see [Code Coverage](#code-coverage).

### Tests

```sh
$ ctest -C Debug
```

### Developer Tools

Scripts for the common tasks. The `cmake/idi/tools/` ones are part of the framework and are
updated with it; each has a `.sh` (Linux/macOS) and a `.bat` (Windows) version, and `--help`.

| Script | Does |
|---|---|
| `./new_component.sh <name>` | Create a new component in `src/<name>/` |
| `cmake/idi/tools/lint.sh` | clang-format check + clang-tidy gate ([Linting](#linting)) |
| `cmake/idi/tools/coverage.sh` | Coverage build, test run and HTML report ([Code Coverage](#code-coverage)) |
| `cmake/idi/tools/docs.sh` | Doxygen API docs ([API Documentation](#api-documentation)) |
| `cmake/idi/tools/update.sh` | Guided framework update ([Updating the Framework](#updating-the-framework)) |

## Concepts

The template is based on around a very generalized and flexible CMake framework for building executables, shared libraries, and static libraries that are cross platform for Linux and Windows (Mac OS support is possible in the near future).

### Target Construction

Targets are built around collections of object libaries that are then combined into a static or shared library depending on the project's main type. If the target is an executable, then all object files are still built to a core shared library and the final executable linked against it.

### Components

The object libraries that are used to build these final targets are called "components" in the language of the framework. There is one default component called `base` that provides boilerplate versioning and other useful information related to project configuration. Additional components are created with:

```sh
$ ./new_component.sh component_name        # Windows: new_component.bat component_name
```

(the same as `cmake -S . -B build -DNEW_COMPONENT_NAME=component_name`). This generates a boilerplate component in `src/component_name/`. Then add `add_subdirectory(component_name)` to `src/components.cmake` and re-configure. Run `./new_component.sh --help` for the layout of the generated files.

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

### Header-Only Components and Contracts

A component declared with `idi_component(<name> HEADER_ONLY ...)` is an `INTERFACE` library with no sources. In a **shared** library project, a header-only component is the way to publish C++ headers that other projects compile against *without linking the shared library*: for example the port definitions, interface contracts and data types of a plugin that is loaded at run time by a loader. By convention such a component is called `contracts`, so consumers link `<project_name>_contracts`. All of its headers are installed (under `includes/<project_name>/`), not only `public` ones, and its dependencies should be header-only too.

The `<project_name>_public` target is different: it exposes the C ABI headers and links the shared library itself, so it is not for consumers of a plugin that a loader loads.

 ### Component Include Files

The `include/project_name` folder will also include a `include.cmake` file that declares the header files. This file also includes the `public/public.cmake` file. See the documentation below for `idi_add_includes` and `idi_add_public_includes` respectively for more information.

### Tests

Tests are contained in the component's `tests` folder. See `idi_component_test` and `idi_component_test_public` function documentation below for more information on how tests can be added. Tests are built around CTest and use Catch2 by default.

## Code Coverage

The framework instruments components and tests with GCC/Clang's `--coverage` flag and builds reports with lcov or gcovr.

### Requirements

- **Compiler:** GCC or Clang (MSVC has no gcov-style coverage; on Windows use clang with Ninja)
- **Report tools (at least one):**
  - `lcov` + `genhtml` — HTML report (preferred)
  - `gcovr` — HTML and Cobertura XML (for CI)

```sh
$ sudo apt install lcov        # lcov + genhtml
$ pip install gcovr             # gcovr
```

### Usage

One step, in its own `build-coverage/` directory:

```sh
$ cmake/idi/tools/coverage.sh --open                        # Windows: cmake\idi\tools\coverage.bat
$ CC=clang-21 CXX=clang++-21 cmake/idi/tools/coverage.sh    # another compiler
$ cmake/idi/tools/coverage.sh --fail-under 80               # fail below 80% line coverage
```

Or by hand: configure with `-DCODE_COVERAGE=ON` (use a separate build directory, the option sticks in the cache) and build a target:

| Target | Description |
|---|---|
| `ccov-all` | Reset counters, run all tests with `ctest`, write the HTML report (plus Cobertura XML when gcovr is installed) and print `Code Coverage: NN.NN%` |
| `ccov-all-xml` | Same test run, Cobertura XML only (requires `gcovr`; for CI) |
| `ccov-clean` | Remove the reports and reset the counters |

```sh
$ cmake -S . -B build-coverage -DCODE_COVERAGE=ON
$ cmake --build build-coverage
$ cmake --build build-coverage --target ccov-all
```

Reports are written to `<build>/reports/coverage/`: `html/index.html`, `coverage.info` (lcov) and `coverage.xml` (gcovr).

### How It Works

`idi_component`, `idi_component_test` and `idi_component_test_public` call `target_code_coverage()` on their targets. When `CODE_COVERAGE=ON`:

1. Component object libraries and test executables are compiled with `--coverage` (in Debug).
2. At the end of configuration the report targets are created. They run **every** ctest test, so tests a project registers with plain `add_test()` (scripts, system tests) count too, and a failing test fails the target.
3. Test code (`*/tests/*`), `lib/`, Catch2, `_deps` and system headers are excluded from the reports.
4. The gcov tool matches the compiler: `gcov-<major>` for GCC, `llvm-cov-<major> gcov` for Clang.

When `CODE_COVERAGE=OFF` (the default), the coverage functions do nothing.

Settings (in `cmake-hooks/post-options.cmake` or with `-D`):

| Variable | Meaning |
|---|---|
| `IDICMAKE_COVERAGE_FAIL_UNDER` | Fail the report targets below this line coverage percent |
| `IDICMAKE_COVERAGE_CTEST_ARGS` | Extra ctest arguments, e.g. `--timeout;120` |

More excludes: `set_property(GLOBAL APPEND PROPERTY IDICMAKE_COVERAGE_EXCLUDES "generated/*")` in a hook (relative patterns are relative to the project root).

In GitLab CI, `coverage: '/^Code Coverage: \d+(?:\.\d+)?%$/'` picks up the printed percentage (see `.gitlab-ci.yml`).

## Linting

clang-format and clang-tidy run over the project's own sources in `src/`, excluding the framework's `src/base/` and generated `*.out.*` files. Demos in `demo/` are not linted unless you ask for it (`--demos`, or `IDICMAKE_LINT_DEMOS`).

```sh
$ cmake/idi/tools/lint.sh                      # format check + tidy gate; Windows: cmake\idi\tools\lint.bat
$ cmake/idi/tools/lint.sh --fix --format-only  # reformat everything
$ cmake/idi/tools/lint.sh src/foo/foo.cpp      # only some files
$ cmake/idi/tools/lint.sh --clang-version 21   # same tools as CI
$ cmake/idi/tools/lint.sh --all-checks         # also report the full .clang-tidy list (advisory)
$ cmake/idi/tools/lint.sh --demos              # also lint demo/
```

The script configures and builds `build-lint/` (clang-tidy needs `compile_commands.json` and any generated sources). The same checks are available as targets in any configured build:

| Target | Description |
|---|---|
| `format` | Apply clang-format to all project files |
| `format-check` | Fail if a file is not formatted |
| `tidy` | clang-tidy with the **gate checks**; fails on any finding |
| `tidy-report` | clang-tidy with the full `.clang-tidy` check list; report only |
| `lint` | `format-check` + `tidy` |
| `install-git-hooks` | Install a pre-commit hook that checks clang-format on staged files (skip once with `git commit --no-verify`) |

The **gate** is a short list of checks that catch real bugs plus the naming rules from `.clang-tidy`. The broader `.clang-tidy` set (cppcoreguidelines, cert, hicpp, ...) is advisory. In the template's CI, `format-check` fails the pipeline and `tidy` is `allow_failure` until the project is ready to enforce it.

clang-tidy needs the Ninja or Makefile generator (Visual Studio generators do not write `compile_commands.json`); on Windows, run `lint.bat` from a Developer Command Prompt with Ninja installed.

Settings (in `cmake-hooks/post-options.cmake` or with `-D`):

| Variable | Default | Meaning |
|---|---|---|
| `IDICMAKE_CLANG_TOOLS_VERSION` | newest installed | LLVM major version of clang-format/clang-tidy |
| `IDICMAKE_LINT_DIRS` | `src` | Directories to lint |
| `IDICMAKE_LINT_DEMOS` | `OFF` | Also lint `demo/` (set `ON` in a hook to make it permanent; `lint.sh --demos` for one run) |
| `IDICMAKE_LINT_EXCLUDES` | `*.out.*;src/base/*;src/unit_test_component/*` | Project-relative globs to skip |
| `IDICMAKE_LINT_TIDY_GATE_CHECKS` | see `cmake/idi/functions/idi_lint.cmake` | clang-tidy checks the `tidy` target enforces |

### Code Style

`.clang-format` defines the layout and `.clang-tidy` the naming rules that the gate enforces:

```cpp
namespace vendor::app {                  // namespaces: lower_case
    constexpr int MAX_PEERS = 8;         // global/static/class constants: UPPER_CASE

    class PeerList {                     // classes, structs, enums, type aliases: CamelCase
    public:
        void add_peer(int peer_id);      // functions, methods, variables, parameters: lower_case

    protected:
        void _rebuild_index();           // protected/private methods and members: '_' prefix
        int _count = 0;

    private:
        bool _dirty = false;
    };
} // namespace vendor::app
```

## API Documentation

The `docs` target runs [Doxygen](https://www.doxygen.nl) with the [doxygen-awesome-css](https://github.com/jothepro/doxygen-awesome-css) theme:

```sh
$ cmake/idi/tools/docs.sh --open               # Windows: cmake\idi\tools\docs.bat --open
$ cmake --build build --target docs             # same thing
```

Output: `build/docs/html/index.html`. The headers are collected from the components automatically: a **shared** library documents each component's `include/<project>/public/` headers (the exported API) plus header-only components; **static** and **executable** builds document all of `include/<project>/`. The front page is `docs/mainpage.md` (other `docs/*.md` files become extra pages), or `README.md` if there is no `docs/mainpage.md`.

The theme is downloaded (pinned version, hash checked) the first time `docs` is built, so configuring needs no network. Use `-DIDICMAKE_DOCS_THEME=OFF` (or `docs.sh --no-theme`) for plain Doxygen output offline.

Settings (in `cmake-hooks/post-options.cmake` or with `-D`):

| Variable | Meaning |
|---|---|
| `<P>_BUILD_DOCS` | Add the `docs` target (default on for top-level builds) |
| `IDICMAKE_DOCS_THEME` | Use doxygen-awesome-css (default `ON`) |
| `IDICMAKE_DOCS_OUTPUT_DIR` | Output directory (default `<build>/docs`) |
| `IDICMAKE_DOCS_BRIEF` | One-line description under the project name |
| `IDICMAKE_DOCS_INPUTS` | Extra files/directories to document |
| `DOXYGEN_<KEY>` | Any Doxyfile setting, e.g. `set(DOXYGEN_PREDEFINED "MY_EXPORT=")`; project values win |

The template's GitLab CI publishes the docs with GitLab Pages from the default branch (`pages` job).

## Updating the Framework

The framework updates itself from a newer template without touching project code. Only the framework-owned paths are replaced:

| Path | Content |
|---|---|
| `cmake/idi/` | The framework: functions, updater, templates, scripts, tools, `CHANGELOG.md` |
| `src/base/` | Base component (its include directory is renamed to match your project) |
| `.claude/skills/idi-cmake/` | Claude Code skill describing this framework version |
| `CMakeLists.txt` | Root CMake file |
| `src/CMakeLists.txt` | Source directory CMake file |
| `lib/.gitignore` | Library gitignore |

Everything else is yours and is **not touched**: `platform-*.cmake`, `version.cmake`, `src/components.cmake`, `src/main/`, your components, `cmake-hooks/`, `lib/libraries.cmake`, `demo/`, CI files, `README.md`. Never put project changes inside the paths above (for example extra headers in `src/base/`): the update deletes them. Use a hook, a platform file or your own component instead.

The list lives in `cmake/idi/updater/managed_paths.cmake`; the changes in each release are in `cmake/idi/CHANGELOG.md`.

### Running an Update

```sh
$ cmake/idi/tools/update.sh --check     # preview only
$ cmake/idi/tools/update.sh             # Windows: cmake\idi\tools\update.bat
```

The script:

1. Refuses to run on a working tree with uncommitted changes, so the update is its own reviewable diff (`--allow-dirty` overrides).
2. Fetches the template (GitHub `master` by default) and shows the version change, every file that will change, be added or be **deleted** in the framework-owned paths, and the changelog entries since your version.
3. Asks for confirmation (`-y` to skip), then applies the update.
4. Shows the diff summary and the exact `git` command to roll back.
5. Re-configures, builds and runs the tests in `build/` (`--no-verify` to skip).
6. With `--commit`, commits the framework-owned paths as `Update IDI CMake framework <old> -> <new>`.

Sources:

```sh
$ cmake/idi/tools/update.sh --ref v6.4.0                     # a branch or tag on GitHub
$ cmake/idi/tools/update.sh --folder ../idi-cpp-template     # a local checkout
$ cmake/idi/tools/update.sh --file idi-cpp-template.zip      # a local archive
$ cmake/idi/tools/update.sh --url 'https://gitlab.example.com/idi/idi-cpp-template/-/archive/{ref}/idi-cpp-template-{ref}.zip' --ref master
```

Set `IDI_TEMPLATE_UPDATE_URL` (with `{ref}`) to make a mirror the default. If the incoming version is not newer the script stops; `--force` re-applies it. A **major** version update may need changes to project-owned files: they are listed under *Manual steps* in the changelog, and the script points them out.

**Projects on framework 6.3.2 or older** don't have the script yet. Update once with the CMake command below (6.3.2 and older can't update from a GitHub archive URL, so use a local checkout or archive of the template), then use `update.sh` from then on.

### Updating with CMake Directly

The script drives the same configure-time updater, which can also be run by hand:

```sh
$ cmake -S . -B build -DDO_FRAMEWORK_UPDATE=ON                                    # GitHub master
$ cmake -S . -B build -DDO_FRAMEWORK_UPDATE=ON -DFRAMEWORK_UPDATE_MODE=folder \
    -DFRAMEWORK_UPDATE_FOLDER_LOC=/absolute/path/to/template
$ cmake -S . -B build -DDO_FRAMEWORK_UPDATE=ON -DFRAMEWORK_UPDATE_MODE=file \
    -DFRAMEWORK_UPDATE_FILE_LOC=path/to/template.zip
$ cmake -S . -B build -DDO_FRAMEWORK_UPDATE=ON -DFRAMEWORK_UPDATE_MODE=url \
    -DFRAMEWORK_UPDATE_URL=https://example.com/template.zip
```

| Mode | Source | Variable |
|---|---|---|
| `url` (default) | Zip archive download | `FRAMEWORK_UPDATE_URL` (default: GitHub `master`) |
| `file` | Local archive | `FRAMEWORK_UPDATE_FILE_LOC` (absolute, or relative to the project root) |
| `folder` | Local template folder | `FRAMEWORK_UPDATE_FOLDER_LOC` (absolute path) |

Archives may contain the template at the top level or inside one folder (as GitHub archives do). The updater refuses to apply a version that is not newer unless `-DFRAMEWORK_UPDATE_FORCE=ON` is given. Configuration stops after the update: run cmake again to configure normally.

### Version Checks

After updating, the framework validates that your root and `src/` CMakeLists.txt files meet the minimum required version numbers (`IDICMAKE_ROOT_REQ_CML_V`, `IDICMAKE_SRC_REQ_CML_V`, `IDICMAKE_BASE_REQ_CML_V`). The updater replaces these files, so they are normally already at the required version.

## Claude Code Skill

The template ships a [Claude Code](https://claude.com/claude-code) skill in `.claude/skills/idi-cmake/`. Claude loads it automatically when working on CMake files, components, dependencies, tests, installs, or framework updates in any project built from this template (or invoke it with `/idi-cmake`). It is framework-owned and refreshed by the updater, so it always matches the project's framework version. Put project-specific notes in your own `CLAUDE.md` rather than editing the skill.

When changing the framework, update the skill in the same commit; see `.claude/skills/idi-cmake/reference/maintaining.md`.

## License

Template is licensed under a modified MIT License. See the `TEMPLATE_LICENSE` file for more information!
