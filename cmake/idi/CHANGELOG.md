# IDI CMake framework changelog

Framework versions only (not the project's own version). The update tool
(`cmake/idi/tools/update.sh` / `update.bat`) prints the entries between the project's
version and the incoming one. Each release lists what changed and, under
**Manual steps**, anything a project has to change by hand in files the updater does not own.

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
