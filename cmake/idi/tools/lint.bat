@echo off
rem
rem @author Cliff Foster (Nou) <cliff@idi-systems.com>
rem
rem @copyright Copyright (c) 2026 International Development & Integration Systems LLC
rem
rem Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
rem
rem clang-format and clang-tidy checks for the project's own sources (Windows): src\, and demo\ with --demos.
rem Part of the IDI CMake framework (cmake/idi/tools). clang-tidy needs compile_commands.json,
rem which only the Ninja / Makefile generators write: without Ninja only clang-format runs.
rem
setlocal EnableExtensions EnableDelayedExpansion

for %%I in ("%~dp0..\..\..") do set "ROOT=%%~fI"
set "BUILD_DIR=%ROOT%\build-lint"
set "FIX=0"
set "DO_FORMAT=1"
set "DO_TIDY=1"
set "ALL_CHECKS=0"
set "NO_BUILD=0"
set "DEMOS=OFF"
set "CLANG_VERSION="
set "FILE_LIST="
set "EXTRA="

:parse
if "%~1"=="" goto parsed
if /I "%~1"=="-h" goto usage
if /I "%~1"=="--help" goto usage
if "%~1"=="/?" goto usage
if /I "%~1"=="--fix" ( set "FIX=1" & shift & goto parse )
if /I "%~1"=="--format-only" ( set "DO_TIDY=0" & shift & goto parse )
if /I "%~1"=="--tidy-only" ( set "DO_FORMAT=0" & shift & goto parse )
if /I "%~1"=="--all-checks" ( set "ALL_CHECKS=1" & shift & goto parse )
if /I "%~1"=="--no-build" ( set "NO_BUILD=1" & shift & goto parse )
if /I "%~1"=="--demos" ( set "DEMOS=ON" & shift & goto parse )
if /I "%~1"=="--clang-version" (
    set "CLANG_VERSION=%~2"
    shift & shift & goto parse
)
if /I "%~1"=="--build-dir" (
    set "BUILD_DIR=%~f2"
    shift & shift & goto parse
)
if "%~1"=="--" ( shift & goto extra )
set "ARG=%~1"
if "!ARG:~0,1!"=="-" (
    echo Unknown option: %~1
    echo Run with --help for usage.
    exit /b 2
)
if not exist "%~1" (
    echo No such file: %~1
    exit /b 2
)
if defined FILE_LIST (
    set "FILE_LIST=!FILE_LIST!;%~f1"
) else (
    set "FILE_LIST=%~f1"
)
shift
goto parse

:extra
if "%~1"=="" goto parsed
set "EXTRA=!EXTRA! %1"
shift
goto extra

:parsed
where cmake >nul 2>nul || ( echo ERROR: cmake not found on PATH & exit /b 2 )

set "GEN="
if not exist "%BUILD_DIR%\CMakeCache.txt" (
    where ninja >nul 2>nul && set "GEN=-G Ninja"
)
if not exist "%BUILD_DIR%\CMakeCache.txt" if not defined GEN if "%DO_TIDY%"=="1" (
    echo WARNING: Ninja not found; Visual Studio generators do not write compile_commands.json,
    echo          so only clang-format runs. Install Ninja ^(winget install Ninja-build.Ninja^) and run
    echo          from a Developer Command Prompt to enable clang-tidy.
    set "DO_TIDY=0"
)
set "VERSION_ARG="
if defined CLANG_VERSION set "VERSION_ARG=-DIDICMAKE_CLANG_TOOLS_VERSION=%CLANG_VERSION%"

echo [lint] Configuring %BUILD_DIR%
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
cmake -S "%ROOT%" -B "%BUILD_DIR%" %GEN% -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DIDICMAKE_LINT_DEMOS=%DEMOS% %VERSION_ARG% %EXTRA% > "%BUILD_DIR%\lint-configure.log" 2>&1
if errorlevel 1 (
    type "%BUILD_DIR%\lint-configure.log"
    echo ERROR: configure failed ^(log above^)
    exit /b 2
)
findstr /L /C:"[Lint]" "%BUILD_DIR%\lint-configure.log"

if "%DO_TIDY%"=="1" if not exist "%BUILD_DIR%\compile_commands.json" (
    echo WARNING: %BUILD_DIR% has no compile_commands.json ^(not a Ninja build^); skipping clang-tidy.
    set "DO_TIDY=0"
)

if "%DO_TIDY%"=="1" if "%NO_BUILD%"=="0" (
    echo [lint] Building ^(so generated sources exist for clang-tidy^)
    cmake --build "%BUILD_DIR%" --parallel >nul
    if errorlevel 1 (
        echo ERROR: build failed; fix it or use --no-build
        exit /b 2
    )
)

set "SCRIPT=%ROOT%\cmake\idi\scripts\lint.cmake"
set "CONFIG=%BUILD_DIR%\idi-lint-config.cmake"
set "FAILED=0"
echo.
if "%DO_FORMAT%"=="1" (
    if "%FIX%"=="1" (
        cmake "-DLINT_CONFIG=%CONFIG%" -DMODE=format "-DFILES=!FILE_LIST!" -P "%SCRIPT%" || set "FAILED=1"
    ) else (
        cmake "-DLINT_CONFIG=%CONFIG%" -DMODE=format-check "-DFILES=!FILE_LIST!" -P "%SCRIPT%" || set "FAILED=1"
    )
    echo.
)
if "%DO_TIDY%"=="1" (
    cmake "-DLINT_CONFIG=%CONFIG%" -DMODE=tidy "-DFILES=!FILE_LIST!" -P "%SCRIPT%" || set "FAILED=1"
    echo.
)
if "%ALL_CHECKS%"=="1" if "%DO_TIDY%"=="1" (
    cmake "-DLINT_CONFIG=%CONFIG%" -DMODE=tidy-report "-DFILES=!FILE_LIST!" -P "%SCRIPT%"
    echo.
)

if "%FAILED%"=="0" (
    echo All lint checks passed.
) else (
    echo Lint found problems ^(see above^).
)
exit /b %FAILED%

:usage
echo Usage: cmake\idi\tools\lint.bat [options] [files...] [-- ^<extra cmake configure args^>]
echo.
echo Checks formatting (clang-format) and runs the clang-tidy gate checks. With no files, checks
echo every project file under src\ (and demo\ with --demos); with files, checks only those.
echo Exit code 0 = clean, 1 = findings.
echo.
echo Options:
echo   --fix                 Apply clang-format to the files instead of only checking
echo   --format-only         Only run clang-format
echo   --tidy-only           Only run clang-tidy
echo   --all-checks          Also report the full .clang-tidy check list (advisory, never fails)
echo   --demos               Also lint demo\ (default off; to make it permanent set
echo                         IDICMAKE_LINT_DEMOS ON in cmake-hooks\post-options.cmake)
echo   --clang-version N     Use clang-format-N / clang-tidy-N if installed (default: newest)
echo   --build-dir DIR       Build directory used for compile_commands.json (default: build-lint)
echo   --no-build            Don't build before clang-tidy
echo   -h, --help, /?        Show this help
echo   -- ARGS...            Pass the remaining arguments to the cmake configure step
echo.
echo clang-tidy needs the Ninja generator (run from a Developer Command Prompt). Without Ninja,
echo only clang-format runs. Settings live in cmake: IDICMAKE_LINT_* in cmake\idi\functions\idi_lint.cmake.
exit /b 0
