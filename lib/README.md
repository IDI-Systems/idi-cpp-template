# External Libraries

There are two primary ways of adding external libraries in this framework. The preferred method is using the `idi_add_first_party_dependency()` and `idi_add_third_party_dependency()` CMake functions available in the framework. The second, less preferred but still acceptable way is to add git submodules directly.

## CMake Dependency Management

The framework contains two functions that wrap CMake's `FetchContent` facilities and are designed to integrate git repository dependencies.

```
idi_add_first_party_dependency(
    <name>
    <git_url>
    <git_tag>
    [DOWNLOAD_ONLY]
    [DEP_OPTIONS args...]
)

idi_add_third_party_dependency(
    <name>
    <git_url>
    <git_tag>
    [DOWNLOAD_ONLY]
    [DEP_OPTIONS args...]
)
```

Both functions are identical in signature, but with slight differences in that `idi_add_third_party_dependency()` will place dependencies in `lib/.third-party` instead of directly in `lib/` and `idi_add_first_party_dependency()` will _not_ replace files if the configuration is wiped out, but warn instead about untracked/modified files and mismatching git checkout information.

The value of `<name>` should be the same as the underlying CMake `project()` name to make sure that if multiple dependencies use it, it has a higher chance of matching and preventing duplicate dependencies.

`<git_url>` and `<git_tag>` are the same as those in CMake's `GIT_REPOSITORY` and `GIT_TAG` options passed to `FetchContent_Declare` (and derive from `ExternalProject_Add()`).

`DOWNLOAD_ONLY` is optional and will only download the contents of the git repository and not try to add them to the project. This is useful if the repository doesn't support CMake out of the box or uses a different build system.

`DEP_OPTIONS` are a series of strings to set options for the dependency, they are the same as calling `set(name value)` before `add_subdirectory()` is called. They are dependent on the options specified by the underlying dependency, and are written as `"OPTION_NAME OPTION_VALUE"`, such as `"SPDLOG_NO_EXCEPTIONS OFF"` would set `spdlog` to not use exceptions.


### CMake Variables

`IDICMAKE_EXTERNAL_LIB_DIR` points to the root library folder

`IDICMAKE_EXTERNAL_THIRD_PARTY_LIB_DIR` points to the third party library directory.

`IDI_SYNC_DEPENDENCIES` can be set globally to `true` and on a clean reconfiguration of the project it will sync **all** dependency folders to the configured checkout. This can be potentially destructive if you are making changes to dependencies.


### Examples:

```
# Add third party dependency and set options
idi_add_third_party_dependency(spdlog https://github.com/gabime/spdlog.git v1.12.0 DEP_OPTIONS "SPDLOG_NO_EXCEPTIONS ON")

# Add first party dependency
idi_add_first_party_dependency(idi https://gitlab.idi-systems.com/idi/libidi.git master)

# Add third party dependency and specify a custom CMake target for a project that doesn't use CMake
idi_add_third_party_dependency(asio https://github.com/chriskohlhoff/asio.git asio-1-29-0 DOWNLOAD_ONLY)
add_library(asio INTERFACE)
target_include_directories(asio SYSTEM INTERFACE ${IDICMAKE_EXTERNAL_THIRD_PARTY_LIB_DIR}/asio/asio/include)
```

# Git Submodules

Use git submodules as you would in any other project. Ideally follow the same pattern for folder placement, with third party libraries being placed in the `lib/.third-party` folder.
