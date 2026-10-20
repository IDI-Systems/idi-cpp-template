# Framework functions

All are defined under `cmake/idi/functions/` and loaded by
`cmake/idi/idi-template.cmake`. Names starting with `__` are internal.

**Keyword-mode parsing.** Most functions take a list where a keyword
(`ADDITIONAL_LIBRARIES`, `EXTERNAL_LIBRARIES`, `ADDITIONAL_INCLUDES`,
`ADDITIONAL_SOURCES`, …) switches the *mode* for every bare argument that
follows, until the next keyword. Flags (`HEADER_ONLY`, `NO_CATCH`, …) can appear
anywhere.

## Components — `idi_component.cmake`

```cmake
idi_component(<name> [HEADER_ONLY]
              [ADDITIONAL_LIBRARIES] <component>...   # default mode
              [EXTERNAL_LIBRARIES <target>...]
              [ADDITIONAL_INCLUDES <dir>...]
              [ADDITIONAL_SOURCES <file>...])
idi_component_no_tests(<name> ...)                    # same, skips tests/tests.cmake
```
- Creates `${IDICMAKE_PROJECT_NAME}_<name>`: `OBJECT` library (or `INTERFACE` with `HEADER_ONLY`).
- `ADDITIONAL_LIBRARIES`: other components by **bare name**; links `<proj>_<component>` PUBLIC.
- `EXTERNAL_LIBRARIES`: any CMake target, linked PUBLIC (INTERFACE if header-only).
- `ADDITIONAL_INCLUDES`: `SYSTEM PRIVATE` include dirs. `ADDITIONAL_SOURCES`: PRIVATE sources.
- Requires `include/` to contain exactly one directory; renames it on disk to `<proj>` if different.
- Includes `objects.cmake`, links the component into `${IDICMAKE_CORE}`, adds `include/` as a PUBLIC include, sets up install file sets, PIC (shared or `<P>_FORCE_PIC`), hidden visibility (shared), coverage.
- `idi_component` then includes `tests/tests.cmake`.
- Sets `CURRENT_LIBRARY_NAME` / `CURRENT_LIBRARY_DIR` while `objects.cmake` and the `*-component` hooks run.

## Sources and headers — `idi_add_sources.cmake`

```cmake
idi_add_sources([INTERNAL|EXTERNAL|INTERNAL_CONFIGURE|EXTERNAL_CONFIGURE] <file>...)
idi_add_includes(...)          # same modes; also adds to FILE_SET core_includes
idi_add_public_includes(...)   # same modes; adds to core_includes AND core_public_includes
```
- Adds files to `${CURRENT_LIBRARY_NAME}` (call only from a component's cmake files).
- Default mode `INTERNAL`. `*_CONFIGURE` runs `idi_configure_file` (plain
  `configure_file`, so `${VAR}` and `@VAR@` both expand) producing
  `<name>.out.<ext>` beside the source; the original is marked header-only.
- `idi_add_public_includes` in shared builds also records the component's
  `include/` dir on `<proj>_public` and the header in the umbrella header
  (files whose name starts with `__` are not added to the umbrella).

```cmake
idi_configure_file(<out_var> <file>)   # configure <file> -> <file stem>.out.<ext>; returns the new path
idi_add_additional_files(<file>...)    # misc.cmake: copy files (COPYONLY) into ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}, e.g. runtime data next to binaries
```

## Dependencies — `idi_add_dependency.cmake`

```cmake
idi_add_third_party_dependency(<name> <git_url> <git_tag> [DOWNLOAD_ONLY] [DEP_OPTIONS "KEY VALUE"...])
idi_add_first_party_dependency(<name> <git_url> <git_tag> [DOWNLOAD_ONLY] [DEP_OPTIONS "KEY VALUE"...])
```
- FetchContent clone into `${IDICMAKE_EXTERNAL_THIRD_PARTY_LIB_DIR}/<name>` (`lib/third-party`)
  or `${IDICMAKE_EXTERNAL_LIB_DIR}/<name>` (`lib/first-party`); build dir `_deps/<name>`.
  As a subproject of another IDI project, deps go in the **top-level** project's `lib/`.
- `<name>` should match the dependency's `project()` name; names are
  de-duplicated case-insensitively across the whole build (cache list `IDICMAKE_DEP_NAME_LIST`).
- Existing checkouts are inspected (tag/SHA/branch/dirty/behind):
  third-party is re-fetched on mismatch; first-party only **warns** unless
  `IDI_SYNC_DEPENDENCIES` is true (fatal if dirty).
- `DEP_OPTIONS "KEY VALUE"` = `set(KEY VALUE)` before the dependency's `add_subdirectory`.
- Unless `DOWNLOAD_ONLY`, the dependency is `add_subdirectory`'d (third-party as `EXCLUDE_FROM_ALL SYSTEM`).
  With `DOWNLOAD_ONLY`, define your own target, e.g.
  `add_library(asio INTERFACE)` + `target_include_directories(asio SYSTEM INTERFACE ${IDICMAKE_EXTERNAL_THIRD_PARTY_LIB_DIR}/asio/asio/include)`.

```cmake
idi_add_subdirectory(<src_dir> <expected_target> [add_subdirectory args...])  # skip if target already exists
```

## Tests — `idi_component_test.cmake`

```cmake
idi_component_test(<component> <test_file>
                   [NO_CATCH] [EXCLUDE_CORE]
                   [ADDITIONAL_SOURCES] <file>...      # default mode
                   [ADDITIONAL_LIBRARIES <component>...]
                   [EXTERNAL_LIBRARIES <target>...]
                   [ADDITIONAL_INCLUDES <dir>...])
idi_component_test_public(<component> <test_file> ...)
```
- Executable + CTest test named `<proj>_<component>_<test file stem>`, run from the runtime output dir (`build/bin`).
- Links `Catch2::Catch2WithMain` (unless `NO_CATCH`) and `${IDICMAKE_CORE}`
  (with `EXCLUDE_CORE`: only the current component `${CURRENT_LIBRARY_NAME}`).
- Only built when `<P>_BUILD_TESTS` is on. `idi_component_test` is **skipped in
  shared builds**; `idi_component_test_public` always runs — use it for tests of
  the exported C API.

## Demos — `idi_demo.cmake`

```cmake
idi_demo(<name> <file> [NO_CATCH] [EXCLUDE_CORE] [PUBLIC_ONLY]
         [ADDITIONAL_SOURCES|ADDITIONAL_LIBRARIES|EXTERNAL_LIBRARIES|ADDITIONAL_INCLUDES ...])
idi_demo_public(<name> <file> ...)   # = PUBLIC_ONLY; skipped unless shared build
```
- Target is `<name>` (no project prefix). Links Catch2WithMain by default (use `NO_CATCH` for a real `main`).
- Links core, or `<proj>_public` with `PUBLIC_ONLY`.
- Only added when `<P>_BUILD_DEMOS` is on and coverage is off.

## Platform config defines — `idi_platform_config.cmake`

```cmake
idi_platform_config(<DEFINE_NAME> RAW|STRING|BOOL [default])
```
Appends a line to the generated `<proj>/public/platform_config.h`. The value is
`${<DEFINE_NAME>}` if that variable is truthy, else `default`; with neither, a
commented-out define is written. `BOOL` writes `#define X` or `// #define X`.
Call from `cmake-hooks/post-options.cmake` (before `src/` is configured).

## Compile settings — `idi_target_compile_settings.cmake`

```cmake
idi_target_compile_settings(<target>)
```
Applies `IDICMAKE_{MSVC,GNU}_PRIVATE_COMPILE_OPTIONS`,
`IDICMAKE_MSVC_PRIVATE_COMPILE_DEFINITIONS` and `IDICMAKE_PRIVATE_COMPILE_FEATURES`
(from `platform-compile-options.cmake`) PRIVATE, wrapped by the
`pre/post-target-compile-options` hooks. Called for every framework target; call
it yourself on custom targets you want to match.

## Coverage — `idi_code_coverage.cmake`

```cmake
target_code_coverage(<target> [ALL] [OBJECTS <target>...] [EXCLUDE <glob>...])
add_code_coverage_all_targets([EXCLUDE <glob>...])
```
No-ops unless `-DCODE_COVERAGE=ON` (forces Debug; GCC/Clang only). No `option()`
is declared, but a `-D` on the command line still lands in the cache, so use a
separate build dir for coverage or pass `-DCODE_COVERAGE=OFF` to turn it off.
Components and tests already call it. Targets: `ccov-all`, `ccov-all-xml`
(gcovr + lcov present), `ccov-clean`; output in `build/reports/coverage/`.

## Hooks — `misc.cmake`

```cmake
idi_cmake_hook(<name>)          # include(${PROJECT_SOURCE_DIR}/cmake-hooks/<name>.cmake OPTIONAL)
idi_cmake_hook_abs(<path>)
```

## Framework-internal macros (`functions/framework/`)

Called by template-owned files; don't call them from project code:
`idi_load_platform_config` (root, before `project()`), `idi_init` (root),
`idi_src` (`src/CMakeLists.txt`), `idi_main` (`src/main/CMakeLists.txt`),
`idi_new_component` (from `idi_init`), `idi_configure_common_includes`
(base component only).

Other internal helpers: `idi_component_setup` (body of `idi_component`),
`idi_get_repo_information` and `idi_commit_starts_with` (dependency checkout checks).
