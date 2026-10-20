# Project layout, components, hooks

## Repository layout

```
CMakeLists.txt                 # template-owned; sets IDICMAKE_ROOT_CML_V, loads framework, project(), idi_init()
version.cmake                  # project version: IDICMAKE_PROJECT_VERSION_MAJOR/MINOR/PATCH
platform-config.cmake          # project name, namespaces, IS_LIBRARY / IS_SHARED
platform-config.{exe,static,shared}.cmake   # same, with the type preset (used by CI)
platform-options.cmake         # project-wide set() calls before project()
platform-local-options.cmake   # optional, gitignored, per-developer overrides
platform-compile-options.cmake # warning flags / defines / C++ standard for all targets
cmake/idi/                     # the framework (template-owned)
cmake-hooks/                   # optional hook files (project-owned, may be deleted)
lib/libraries.cmake            # dependency declarations
lib/{first,third}-party/       # fetched dependencies (gitignored)
src/CMakeLists.txt             # template-owned; calls idi_src()
src/components.cmake           # add_subdirectory() per component
src/base/                      # framework-provided component (template-owned)
src/main/                      # entry points: main.cpp (exe), dll_main.cpp (shared, Windows DllMain)
src/<component>/               # your components
demo/CMakeLists.txt            # idi_demo() calls
```

## Component anatomy

```
src/foo/
  CMakeLists.txt               # idi_component(foo base ...)
  objects.cmake                # idi_add_sources(...); include(include/<proj>/include.cmake)
  foo.cpp
  private_detail.hpp           # private: anything outside include/
  include/
    <proj>/                    # exactly one dir; auto-renamed to IDICMAKE_PROJECT_NAME
      include.cmake            # idi_add_includes(...); include(public/public.cmake)
      foo.hpp                  # C++ API, namespace vendor::app::foo
      public/
        public.cmake           # idi_add_public_includes(...)
        foo_public.h           # extern "C" API with <CNS>_EXPORT
  tests/
    tests.cmake                # idi_component_test(...) / idi_component_test_public(...)
    test.cpp
    test_public.cpp
```

The file chain is: `CMakeLists.txt` → `objects.cmake` → `include.cmake` →
`public.cmake`, then `tests/tests.cmake`. Every source and header must be listed
explicitly in one of these.

Include style inside the project and for consumers:
`#include "<proj>/foo.hpp"`, `#include "<proj>/public/foo_public.h"`,
`#include "<proj>/public/export.h"`.

`include/<proj>/` isolation is per component, not per folder: anything that links
a component (or `<proj>_public`) can reach all of that component's `include/`
tree. Only files outside `include/` are truly private.

### Scaffolding (`-DNEW_COMPONENT_NAME=foo`)

`idi_new_component` (`cmake/idi/functions/framework/idi_new_component.cmake`)
copies `cmake/idi/templates/template_component/` to `src/foo/`:
- `__idi__component` in file names → `foo`.
- A directory named `include` gets an extra `<proj>/` level inserted.
- File contents go through `configure_file(@ONLY)` with
  `@__idi_new_component_name@`, `@PROJECT_NAME@`, `@__idi_namespace@`,
  `@__idi_c_caps_namespace@`. `${...}` is left untouched.
- Does **not** check for an existing `src/foo` — it silently overwrites the
  template-named files there. Check first. Resets `NEW_COMPONENT_NAME` afterwards.
- It does **not** edit `src/components.cmake`.

## `src/base` (template-owned)

Provides versioning and config headers for every project; do not add project code
here (create your own `common` component instead). Public headers in
`include/<proj>/public/`: `export.h`, `platform_config.h`, `idi_version.h`,
`version.h` (C API: `<cns>_get_version_major()`, `_get_git_hash_short()`, …),
plus C++ `version.hpp` in `vendor::app::base`. See `build-install.md`.

## `src/main` (project-owned)

`idi_main()` includes `main/objects.cmake` — sources there are added straight to
`${IDICMAKE_CORE}` — and `main/tests/tests.cmake` (shared builds add
`dll_test.cpp` via `idi_component_test_public(main ...)`). `main.cpp` is compiled
only into the executable; `dll_main.cpp` only into the shared library. Never list
`main` in `components.cmake`.

## Hooks (`cmake-hooks/<name>.cmake`, all optional)

| Hook | When | Scope |
|---|---|---|
| `pre-configure` | after platform-options, before platform config | root, pre-`project()` |
| `post-platform-config` | after platform config is loaded | root, pre-`project()` |
| `pre-init` | start of `idi_init` (CTest/FetchContent included) | root |
| `pre-options` | before `<P>_*` cache options are defined | root |
| `post-options` | after options + `platform-compile-options.cmake`; good place for `idi_platform_config()` and overriding `IDICMAKE_*_COMPILE_OPTIONS` | root |
| `pre-source` / `post-source` | around `add_subdirectory(src)` | root |
| `pre-components-list` / `post-components-list` | around `src/components.cmake` | `src/` |
| `pre-component` / `post-component` | each component; `${CURRENT_LIBRARY_NAME}`, `${CURRENT_LIBRARY_DIR}` set | function scope |
| `pre-target-compile-options` / `post-target-compile-options` | each framework target; `${compile_target}` set | function scope |
| `post-configure` | end of `idi_init` (after demos and `lib/libraries.cmake`) | root |

Variables set in function-scope hooks do not leak out. Root hooks run inside
`if(NOT TARGET <proj>)`, so they don't re-run when the project is pulled in twice.
