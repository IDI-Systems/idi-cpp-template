#!/usr/bin/env bash
#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2025 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#
# clang-format and clang-tidy checks for the project's own sources (src/; demo/ with --demos).
# Part of the IDI CMake framework (cmake/idi/tools); updated by the framework updater.
#
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: cmake/idi/tools/lint.sh [options] [files...] [-- <extra cmake configure args>]

Checks formatting (clang-format) and runs the clang-tidy gate checks. With no files, checks
every project file under src/ (and demo/ with --demos); with files, checks only those.
Exit code 0 = clean, 1 = findings.

Options:
  --fix                 Apply clang-format to the files instead of only checking
  --format-only         Only run clang-format (no build needed)
  --tidy-only           Only run clang-tidy
  --all-checks          Also report the full .clang-tidy check list (advisory, never fails)
  --demos               Also lint demo/ (default off; to make it permanent set
                        IDICMAKE_LINT_DEMOS ON in cmake-hooks/post-options.cmake)
  --clang-version N     Use clang-format-N / clang-tidy-N (default: newest installed)
  --build-dir DIR       Build directory used for compile_commands.json (default: build-lint)
  --no-build            Don't build before clang-tidy (generated sources must already exist)
  -h, --help            Show this help
  -- ARGS...            Pass the remaining arguments to the cmake configure step

Examples:
  cmake/idi/tools/lint.sh                         # everything
  cmake/idi/tools/lint.sh --fix --format-only     # reformat all files
  cmake/idi/tools/lint.sh src/net/socket.cpp      # one file
  cmake/idi/tools/lint.sh --clang-version 21      # match CI's clang version
  cmake/idi/tools/lint.sh --tidy-only -- -DMYPROJ_BUILD_DEMOS=1

Settings (dirs, excludes, gate checks) live in cmake: see IDICMAKE_LINT_* in cmake/idi/functions/idi_lint.cmake.
EOF
}

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
BUILD_DIR="$ROOT/build-lint"
FIX=0
DO_FORMAT=1
DO_TIDY=1
ALL_CHECKS=0
NO_BUILD=0
DEMOS=OFF
CLANG_VERSION=""
FILES=()
EXTRA=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --fix) FIX=1; shift ;;
        --format-only) DO_TIDY=0; shift ;;
        --tidy-only) DO_FORMAT=0; shift ;;
        --all-checks) ALL_CHECKS=1; shift ;;
        --clang-version|-v) CLANG_VERSION="$2"; shift 2 ;;
        --build-dir) BUILD_DIR="$2"; shift 2 ;;
        --no-build) NO_BUILD=1; shift ;;
        --demos) DEMOS=ON; shift ;;
        -h|--help) usage; exit 0 ;;
        --) shift; EXTRA=("$@"); break ;;
        -*) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
        *)
            # Make paths absolute so they work from any directory
            if [[ -e "$1" ]]; then
                FILES+=("$(cd "$(dirname "$1")" && pwd)/$(basename "$1")")
            else
                echo "No such file: $1" >&2
                exit 2
            fi
            shift ;;
    esac
done

if ! command -v cmake >/dev/null 2>&1; then
    echo "ERROR: cmake not found on PATH" >&2
    exit 2
fi

CONFIGURE_ARGS=(-S "$ROOT" -B "$BUILD_DIR" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON "-DIDICMAKE_LINT_DEMOS=$DEMOS")
if [[ ! -f "$BUILD_DIR/CMakeCache.txt" ]] && command -v ninja >/dev/null 2>&1; then
    CONFIGURE_ARGS+=(-G Ninja)
fi
if [[ -n "$CLANG_VERSION" ]]; then
    CONFIGURE_ARGS+=("-DIDICMAKE_CLANG_TOOLS_VERSION=$CLANG_VERSION")
fi

echo "[lint] Configuring $BUILD_DIR"
mkdir -p "$BUILD_DIR"
LOG="$BUILD_DIR/lint-configure.log"
cmake "${CONFIGURE_ARGS[@]}" "${EXTRA[@]+"${EXTRA[@]}"}" > "$LOG" 2>&1 || {
    cat "$LOG" >&2
    echo "ERROR: configure failed (log above)" >&2
    exit 2
}
grep -F "[Lint]" "$LOG" || true

if [[ $DO_TIDY -eq 1 && $NO_BUILD -eq 0 ]]; then
    echo "[lint] Building (so generated sources exist for clang-tidy)"
    cmake --build "$BUILD_DIR" --parallel > /dev/null || {
        echo "ERROR: build failed; fix it or use --no-build" >&2
        exit 2
    }
fi

SCRIPT="$ROOT/cmake/idi/scripts/lint.cmake"
CONFIG="$BUILD_DIR/idi-lint-config.cmake"
FILE_LIST=""
if [[ ${#FILES[@]} -gt 0 ]]; then
    FILE_LIST="$(IFS=';'; echo "${FILES[*]}")"
fi

run_mode() {
    cmake "-DLINT_CONFIG=$CONFIG" "-DMODE=$1" "-DFILES=$FILE_LIST" -P "$SCRIPT"
}

FAILED=0
echo ""
if [[ $DO_FORMAT -eq 1 ]]; then
    if [[ $FIX -eq 1 ]]; then
        run_mode format || FAILED=1
    else
        run_mode format-check || FAILED=1
    fi
    echo ""
fi
if [[ $DO_TIDY -eq 1 ]]; then
    run_mode tidy || FAILED=1
    echo ""
fi
if [[ $ALL_CHECKS -eq 1 ]]; then
    run_mode tidy-report || true
    echo ""
fi

if [[ $FAILED -eq 0 ]]; then
    echo "All lint checks passed."
else
    echo "Lint found problems (see above)."
fi
exit $FAILED
