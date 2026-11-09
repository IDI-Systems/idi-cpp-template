#!/usr/bin/env bash
#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2026 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#
# Generate the Doxygen API documentation (the framework's 'docs' target).
# Part of the IDI CMake framework (cmake/idi/tools); updated by the framework updater.
#
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: cmake/idi/tools/docs.sh [options]

Builds the 'docs' target (Doxygen + doxygen-awesome-css theme). Configures the build
directory first if needed. Needs doxygen on PATH.

Options:
  --build-dir DIR   Build directory (default: build)
  --clean           Remove the generated docs and theme before building
  --no-theme        Plain Doxygen output, no theme download (sticks in this build dir;
                    re-enable with cmake -DIDICMAKE_DOCS_THEME=ON)
  --open            Open the result in a browser
  -h, --help        Show this help

Output: <build-dir>/docs/html/index.html (or IDICMAKE_DOCS_OUTPUT_DIR/html)
EOF
}

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
BUILD_DIR="$ROOT/build"
CLEAN=0
OPEN=0
THEME_ARGS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --build-dir) BUILD_DIR="$2"; shift 2 ;;
        --clean) CLEAN=1; shift ;;
        --no-theme) THEME_ARGS=(-DIDICMAKE_DOCS_THEME=OFF); shift ;;
        --open) OPEN=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
done

if ! command -v doxygen >/dev/null 2>&1; then
    echo "ERROR: doxygen not found on PATH (apt install doxygen / winget install DimitriVanHeesch.Doxygen)" >&2
    exit 2
fi

if [[ $CLEAN -eq 1 ]]; then
    rm -rf "$BUILD_DIR/docs" "$BUILD_DIR/docs-theme"
fi

if [[ ! -f "$BUILD_DIR/CMakeCache.txt" || ${#THEME_ARGS[@]} -gt 0 ]]; then
    echo "[docs] Configuring $BUILD_DIR"
    cmake -S "$ROOT" -B "$BUILD_DIR" "${THEME_ARGS[@]+"${THEME_ARGS[@]}"}"
fi

cmake --build "$BUILD_DIR" --target docs

INDEX="$(sed -n 's/^OUTPUT_DIRECTORY *= *"\{0,1\}\([^"]*\)"\{0,1\}$/\1/p' "$BUILD_DIR/Doxyfile.docs" 2>/dev/null | head -1)/html/index.html"
[[ -f "$INDEX" ]] || INDEX="$BUILD_DIR/docs/html/index.html"
echo ""
echo "Documentation: $INDEX"
if [[ $OPEN -eq 1 ]]; then
    if command -v xdg-open >/dev/null 2>&1; then xdg-open "$INDEX" >/dev/null 2>&1 &
    elif command -v open >/dev/null 2>&1; then open "$INDEX"
    else echo "Open it manually: $INDEX"
    fi
fi
