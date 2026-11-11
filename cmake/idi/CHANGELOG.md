# IDI CMake framework changelog

Framework versions only (not the project's own version). The update tool
(`cmake/idi/tools/update.sh` / `update.bat`) prints the entries between the project's
version and the incoming one. Each release lists what changed and, under
**Manual steps**, anything a project has to change by hand in files the updater does not own.

## 6.5.0

- **Fix, lint:** build folders configured before 6.4.0 never wrote `compile_commands.json`, so
  `tidy` checked no files and passed. CMake leaves an empty `CMAKE_EXPORT_COMPILE_COMMANDS` cache
  entry in those folders, and the framework only turned it on when the variable was undefined. It
  now turns it on when the value is empty; an explicit `OFF` is kept.
- **Fix, lint:** a full `tidy` run that finds no files to check now fails when the lint folders
  hold sources (the compile database is stale or lists none of them), with a hint to re-configure.
  When only `demo/` has sources, it says to turn on `IDICMAKE_LINT_DEMOS`. `tidy-report` prints
  the same message without failing.
- **Lint:** `tidy` and `tidy-report` run `clang-tidy --verify-config` (clang-tidy 16+) on the
  root `.clang-tidy`, every `.clang-tidy` under the lint folders, and the gate list. A glob that
  matches no check or a misspelled option fails the gate; before, clang-tidy ignored it without a word.
- **Sanitizers:** new `IDICMAKE_SANITIZERS` (cache list: `address`, `undefined`, `leak`, `thread`;
  MSVC `address` only) builds every target, dependencies included, with the sanitizers so `ctest`
  runs under them. Undefined behaviour stops the program. Top-level builds only.
- **Component template:** generated components get a `tests/.clang-tidy` that turns off
  `bugprone-unchecked-optional-access` and `readability-function-cognitive-complexity` (both misfire on
  Catch2 tests), and their public header starts with a note that it is a C ABI consumed from C++ only.
- **Fix:** `<P>_DO_TEMPLATE_COMPONENT_TEST` (what CI passes) now scaffolds and builds `src/unit_test_component`;
  only the unprefixed `DO_TEMPLATE_COMPONENT_TEST` used to work, so CI never built the template component.
- **Fix, install:** the static library's archive is installed (`lib/`); shared builds install the `.so`, and on
  Windows the `.dll` and import `.lib` (the old rule named a `HEADERS` file set the target does not have). The
  generated `__build_info.out.h` is installed with the other public headers, since `version.h` includes it.
- **Fix, Windows:** `export.h` gives consumers of a shared library `__declspec(dllimport)`. The framework defines
  `<CNS>_BUILDING_LIBRARY` on every compiled component to select `dllexport` inside the project.
- **Fix:** the `src/CMakeLists.txt` and `src/base/CMakeLists.txt` version checks now run (in `idi_src()` and
  `idi_component(base)`); before, they ran before those files had set their version and never fired.
- **Fix:** a relative `IDICMAKE_PLATFORM_CONFIG` is tried against the directory cmake runs in, then the build dir,
  then the source dir; configure stops with the list of paths tried if none exists.
- The base C API (`version.h`) uses `(void)` prototypes and includes `<stdbool.h>`, so it compiles as C.

### Manual steps

Check the config first: `tidy` now fails on a `.clang-tidy` problem it used to ignore. Run
`cmake/idi/tools/lint.sh --tidy-only` after updating. Common fixes:
- `clang-analyzer-core-*`, `clang-analyzer-cplusplus-*` and `clang-analyzer-unix-*` match no checks
  (the analyzer names use a dot): use `clang-analyzer-core.*`, `clang-analyzer-cplusplus.*` and
  `clang-analyzer-unix.*`. Those groups start reporting in `tidy-report` once fixed.

Optional, to match new projects (all in files the updater does not own):
- Merge the template's `.clang-tidy`:
  - Protected methods take no `_` prefix (the `ProtectedMethodPrefix` line is removed).
  - Turn off checks that are noise for most code: `hicpp-*` (aliases of checks already on),
    magic numbers, identifier length, easily-swappable parameters, the low-level `pro-*` checks C
    APIs need, `use-enum-class` and `performance-enum-size`.
  - Set `modernize-use-using.IgnoreExternC: true`.
- Copy the template's `src/main/tests/.clang-tidy` into each existing component's `tests/` folder.
- `.gitlab-ci.yml`:
  - Remove `allow_failure: true` from the `tidy` job once the gate is clean.
  - Add the `sanitizers` job.
  - Check that the option prefix in `CMAKE_ARGS` is the upper-cased project name.
- Add the ABI note from the component template to existing public headers if they use C++ inside `extern "C"`.

## 6.4.0

Tooling for linting, coverage, API docs and updates, all shipped in `cmake/idi/` so existing projects get them through the updater.

- **Lint:** new targets `format`, `format-check`, `tidy` (gate checks, fails on findings),
  `tidy-report` (full `.clang-tidy` list, advisory), `lint` and `install-git-hooks` (opt-in
  clang-format pre-commit hook). They check `src/`; `demo/` only with `IDICMAKE_LINT_DEMOS=ON`
  (default OFF) or `lint.sh --demos`. Wrappers: `cmake/idi/tools/lint.sh` / `lint.bat`. Settings:
  `IDICMAKE_CLANG_TOOLS_VERSION`, `IDICMAKE_LINT_DIRS`, `IDICMAKE_LINT_DEMOS`, `IDICMAKE_LINT_EXCLUDES`,
  `IDICMAKE_LINT_TIDY_GATE_CHECKS`. Top-level builds now write `compile_commands.json`.
- **Coverage:**
  - `ccov-all` runs every test through `ctest`, so tests added with plain `add_test()` count too, and a failing test fails the target.
  - It writes the HTML and the Cobertura XML from one run and prints `Code Coverage: NN.NN%` for CI.
  - Exclude patterns are now absolute. Before, the gcovr XML report included test files.
  - Clang uses `llvm-cov gcov`, and lcov 2.x is supported.
  - New `IDICMAKE_COVERAGE_FAIL_UNDER` and `IDICMAKE_COVERAGE_CTEST_ARGS`.
  - Wrappers: `cmake/idi/tools/coverage.sh` / `coverage.bat`.
- **Docs:**
  - New `docs` target (Doxygen + doxygen-awesome-css, downloaded when first built).
  - It documents each component's public headers (shared builds) or all of its headers (static/exe builds) automatically.
  - New option `<P>_BUILD_DOCS`. Wrappers: `cmake/idi/tools/docs.sh` / `docs.bat`.
- **Updates:**
  - `cmake/idi/tools/update.sh` / `update.bat` add a guided update: preview, confirm, apply, rebuild and test, optional commit.
  - Updating from a GitHub archive (the default URL) works again; the archive's top-level folder was not handled before.
  - `FRAMEWORK_UPDATE_FILE_LOC` may now be absolute.
  - The updated paths are listed in `cmake/idi/updater/managed_paths.cmake`.
- **Component template:** generated components are clang-format clean.
- **Fix:** the build-info header (`__build_info.out.h`) is declared as a byproduct of the
  `<proj>_GetBuildInfo` step, so Ninja recompiles everything that includes it when the git state
  changes mid-build. Before, the base tests could fail with a dirty-flag mismatch after an edit to
  `src/base` in a dirty tree (e.g. right after a framework update).

### Manual steps

None required. Optional, to match new projects:
- Copy `new_component.sh` / `new_component.bat` (component scaffolding) to the project root.
- Merge the template's `.clang-tidy` (naming rules used by the `tidy` gate). Without naming
  options, `readability-identifier-naming` checks nothing.
- Add `build-*/` to `.gitignore` (the wrappers use `build-lint/` and `build-coverage/`). If you copy
  `new_component.bat`, add `*.bat text eol=crlf` to `.gitattributes` (`cmake/idi/` ships its own).
- Add the `format-check`, `tidy`, `coverage` and `pages` jobs from the template's `.gitlab-ci.yml`.
- A project that defines its own `docs`, `format`, `lint` (etc.) target keeps it; the framework skips
  targets whose names are taken.
