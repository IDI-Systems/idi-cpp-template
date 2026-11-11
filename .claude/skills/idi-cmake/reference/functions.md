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
- `HEADER_ONLY` works in every build type. In a shared build it gets an `INTERFACE` include dir, no visibility
  settings, and installs all its headers (`core_includes`), not only public ones: it is the project's contract
  package (convention: a component named `contracts`, see build-install.md "Consuming"). Fixed in 6.3.1; before,
  a header-only component failed to configure in shared builds.
- `ADDITIONAL_LIBRARIES`: other components by **bare name**; links `<proj>_<component>` PUBLIC.
- `EXTERNAL_LIBRARIES`: any CMake target, linked PUBLIC (INTERFACE if header-only).
- `ADDITIONAL_INCLUDES`: `SYSTEM PRIVATE` include dirs. `ADDITIONAL_SOURCES`: PRIVATE sources.
- Requires `include/` to contain exactly one directory; renames it on disk to `<proj>` if different.
- Includes `objects.cmake`, links the component into `${IDICMAKE_CORE}`, adds `include/` as a PUBLIC include, sets up install file sets, PIC (shared or `<P>_FORCE_PIC`), hidden visibility (shared), coverage.
- `idi_component` then includes `tests/tests.cmake`.
- Sets `CURRENT_LIBRARY_NAME` / `CURRENT_LIBRARY_DIR` while `objects.cmake` and the `*-component` hooks run.
  Since 6.3.2 the `idi_component` / `idi_component_no_tests` macros also set both in the component's directory
  scope, so `tests/tests.cmake` and the rest of the component's `CMakeLists.txt` see this component's values
  (before, they saw an empty or stale value: `idi_component_setup` is a function).

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
  (with `EXCLUDE_CORE`: only `<proj>_<component>`, the component named in the call, plus whatever you list).
  `EXCLUDE_CORE` suits a `HEADER_ONLY` contracts component: the test proves the headers stand alone. Before
  6.3.2 it linked `${CURRENT_LIBRARY_NAME}`, which was empty or stale at that point, so projects linked the
  component again via `EXTERNAL_LIBRARIES <proj>_<component>`; that still works and can be dropped.
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
Components and tests already call it. Exclude globs: absolute or starting with `*`
are used as is, others are relative to the project root (also for patterns appended
directly to the `IDICMAKE_COVERAGE_EXCLUDES` global property from a hook).

Targets: `ccov-all` (reset counters, run **all** ctest tests, lcov HTML + gcovr XML
when installed, print `Code Coverage: NN.NN%`; a failing test fails it),
`ccov-all-xml` (gcovr only, XML), `ccov-clean`; output in `<build>/reports/coverage/`.
gcov tool: `gcov-<major>` (GCC), `llvm-cov-<major> gcov` (Clang). Variables:
`IDICMAKE_COVERAGE_FAIL_UNDER` (percent), `IDICMAKE_COVERAGE_CTEST_ARGS` (list).
Wrapper: `cmake/idi/tools/coverage.{sh,bat}` (own `build-coverage/` dir).

## Sanitizers — `idi_sanitizers.cmake`

```cmake
idi_sanitizers_setup()   # called by idi_init() before dependencies and src/ are added
```
`IDICMAKE_SANITIZERS` (cache list, empty = off): `address`, `undefined`, `leak`, `thread`
(`thread` not with `address`/`leak`; MSVC: `address` only). Top-level builds add
`-fsanitize=<list> -fno-omit-frame-pointer -g` (+ `-fno-sanitize-recover=undefined`) with
`add_compile_options`/`add_link_options` at the root, so components, tests, demos and
dependencies all get them. Use one build dir per set (`build-asan`, `build-tsan`).

## Lint — `idi_lint.cmake`, `scripts/lint.cmake`

```cmake
idi_lint_setup()   # called by idi_src(); defers target creation to the end of configure
```
Top-level builds only. Targets (each skipped if the name is already taken):
`format`, `format-check`, `tidy` (gate checks + `-warnings-as-errors=*`), `tidy-report`
(`.clang-tidy` Checks, never fails), `lint` (format-check + tidy), `install-git-hooks`.
All run `cmake -DLINT_CONFIG=<build>/idi-lint-config.cmake -DMODE=<mode> [-DFILES=a;b] -P cmake/idi/scripts/lint.cmake`,
as do the wrappers `cmake/idi/tools/lint.{sh,bat}` and the hook `cmake/idi/tools/pre-commit`.
Files: globbed from `IDICMAKE_LINT_DIRS` (default `src`; `demo` is added when the cache
option `IDICMAKE_LINT_DEMOS` is ON, default OFF, or with `lint.sh --demos`) at run time, minus
`IDICMAKE_LINT_EXCLUDES` (project-relative globs, default `*.out.*;src/base/*;src/unit_test_component/*`);
clang-tidy uses the `.c/.cpp` entries of `compile_commands.json` (top-level builds set
`CMAKE_EXPORT_COMPILE_COMMANDS` ON; VS generators don't write it). Gate list:
`IDICMAKE_LINT_TIDY_GATE_CHECKS` (naming via `.clang-tidy` CheckOptions + bug/perf checks).
Tool version: `IDICMAKE_CLANG_TOOLS_VERSION` (cache; empty = newest `clang-tidy-N` found);
env `CLANG_FORMAT` / `CLANG_TIDY` override. `run-clang-tidy` is run through Python when
found, else clang-tidy runs file by file. Set the variables in `cmake-hooks/post-options.cmake`.
Since 6.5.0, `tidy`/`tidy-report` first run `clang-tidy --verify-config` on the root and nested
`.clang-tidy` files (and, for `tidy`, the gate list), and `tidy` fails on a bad config or when a full
run finds no files although the lint dirs hold sources (stale `compile_commands.json`; hint when only
`demo/` has sources). `tests/` folders carry a nested `.clang-tidy` (`InheritParentConfig: true`) that
turns off `bugprone-unchecked-optional-access` and `readability-function-cognitive-complexity` for Catch2.
Silence a finding with `NOLINTNEXTLINE(<check>)` or `NOLINTBEGIN/END`, not a trailing `NOLINT`
(clang-format can wrap it onto another line).

## Docs — `idi_docs.cmake`, `scripts/docs-theme.cmake`

```cmake
idi_docs_setup()                                         # called by idi_src()
idi_docs_register_component(<component_dir> <header_only>)  # called by idi_component_setup()
```
Top-level builds with `<P>_BUILD_DOCS` on and Doxygen found get a `docs` target (not in
ALL; skipped if a `docs` target exists). Inputs: per component `include/<proj>/public/`
(shared, non-header-only) or `include/<proj>/` (otherwise); `__*.h` templates skipped,
`__*.out.h` kept; main page `docs/mainpage.md` (+ other `docs/*.md`) else `README.md`.
Uses `doxygen_add_docs()`: any `DOXYGEN_<KEY>` the project sets wins over the defaults.
Theme: doxygen-awesome-css, pinned version + SHA256, downloaded by the `docs-theme`
target at build time; `IDICMAKE_DOCS_THEME=OFF` for plain output. Also
`IDICMAKE_DOCS_OUTPUT_DIR` (default `<build>/docs`), `IDICMAKE_DOCS_BRIEF`, `IDICMAKE_DOCS_INPUTS`.
Wrapper: `cmake/idi/tools/docs.{sh,bat}`.

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
(base component only; its `<proj>_GetBuildInfo` target declares `__build_info.out.h` as a BYPRODUCT).

Other internal helpers: `idi_component_setup` (body of `idi_component`),
`idi_get_repo_information` and `idi_commit_starts_with` (dependency checkout checks).
