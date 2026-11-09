#!/usr/bin/env bash
#
# @author Cliff Foster (Nou) <cliff@idi-systems.com>
#
# @copyright Copyright (c) 2025 International Development & Integration Systems LLC
#
# Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
#
# Guided IDI CMake framework update: preview, confirm, apply, verify, (optionally) commit.
# Part of the IDI CMake framework (cmake/idi/tools); updated by the framework updater.
#
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: cmake/idi/tools/update.sh [options]

Updates the framework-owned files (cmake/idi/, src/base/, .claude/skills/idi-cmake/, the root and
src/ CMakeLists.txt, lib/.gitignore) from a newer template, with a preview first.

Steps: check the git tree is clean -> fetch the update -> show the version change, the files that
will change and the changelog -> ask -> apply -> show the diff summary -> rebuild and run the
tests -> optionally commit. Nothing outside the framework-owned paths is touched.

Source (default: GitHub, master branch):
  --ref REF           Branch or tag of the template repository (e.g. v6.4.0)
  --url URL           Archive URL; {ref} in it is replaced by --ref
  --file ARCHIVE      A local .zip / .tar.gz of the template
  --folder DIR        A local checkout of the template

Options:
  --check             Only preview; change nothing
  -y, --yes           Don't ask for confirmation (required when not run from a terminal)
  --force             Apply even if the project is already at that version
  --allow-dirty       Allow uncommitted changes (the update is then mixed into them)
  --no-verify         Skip the rebuild + ctest after updating
  --build-dir DIR     Build directory used for verification (default: build)
  --commit            Commit the framework-owned paths after a successful update
  -h, --help          Show this help

Environment:
  IDI_TEMPLATE_UPDATE_URL   Default archive URL, with {ref}, e.g. for an internal mirror:
                            https://gitlab.example.com/idi/idi-cpp-template/-/archive/{ref}/idi-cpp-template-{ref}.zip

Examples:
  cmake/idi/tools/update.sh --check            # what would change?
  cmake/idi/tools/update.sh                    # update to the latest master
  cmake/idi/tools/update.sh --ref v6.4.0 --commit
  cmake/idi/tools/update.sh --folder ../idi-cpp-template
EOF
}

# The update replaces this script, and bash reads scripts while running them: run from a temp copy.
if [[ -z "${IDI_UPDATE_REEXEC:-}" ]]; then
    ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
    SELF_COPY="$(mktemp "${TMPDIR:-/tmp}/idi-update.XXXXXX")"
    cp "${BASH_SOURCE[0]}" "$SELF_COPY"
    IDI_UPDATE_REEXEC="$SELF_COPY" IDI_UPDATE_ROOT="$ROOT" exec bash "$SELF_COPY" "$@"
fi
ROOT="$IDI_UPDATE_ROOT"
SELF_COPY="$IDI_UPDATE_REEXEC"

SOURCE_KIND="url"
SOURCE=""
REF=""
CHECK=0
YES=0
FORCE=0
ALLOW_DIRTY=0
VERIFY=1
COMMIT=0
BUILD_DIR="$ROOT/build"

abs_path() { (cd "$(dirname "$1")" && echo "$(pwd)/$(basename "$1")"); }

while [[ $# -gt 0 ]]; do
    case "$1" in
        --ref) REF="$2"; shift 2 ;;
        --url) SOURCE_KIND="url"; SOURCE="$2"; shift 2 ;;
        --file) SOURCE_KIND="file"; SOURCE="$(abs_path "$2")"; shift 2 ;;
        --folder) SOURCE_KIND="folder"; SOURCE="$(cd "$2" && pwd)"; shift 2 ;;
        --check) CHECK=1; shift ;;
        -y|--yes) YES=1; shift ;;
        --force) FORCE=1; shift ;;
        --allow-dirty) ALLOW_DIRTY=1; shift ;;
        --no-verify) VERIFY=0; shift ;;
        --build-dir) BUILD_DIR="$2"; shift 2 ;;
        --commit) COMMIT=1; shift ;;
        -h|--help) usage; rm -f "$SELF_COPY"; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage >&2; rm -f "$SELF_COPY"; exit 2 ;;
    esac
done

STAGE_DIR="$(mktemp -d "${TMPDIR:-/tmp}/idi-update-stage.XXXXXX")"
cleanup() {
    rm -rf "$STAGE_DIR" "$ROOT/.idi-framework-update" "$ROOT/.idi_framework_dl"
    rm -f "$SELF_COPY"
}
trap cleanup EXIT

if ! command -v cmake >/dev/null 2>&1; then
    echo "ERROR: cmake not found on PATH" >&2
    exit 2
fi

WORKFLOW="$ROOT/cmake/idi/updater/update_workflow.cmake"
COMMON=(-DROOT="$ROOT" -DSTAGE_DIR="$STAGE_DIR")
[[ $FORCE -eq 1 ]] && COMMON+=(-DFORCE=ON)

# 1. Preflight, fetch, preview
cmake "${COMMON[@]}" -DMODE=stage -DSOURCE_KIND="$SOURCE_KIND" -DSOURCE="$SOURCE" -DREF="$REF" \
    $( [[ $ALLOW_DIRTY -eq 1 ]] && echo -DALLOW_DIRTY=ON ) -P "$WORKFLOW" || exit 1

STATUS="$(sed -n 's/^STATUS=//p' "$STAGE_DIR/status.txt")"
OLD="$(sed -n 's/^OLD=//p' "$STAGE_DIR/status.txt")"
NEW="$(sed -n 's/^NEW=//p' "$STAGE_DIR/status.txt")"
IN_GIT="$(sed -n 's/^GIT=//p' "$STAGE_DIR/status.txt")"
PATHS=()
while IFS= read -r line; do
    [[ -n "$line" ]] && PATHS+=("$line")
done < "$STAGE_DIR/paths.txt"

if [[ "$STATUS" == "up-to-date" ]]; then
    echo "Nothing to do (use --force to re-apply)."
    exit 0
fi
if [[ $CHECK -eq 1 ]]; then
    echo ""
    echo "Check only: no files were changed."
    exit 0
fi

# 2. Confirm
if [[ $YES -eq 0 ]]; then
    if [[ ! -t 0 ]]; then
        echo "Not running in a terminal: pass --yes to apply the update." >&2
        exit 1
    fi
    echo ""
    read -r -p "Apply the update $OLD -> $NEW? [y/N] " ANSWER
    if [[ ! "$ANSWER" =~ ^[Yy]([Ee][Ss])?$ ]]; then
        echo "Cancelled. No files were changed."
        exit 0
    fi
fi

ROLLBACK="git checkout -- ${PATHS[*]} && git clean -fd -- ${PATHS[*]}"

# 3. Apply (through the configure-time updater)
if ! cmake "${COMMON[@]}" -DMODE=apply -P "$WORKFLOW"; then
    [[ "$IN_GIT" == "TRUE" ]] && echo "Undo any partial changes with: $ROLLBACK" >&2
    exit 1
fi

# 4. Report, using the updated framework's workflow script
if [[ -f "$WORKFLOW" ]]; then
    cmake "${COMMON[@]}" -DMODE=post -P "$WORKFLOW" || true
fi

# 5. Verify
if [[ $VERIFY -eq 1 ]]; then
    echo ""
    echo "Verifying: configure, build and test in $BUILD_DIR"
    if ! { cmake -S "$ROOT" -B "$BUILD_DIR" && cmake --build "$BUILD_DIR" --parallel && \
           ctest --test-dir "$BUILD_DIR" -C Debug --output-on-failure; }; then
        echo "" >&2
        echo "Verification FAILED after the update $OLD -> $NEW." >&2
        echo "Check the 'Manual steps' in cmake/idi/CHANGELOG.md, or roll back with:" >&2
        [[ "$IN_GIT" == "TRUE" ]] && echo "    $ROLLBACK" >&2
        exit 1
    fi
fi

# 6. Commit
if [[ $COMMIT -eq 1 ]]; then
    if [[ "$IN_GIT" != "TRUE" ]]; then
        echo "Not a git work tree: skipping --commit." >&2
    else
        (cd "$ROOT" && git add -A -- "${PATHS[@]}" && \
            git commit -q -m "Update IDI CMake framework $OLD -> $NEW" -- "${PATHS[@]}") && \
            echo "Committed: Update IDI CMake framework $OLD -> $NEW"
    fi
fi

echo ""
echo "Framework updated $OLD -> $NEW."
if [[ $COMMIT -eq 0 && "$IN_GIT" == "TRUE" ]]; then
    echo "Review the changes with 'git diff', then commit them."
fi
