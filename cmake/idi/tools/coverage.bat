@echo off
rem
rem @author Cliff Foster (Nou) <cliff@idi-systems.com>
rem
rem @copyright Copyright (c) 2025 International Development & Integration Systems LLC
rem
rem Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
rem
rem Code coverage in one step (Windows). Part of the IDI CMake framework (cmake/idi/tools).
rem MSVC has no gcov-style coverage, so this uses Ninja + clang (or gcc) from PATH.
rem
setlocal EnableExtensions EnableDelayedExpansion

for %%I in ("%~dp0..\..\..") do set "ROOT=%%~fI"
set "BUILD_DIR=%ROOT%\build-coverage"
set "CLEAN=0"
set "OPEN=0"
set "FAIL_UNDER="
set "EXTRA="

:parse
if "%~1"=="" goto parsed
if /I "%~1"=="-h" goto usage
if /I "%~1"=="--help" goto usage
if "%~1"=="/?" goto usage
if /I "%~1"=="--build-dir" (
    set "BUILD_DIR=%~f2"
    shift & shift & goto parse
)
if /I "%~1"=="--clean" ( set "CLEAN=1" & shift & goto parse )
if /I "%~1"=="--open" ( set "OPEN=1" & shift & goto parse )
if /I "%~1"=="--fail-under" (
    set "FAIL_UNDER=%~2"
    shift & shift & goto parse
)
if "%~1"=="--" ( shift & goto extra )
echo Unknown option: %~1
goto usage_error

:extra
if "%~1"=="" goto parsed
set "EXTRA=!EXTRA! %1"
shift
goto extra

:parsed
where cmake >nul 2>nul || ( echo ERROR: cmake not found on PATH & exit /b 2 )

if not defined CC (
    where clang >nul 2>nul && ( set "CC=clang" & set "CXX=clang++" )
)
if not defined CC (
    where gcc >nul 2>nul && ( set "CC=gcc" & set "CXX=g++" )
)
if not defined CC (
    echo ERROR: coverage needs clang or gcc on PATH ^(MSVC is not supported^).
    echo        Install LLVM ^(winget install LLVM.LLVM^) or set CC / CXX.
    exit /b 2
)

if "%CLEAN%"=="1" if exist "%BUILD_DIR%" (
    echo [coverage] Removing %BUILD_DIR%
    rmdir /s /q "%BUILD_DIR%"
)

set "GEN="
if not exist "%BUILD_DIR%\CMakeCache.txt" (
    where ninja >nul 2>nul || (
        echo ERROR: coverage on Windows needs the Ninja generator ^(winget install Ninja-build.Ninja^).
        exit /b 2
    )
    set "GEN=-G Ninja"
)
set "FAIL_ARG="
if defined FAIL_UNDER set "FAIL_ARG=-DIDICMAKE_COVERAGE_FAIL_UNDER=%FAIL_UNDER%"

echo [coverage] Configuring %BUILD_DIR% with CC=%CC%
cmake -S "%ROOT%" -B "%BUILD_DIR%" %GEN% -DCODE_COVERAGE=ON %FAIL_ARG% %EXTRA% || exit /b 1

echo [coverage] Building
cmake --build "%BUILD_DIR%" --parallel || exit /b 1

echo [coverage] Running tests and generating the report
cmake --build "%BUILD_DIR%" --target ccov-all || exit /b 1

set "REPORT=%BUILD_DIR%\reports\coverage\html\index.html"
if exist "%REPORT%" (
    echo.
    echo Coverage report: %REPORT%
    if "%OPEN%"=="1" start "" "%REPORT%"
) else (
    echo.
    echo No HTML report was written ^(pip install gcovr^). Raw coverage data is in %BUILD_DIR%.
)
exit /b 0

:usage
echo Usage: cmake\idi\tools\coverage.bat [options] [-- ^<extra cmake configure args^>]
echo.
echo Builds the project with coverage instrumentation in a separate build directory, runs all
echo tests (ctest) and writes the report. Needs Ninja and clang or gcc; gcovr for reports.
echo.
echo Options:
echo   --build-dir DIR     Coverage build directory (default: build-coverage)
echo   --clean             Delete the coverage build directory first
echo   --fail-under PCT    Fail if line coverage is below PCT percent (e.g. 80)
echo   --open              Open the HTML report when done
echo   -h, --help, /?      Show this help
echo.
echo The compiler comes from CC / CXX (default: clang, then gcc on PATH).
echo Output: ^<build-dir^>\reports\coverage\html\index.html and coverage.xml
exit /b 0

:usage_error
echo Run with --help for usage.
exit /b 2
