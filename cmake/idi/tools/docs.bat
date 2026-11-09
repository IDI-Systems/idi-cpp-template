@echo off
rem
rem @author Cliff Foster (Nou) <cliff@idi-systems.com>
rem
rem @copyright Copyright (c) 2025 International Development & Integration Systems LLC
rem
rem Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
rem
rem Generate the Doxygen API documentation (Windows). Part of the IDI CMake framework (cmake/idi/tools).
rem
setlocal EnableExtensions EnableDelayedExpansion

for %%I in ("%~dp0..\..\..") do set "ROOT=%%~fI"
set "BUILD_DIR=%ROOT%\build"
set "CLEAN=0"
set "OPEN=0"
set "THEME_ARG="

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
if /I "%~1"=="--no-theme" ( set "THEME_ARG=-DIDICMAKE_DOCS_THEME=OFF" & shift & goto parse )
if /I "%~1"=="--open" ( set "OPEN=1" & shift & goto parse )
echo Unknown option: %~1
echo Run with --help for usage.
exit /b 2

:parsed
where cmake >nul 2>nul || ( echo ERROR: cmake not found on PATH & exit /b 2 )
where doxygen >nul 2>nul || (
    echo ERROR: doxygen not found on PATH ^(winget install DimitriVanHeesch.Doxygen^)
    exit /b 2
)

if "%CLEAN%"=="1" (
    if exist "%BUILD_DIR%\docs" rmdir /s /q "%BUILD_DIR%\docs"
    if exist "%BUILD_DIR%\docs-theme" rmdir /s /q "%BUILD_DIR%\docs-theme"
)

set "NEED_CONFIGURE=0"
if not exist "%BUILD_DIR%\CMakeCache.txt" set "NEED_CONFIGURE=1"
if defined THEME_ARG set "NEED_CONFIGURE=1"
if "%NEED_CONFIGURE%"=="1" (
    echo [docs] Configuring %BUILD_DIR%
    cmake -S "%ROOT%" -B "%BUILD_DIR%" %THEME_ARG% || exit /b 1
)

cmake --build "%BUILD_DIR%" --target docs || exit /b 1

set "INDEX=%BUILD_DIR%\docs\html\index.html"
echo.
echo Documentation: %INDEX%
if "%OPEN%"=="1" start "" "%INDEX%"
exit /b 0

:usage
echo Usage: cmake\idi\tools\docs.bat [options]
echo.
echo Builds the 'docs' target (Doxygen + doxygen-awesome-css theme). Configures the build
echo directory first if needed. Needs doxygen on PATH.
echo.
echo Options:
echo   --build-dir DIR   Build directory (default: build)
echo   --clean           Remove the generated docs and theme before building
echo   --no-theme        Plain Doxygen output, no theme download (sticks in this build dir;
echo                     re-enable with cmake -DIDICMAKE_DOCS_THEME=ON)
echo   --open            Open the result in a browser
echo   -h, --help, /?    Show this help
echo.
echo Output: ^<build-dir^>\docs\html\index.html (or IDICMAKE_DOCS_OUTPUT_DIR\html)
exit /b 0
