# Maintaining the framework (template repository only)

Applies when editing the template repo itself (`IDI-Systems/idi-cpp-template`,
local checkout often `cmake-cpp`). In a derived project, do not edit these files —
fix them upstream and pull with the updater.

## What a framework change can touch

The updater (`cmake/idi/updater/updater_imp.cmake`) delivers only the paths listed in
`cmake/idi/updater/managed_paths.cmake`: `cmake/idi/`, `src/base/`,
`.claude/skills/idi-cmake/` (whole-directory replace), and `CMakeLists.txt`,
`src/CMakeLists.txt`, `lib/.gitignore` (file replace). The incoming list is used, so
adding a path takes effect in the same update (bump the updater version).
Changes anywhere else (platform files, hooks, `components.cmake`, `src/main`, CI,
README) reach **new** projects only; existing projects must be told to apply them
by hand.

## Version numbers

`cmake/idi/version.cmake` — framework semver:
- **MAJOR**: breaking change to any `idi_*` signature/behavior, project-owned file
  expectations, or any `*_REQ_CML_V` bump.
- **MINOR**: backward-compatible additions.
- **HOTFIX**: fixes only.

`IDICMAKE_ROOT_REQ_CML_V`, `IDICMAKE_SRC_REQ_CML_V`, `IDICMAKE_BASE_REQ_CML_V`:
bump when root `CMakeLists.txt`, `src/CMakeLists.txt`, or `src/base/CMakeLists.txt`
change, together with the `IDICMAKE_*_CML_V` value set inside that file. A bump
requires a MAJOR framework bump.

`cmake/idi/updater/updater_version.cmake` — `IDICMAKE_CPP_UPDATER_VERSION`:
increment on **any** change to `updater.cmake` or `updater_imp.cmake`. The
incoming `updater_imp.cmake` only runs when this number differs from the
project's; otherwise the project's old copy runs and new update steps are
silently skipped.

The updater refuses to run when the incoming framework *and* updater versions
are not newer, so every release that should reach projects needs a version bump.

Every release also needs a `## <version>` section in `cmake/idi/CHANGELOG.md` (newest
first). `update.sh` prints the sections between the project's and the incoming version,
so list breaking changes and anything projects must do by hand under `### Manual steps`.

The guided update (`cmake/idi/tools/update.{sh,bat}` + `updater/update_workflow.cmake`)
stages and previews with the *project's* copy of `update_workflow.cmake`, applies through
the configure-time updater in folder mode, then runs `MODE=post` from the *new* copy. Keep
`MODE=stage` able to read old templates (it falls back to the ≤ 6.3.2 managed paths).

## Changing the component template

`cmake/idi/templates/template_component/` is copied with `configure_file(@ONLY)`:
use `@__idi_new_component_name@`, `@PROJECT_NAME@`, `@__idi_namespace@`,
`@__idi_c_caps_namespace@` in contents and `__idi__component` in file names.
Keep `${...}` for values resolved at configure time of the generated component.
Test with `-DDO_TEMPLATE_COMPONENT_TEST=1` (builds `src/unit_test_component`).

## Testing a change

```sh
for t in exe static shared; do
  cmake -S . -B build-$t -DIDICMAKE_PLATFORM_CONFIG=$PWD/platform-config.$t.cmake -DDO_TEMPLATE_COMPONENT_TEST=1 \
        -DTEMPLATE_PROJECT_BUILD_DEMOS=1 && cmake --build build-$t && ctest --test-dir build-$t -C Debug
done
```
The platform config path must be absolute (or relative to the directory cmake runs in). If
configure fails before the platform config loads, the `unit_test_component` scaffold is written
with an empty project name (`include/` without the `<proj>` folder): delete `src/unit_test_component/`
before re-running. A HEADER_ONLY component is not covered by the matrix; when touching header-only or
test code, add one (with an `EXCLUDE_CORE` `idi_component_test_public`) in a scratch copy and build shared.

Lint the template's own code (the scaffold output too, so components generated in
projects start clean):
```sh
cmake/idi/tools/lint.sh --clang-version 21 -- -DDO_TEMPLATE_COMPONENT_TEST=1 "-DIDICMAKE_LINT_EXCLUDES=*.out.*;src/base/*"
```
Coverage and docs: `cmake/idi/tools/coverage.sh`, `cmake/idi/tools/docs.sh` (exe and shared configs).

Updater test: copy an older checkout (or a derived project) somewhere as a git repo, then
`cmake -S <copy> -B <copy>/build -DDO_FRAMEWORK_UPDATE=ON -DFRAMEWORK_UPDATE_MODE=folder -DFRAMEWORK_UPDATE_FOLDER_LOC=$PWD`,
re-run cmake, build, ctest. For the guided flow, run `<copy>/cmake/idi/tools/update.sh --folder <newer template copy>`
(`--check`, then a full run with `-y --commit`).

## Keep this skill in sync

This skill ships with the framework, so it must describe the same version. In the
same commit as a framework change, update:
- `reference/functions.md` for any added/changed `idi_*` function, keyword, or default;
- `reference/build-install.md` for options, generated headers, install rules;
- `reference/layout.md` for hooks, template-component layout;
- the ownership table in `SKILL.md` and the list above if updater-managed paths change;
- README.md.

Quick check that every public function is documented:
```sh
grep -rhoE "^(function|macro)\((idi_[a-z_]+|target_code_coverage|add_code_coverage_all_targets)" cmake/idi \
  | sed -E 's/.*\(//' | sort -u | while read f; do grep -q "$f" .claude/skills/idi-cmake/reference/functions.md || echo "undocumented: $f"; done
```

## Rules learned the hard way

- Never put `#pragma once` in a header whose content is the same in every derived project
  (a forwarding header, or anything without the project name or namespace in it). GCC treats
  `#pragma once` files with identical content, size and mtime second as one file, and the
  updater writes every project's copy in the same second. Either leave the guard out (when the
  file only includes a guarded, project-unique header) or make the content project-specific by
  configuring it. Fixed for the base forwarding headers in 6.3.2.
- Code that runs in a component's directory scope (`tests/tests.cmake`, the component's
  `CMakeLists.txt`) cannot see variables set inside `idi_component_setup` (a function). Pass the
  component name instead, or set the variable in the `idi_component*` macro.

## Known issues (as of framework 6.4.0)

- `<P>_DO_TEMPLATE_COMPONENT_TEST` is defined and mirrored to
  `IDICMAKE_DO_TEMPLATE_COMPONENT_TEST`, but `idi_new_component.cmake` and
  `idi_src.cmake` read the unprefixed `DO_TEMPLATE_COMPONENT_TEST`, so CI's
  `-DTEMPLATE_PROJECT_DO_TEMPLATE_COMPONENT_TEST=1` does nothing.
- `__build_info.h` is not listed in `src/base/.../public/public.cmake`, so it is
  not installed, while the installed `__version.out.h` includes
  `<proj>/public/__build_info.out.h`.
- Shared install: `install(TARGETS <proj> LIBRARY FILE_SET HEADERS ...)` — the
  target has no `HEADERS` file set, and on Windows the DLL (`RUNTIME`) and import
  lib (`ARCHIVE`) are not installed.
- `export.h` has no `dllimport` branch for Windows consumers.
- Only the root CML version check is effective: `IDICMAKE_SRC_CML_V` /
  `IDICMAKE_BASE_CML_V` are not yet set when `idi-template.cmake` checks them.
- The `.bat` wrappers in `cmake/idi/tools/` and `new_component.bat` have not been run on Windows
  yet (written to mirror the `.sh` versions, which are tested on Linux).
