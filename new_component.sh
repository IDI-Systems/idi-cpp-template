#!/usr/bin/env bash
#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2025 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#
# Create a new component in src/<name>/ from cmake/idi/templates/template_component.
#
set -euo pipefail

usage() {
    cat <<'USAGE'
Usage: ./new_component.sh <component_name>

Creates src/<component_name>/ from the framework's component template:
  src/<name>/CMakeLists.txt              idi_component(<name> base) - list dependencies here
  src/<name>/objects.cmake               .cpp files (idi_add_sources)
  src/<name>/<name>.cpp                  example source
  src/<name>/include/<project>/          C++ headers (include.cmake)
  src/<name>/include/<project>/public/   exported C headers for shared builds (public.cmake)
  src/<name>/tests/                      Catch2 tests (tests.cmake)

The name must be lower_snake_case (a-z, 0-9, _; starts with a letter). It becomes the
target <project>_<name> and the C++ namespace <vendor>::<app>::<name>.

Afterwards, add the component to src/components.cmake:
  add_subdirectory(<name>)
and re-configure (cmake -S . -B build).

Options:
  -h, --help    Show this help

Environment:
  BUILD_DIR     Build directory to configure (default: build)

Same as running: cmake -S . -B build -DNEW_COMPONENT_NAME=<name>
USAGE
}

if [[ $# -eq 0 ]]; then
    usage
    exit 1
fi
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
    exit 0
fi
if [[ $# -gt 1 ]]; then
    echo "Error: expected one component name, got $#: $*" >&2
    echo "Run ./new_component.sh --help for usage." >&2
    exit 1
fi

NAME="$1"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${BUILD_DIR:-$ROOT/build}"

if [[ ! "$NAME" =~ ^[a-z][a-z0-9_]*$ ]]; then
    echo "Error: '$NAME' is not a valid component name. Use lower_snake_case: a-z, 0-9 and _, starting with a letter." >&2
    exit 1
fi
case "$NAME" in
    main|core|public)
        echo "Error: '$NAME' is reserved by the framework (src/main, <project>_core, <project>_public)." >&2
        exit 1 ;;
esac
if [[ -e "$ROOT/src/$NAME" ]]; then
    echo "Error: src/$NAME already exists. The template would overwrite its files; pick another name or remove it first." >&2
    exit 1
fi
if ! command -v cmake >/dev/null 2>&1; then
    echo "Error: cmake not found on PATH" >&2
    exit 1
fi

echo "Creating component '$NAME' in src/$NAME ..."
if ! cmake -S "$ROOT" -B "$BUILD_DIR" -DNEW_COMPONENT_NAME="$NAME"; then
    echo "Error: CMake failed while creating component '$NAME' (see output above)." >&2
    exit 1
fi
if [[ ! -f "$ROOT/src/$NAME/CMakeLists.txt" ]]; then
    echo "Error: src/$NAME was not created (see output above)." >&2
    exit 1
fi

echo ""
echo "Component '$NAME' created in src/$NAME."
echo "Next: add this line to src/components.cmake, then re-configure:"
echo ""
echo "    add_subdirectory($NAME)"
echo ""
