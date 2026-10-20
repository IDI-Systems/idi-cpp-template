---
name: idi-cmake
description: How the IDI C++ CMake template/framework (cmake/idi/, idi_* functions, IDICMAKE_* variables) works and how to work inside a project built on it. Use whenever editing CMakeLists.txt or *.cmake files in a project that has cmake/idi/idi-template.cmake; adding or changing a component, sources, headers, or public (shared-library) headers; adding a dependency (idi_add_first_party_dependency / idi_add_third_party_dependency); adding tests, demos, or coverage; changing build type (exe/static/shared), options, compile flags, or platform_config.h defines; installing or consuming the project from another project; updating the framework (DO_FRAMEWORK_UPDATE); starting a new project from the template; or changing the framework itself.
---

# IDI C++ CMake framework

This project is built on the IDI C++ CMake template. This skill documents the
framework version shipped alongside it in `cmake/idi/` (see
`cmake/idi/version.cmake`). **If anything here disagrees with the code in
`cmake/idi/`, the code wins** — read the function before relying on a detail.

## Mental model

- **Components** are CMake `OBJECT` libraries (`<proj>_<component>`) living in
  `src/<component>/`. Every component links PUBLIC into one **core** static
  library.
- The project type comes from `platform-config.cmake`:

  | `IDICMAKE_IS_LIBRARY` / `IDICMAKE_IS_SHARED` | Core target | Final target |
  |---|---|---|
  | false / false (exe) | `<proj>_core` STATIC | `<proj>` executable from `src/main/main.cpp` |
  | true / false (static) | `<proj>` STATIC (core *is* the product) | — |
  | true / true (shared) | `<proj>_core` STATIC | `<proj>` SHARED (whole-archive of core, hidden visibility) + `<proj>_public` INTERFACE target |

- Headers live under `src/<component>/include/<proj>/` (C++ API, usable by
  static consumers and other components) and
  `src/<component>/include/<proj>/public/` (C-ABI exported API of the shared
  library, decorated with `<CNS>_EXPORT`).
- `<proj>` = `IDICMAKE_PROJECT_NAME`. `<P>` = its upper-case form (option
  prefix). `<CNS>` = upper-case `vendor_app` C namespace (macro prefix, e.g.
  `IDI_APP`). C++ namespace is `vendor::app`.
- Configure order: `platform-options.cmake` → `platform-local-options.cmake`
  → platform config → `project()` → options → `idi_new_component` → Catch2 →
  `src/` (components, then main) → `demo/` → `lib/libraries.cmake`. Optional
  `cmake-hooks/*.cmake` run at each step; see `reference/layout.md`.

## Who owns which file — read before editing

The framework updater **deletes and replaces** template-owned files. In a
derived project, never put project changes in them; use a hook, platform file,
or component instead.

| Template-owned (overwritten on update) | Project-owned (safe to edit) |
|---|---|
| `cmake/idi/**` | `platform-config*.cmake`, `platform-options.cmake`, `platform-local-options.cmake` (gitignored) |
| `src/base/**` (the base component) | `platform-compile-options.cmake` |
| root `CMakeLists.txt` | root `version.cmake` (project version) |
| `src/CMakeLists.txt` | `src/components.cmake`, `src/main/**`, every other `src/<component>/` |
| `lib/.gitignore` | `lib/libraries.cmake`, `demo/**`, `cmake-hooks/**` |
| `.claude/skills/idi-cmake/**` (this skill) | CI files, `README.md`, dotfiles, `CLAUDE.md` |

Exception: when working **in the template repository itself** (the
`idi-cpp-template` / `cmake-cpp` repo), template-owned files are the product —
read `reference/maintaining.md` first.

## Common tasks

Before writing any `idi_*` call, check the exact signature in
`reference/functions.md`. Argument lists are keyword-*mode* switches: a keyword
changes how every following bare argument is treated.

**Add a component** — scaffold it, don't hand-write it:
```sh
cmake -S . -B build -DNEW_COMPONENT_NAME=foo   # creates src/foo/ from cmake/idi/templates/template_component
```
It overwrites without asking, so make sure `src/foo/` doesn't exist first.
Then add `add_subdirectory(foo)` to `src/components.cmake` (the framework only
prints a reminder) and re-configure. Edit dependencies on other components in
`src/foo/CMakeLists.txt`: `idi_component(foo base other_component EXTERNAL_LIBRARIES spdlog::spdlog)`.
Component names in that list are bare (`base`, not `<proj>_base`).

**Add sources / headers** — list each file in the matching cmake file of the
component (globs are not used):
- `.cpp` → `src/foo/objects.cmake` via `idi_add_sources(...)`
- internal C++ API header → `src/foo/include/<proj>/include.cmake` via `idi_add_includes(...)`
- exported C header for the shared lib → `src/foo/include/<proj>/public/public.cmake` via `idi_add_public_includes(...)`
- a file needing `${VAR}`/`@VAR@` substitution → put it after `INTERNAL_CONFIGURE`; it is configured to `name.out.ext` next to the source (gitignored) and that output is compiled/included.
Headers that must stay private go anywhere in `src/foo/` *outside* `include/`.
Include paths are always `"<proj>/x.hpp"` or `"<proj>/public/x.h"`.

**Add a dependency** — in `lib/libraries.cmake`:
```cmake
idi_add_third_party_dependency(spdlog https://github.com/gabime/spdlog.git v1.12.0 DEP_OPTIONS "SPDLOG_NO_EXCEPTIONS ON")
idi_add_first_party_dependency(idi https://gitlab.idi-systems.com/idi/libidi.git master)
```
Then link it from the component (`EXTERNAL_LIBRARIES <target>`). Uses
FetchContent into `lib/third-party/` / `lib/first-party/` (gitignored), not
`find_package`. Catch2 v3 is already added by the framework.

**Add a test** — in `src/foo/tests/tests.cmake`:
`idi_component_test(foo "${CMAKE_CURRENT_LIST_DIR}/my_test.cpp")` (skipped in
shared builds) or `idi_component_test_public(...)` (always built). Catch2 v3
with `Catch2WithMain`; target `<proj>_foo_my_test`; run with `ctest -C Debug`.

**Add a demo** — in `demo/CMakeLists.txt`: `idi_demo(name "${CMAKE_CURRENT_LIST_DIR}/x.cpp")`,
or `idi_demo_public(...)` to link only `<proj>_public` (shared builds only;
proves the public API is self-sufficient). Built when `<P>_BUILD_DEMOS` is on.

**Add a `platform_config.h` define** — in `cmake-hooks/post-options.cmake`:
`idi_platform_config(<CNS>_HAS_FOO BOOL ${SOME_VAR})` (types `RAW`, `STRING`, `BOOL`).

**Change compile flags** — edit `platform-compile-options.cmake` (applied PRIVATE
to every framework target). Per-target tweaks: `cmake-hooks/post-target-compile-options.cmake`
(target name is `${compile_target}`). Defaults: C++20, `-Wall -Wextra -Wshadow -pedantic -Werror -fno-exceptions`, MSVC `/W4 /WX`.

**Switch build type** — edit `IDICMAKE_IS_LIBRARY`/`IDICMAKE_IS_SHARED`, or pass
`-DIDICMAKE_PLATFORM_CONFIG=../platform-config.shared.cmake` (also `.static`, `.exe`).

**Coverage** — `cmake -B build-cov -DCODE_COVERAGE=ON && cmake --build build-cov --target ccov-all`
(GCC/Clang only; forces Debug; use a separate build dir since the `-D` sticks in the cache).

**Update the framework** — `cmake -B build -DDO_FRAMEWORK_UPDATE=ON`
(optional `-DFRAMEWORK_UPDATE_MODE=url|file|folder` + `FRAMEWORK_UPDATE_URL` /
`_FILE_LOC` / `_FOLDER_LOC`, `-DFRAMEWORK_UPDATE_FORCE=ON`). The configure stops
after updating; run cmake again. Review `git diff` afterwards: anything lost
in a template-owned file was a project change in the wrong place.

**Start a new project from the template** — see "New project checklist" in
`reference/build-install.md`.

## Reference files

- `reference/functions.md` — every public `idi_*` function and macro: signature, keywords, behavior.
- `reference/layout.md` — component anatomy, base component, `src/main`, hook order and scoping, scaffolding placeholders.
- `reference/build-install.md` — options and variables, build types, generated headers (export/version/build info/umbrella), install layout, consuming from another project, CI, new-project checklist.
- `reference/maintaining.md` — changing the framework itself: versioning rules, updater, keeping this skill in sync, known issues.
