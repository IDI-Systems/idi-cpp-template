#!/usr/bin/env bash
#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2026 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#
# Code coverage in one step: configure a coverage build, build it, run every test and write the report.
# Part of the IDI CMake framework (cmake/idi/tools); updated by the framework updater.
#
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: cmake/idi/tools/coverage.sh [options] [-- <extra cmake configure args>]

Builds the project with coverage instrumentation in a separate build directory, runs all
tests (ctest) and writes the report. Needs GCC or Clang, plus lcov or gcovr for reports.

Options:
  --build-dir DIR     Coverage build directory (default: build-coverage)
  --clean             Delete the coverage build directory first
  --fail-under PCT    Fail if line coverage is below PCT percent (e.g. 80)
  --open              Open the HTML report when done
  -h, --help          Show this help

The compiler comes from the CC / CXX environment variables, e.g.
  CC=clang-21 CXX=clang++-21 cmake/idi/tools/coverage.sh

Output: <build-dir>/reports/coverage/html/index.html, coverage.info (lcov), coverage.xml (gcovr)
EOF
}

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
BUILD_DIR="$ROOT/build-coverage"
CLEAN=0
OPEN=0
FAIL_UNDER=""
EXTRA=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --build-dir) BUILD_DIR="$2"; shift 2 ;;
        --clean) CLEAN=1; shift ;;
        --fail-under) FAIL_UNDER="$2"; shift 2 ;;
        --open) OPEN=1; shift ;;
        -h|--help) usage; exit 0 ;;
        --) shift; EXTRA=("$@"); break ;;
        *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
done

if ! command -v cmake >/dev/null 2>&1; then
    echo "ERROR: cmake not found on PATH" >&2
    exit 2
fi

if [[ $CLEAN -eq 1 && -d "$BUILD_DIR" ]]; then
    echo "[coverage] Removing $BUILD_DIR"
    rm -rf "$BUILD_DIR"
fi

CONFIGURE_ARGS=(-S "$ROOT" -B "$BUILD_DIR" -DCODE_COVERAGE=ON)
if [[ ! -f "$BUILD_DIR/CMakeCache.txt" ]] && command -v ninja >/dev/null 2>&1; then
    CONFIGURE_ARGS+=(-G Ninja)
fi
if [[ -n "$FAIL_UNDER" ]]; then
    CONFIGURE_ARGS+=("-DIDICMAKE_COVERAGE_FAIL_UNDER=$FAIL_UNDER")
fi

echo "[coverage] Configuring $BUILD_DIR"
cmake "${CONFIGURE_ARGS[@]}" "${EXTRA[@]+"${EXTRA[@]}"}"

echo "[coverage] Building"
cmake --build "$BUILD_DIR" --parallel

echo "[coverage] Running tests and generating the report"
cmake --build "$BUILD_DIR" --target ccov-all

REPORT="$BUILD_DIR/reports/coverage/html/index.html"
if [[ -f "$REPORT" ]]; then
    echo ""
    echo "Coverage report: $REPORT"
    if [[ $OPEN -eq 1 ]]; then
        if command -v xdg-open >/dev/null 2>&1; then xdg-open "$REPORT" >/dev/null 2>&1 &
        elif command -v open >/dev/null 2>&1; then open "$REPORT"
        else echo "Open it manually: $REPORT"
        fi
    fi
else
    echo ""
    echo "No HTML report was written (install lcov or gcovr). Raw .gcda data is in $BUILD_DIR."
fi
