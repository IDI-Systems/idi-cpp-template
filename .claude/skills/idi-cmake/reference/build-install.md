# Build, options, generated headers, install, consumption

## Build

```sh
cmake -S . -B build                         # add -A x64 on Windows
cmake --build build                         # --config Debug|Release for multi-config
ctest --test-dir build -C Debug
```
Outputs (top-level builds): executables/tests in `build/bin/`, libraries in `build/lib/`.
Requires CMake ≥ 3.26 and a C++20 compiler (GCC 11+, Clang 11+, MSVC 2019+).

## Platform config variables (`platform-config.cmake`)

| Variable | Meaning |
|---|---|
| `IDICMAKE_PROJECT_NAME` | target names, include prefix, option prefix `<P>`; `idicmake` is reserved |
| `IDICMAKE_VENDOR_NAMESPACE` | C++ outer namespace (`idi`) |
| `IDICMAKE_APP_NAMESPACE` | C++ inner namespace (`app`); empty → vendor only |
| `IDICMAKE_IS_LIBRARY` | library vs executable |
| `IDICMAKE_IS_SHARED` | shared vs static (requires `IS_LIBRARY`) |

Select an alternate file with `-DIDICMAKE_PLATFORM_CONFIG=<path>` (top-level only).

## Cache options (`<P>` = upper-case project name)

| Option | Default | Effect |
|---|---|---|
| `<P>_BUILD_TESTS` | 1 top-level, 0 as subproject | build component tests |
| `<P>_BUILD_DEMOS` | 1 top-level, 0 as subproject | add `demo/` |
| `<P>_USE_GIT_VERSIONING` | 1 | git hash/branch/dirty into build info |
| `<P>_USE_BUILD_TIMESTAMPS` | 0 | UTC build time into build info |
| `<P>_FORCE_PIC` | 0 | PIC for static builds linked into a shared lib |
| `<P>_GENERATE_UMBRELLA_HEADER` | 1 | shared builds: generate `<proj>/<proj>.h` |
| `<P>_CI_GIT_BRANCH_NAME` | "" | override branch name (CI detached HEAD) |
| `<P>_DO_TEMPLATE_COMPONENT_TEST` | 0 | currently has no effect, see maintaining.md |

Non-prefixed: `NEW_COMPONENT_NAME`, `DO_TEMPLATE_COMPONENT_TEST` (scaffold and
build a throwaway `src/unit_test_component`), `CODE_COVERAGE` (no `option()`, but sticks once passed with `-D`),
`IDI_SYNC_DEPENDENCIES`, `DO_FRAMEWORK_UPDATE` + `FRAMEWORK_UPDATE_*`.
After options load, each is mirrored to `IDICMAKE_<OPTION>` (e.g. `IDICMAKE_BUILD_TESTS`) — use those in cmake code.

## Generated headers (base component)

The configured `*.out.*` files are written **into the source tree** next to their
templates and gitignored; never edit or commit them.

- `<proj>/public/export.h` → `<CNS>_EXPORT`: `__declspec(dllexport)` /
  `visibility("default")` when `<CNS>_IS_LIBRARY`, empty otherwise. Mark every
  exported C function with it. (No `dllimport` branch.) Shared builds compile with
  hidden visibility, so un-marked symbols are not exported.
- `<proj>/public/platform_config.h` → `<CNS>_PROJECT_NAME`, `_PROJECT_NAME_STR`,
  `_IS_LIBRARY`, `_IS_SHARED`, `_IS_DYNAMIC`, `_VENDOR_NAMESPACE`, `_APP_NAMESPACE`
  + anything added with `idi_platform_config()`.
- `<proj>/public/idi_version.h` → `<CNS>_VERSION_MAJOR/MINOR/PATCH` from `version.cmake`.
- `<proj>/public/version.h` → C API `<cns>_get_version_*`, `_get_git_hash_short/long`,
  `_get_git_branch`, `_get_git_is_dirty`, `_get_build_timestamp`; C++ equivalents in
  `<proj>/version.hpp` (`vendor::app::base`).
- `__build_info.out.h` is regenerated **at build time** by the `<proj>_GetBuildInfo`
  target (`cmake/idi/scripts/build-info.cmake`).
- Shared builds: umbrella header `build/generated/<proj>/<proj>.h` including every
  public header (except `__*` files); include as `"<proj>/<proj>.h"`.

## Install layout (`cmake --install build --prefix <dir>`)

- Headers: `includes/<proj>/<proj>/...` (note `includes`, not `include`). Static
  and exe builds install all `idi_add_includes` + public headers; shared builds
  install only public headers + the umbrella header.
- Executable: `RUNTIME` (`bin/`). Shared lib: `LIBRARY` (`lib/` on Linux).
- No `install(EXPORT)`, no `<proj>Config.cmake`: **`find_package(<proj>)` is not
  supported.** Static-library builds don't install the `.a`/`.lib`.

## Consuming from another project

Supported route is source inclusion:
```cmake
# in the consumer's lib/libraries.cmake (if it's an IDI project)
idi_add_first_party_dependency(mylib https://gitlab.example.com/group/mylib.git v1.2.0)
# or plain CMake
add_subdirectory(path/to/mylib)
```
As a subproject: tests and demos default off, output dirs are not overridden,
dependencies are fetched into the top-level project's `lib/`, and a second include
is skipped via `if(NOT TARGET <proj>)`.

Link targets: `<proj>` (the static or shared library), `<proj>_public` (shared:
only public headers — preferred for consumers), or individual `<proj>_<component>`
object libraries.

## CI

`.github/workflows/cpp.yml`, `.gitlab-ci.yml`, `Jenkinsfile`, `JenkinsfileTemplate`
test the **template itself** across exe/static/shared × compilers. In a derived
project, rename every `TEMPLATE_PROJECT_*` flag to `<P>_*`, rename artifacts, and
trim the matrix to what the project ships.

## New project checklist

1. `platform-config.cmake`: set `IDICMAKE_PROJECT_NAME`, namespaces, type. Update
   or delete `platform-config.{exe,static,shared}.cmake`.
2. Configure once: `src/base/include/template_project/` is renamed to `<proj>` on
   disk — commit the rename (also for any component whose include dir is renamed).
3. `version.cmake`: project version.
4. Review `platform-compile-options.cmake` (`-Werror`, `-fno-exceptions`, C++20).
5. Write `src/main/main.cpp` (exe) and add components with `-DNEW_COMPONENT_NAME=`.
6. Fix CI files (above). Replace `README.md`; keep `TEMPLATE_LICENSE` for the framework files.
7. Delete `cmake-hooks/` files you don't use (optional).
