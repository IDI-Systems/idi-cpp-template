@echo off
rem
rem @author Cliff Foster (Nou) <cliff@idi-systems.com>
rem
rem @copyright Copyright (c) 2025 International Development & Integration Systems LLC
rem
rem Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
rem
rem Guided IDI CMake framework update (Windows): preview, confirm, apply, verify, (optionally) commit.
rem Part of the IDI CMake framework (cmake/idi/tools); updated by the framework updater.
rem
setlocal EnableExtensions EnableDelayedExpansion

rem The update replaces this file and cmd reads batch files while running them: run from a temp copy.
if not defined IDI_UPDATE_REEXEC (
    for %%I in ("%~dp0..\..\..") do set "IDI_UPDATE_ROOT=%%~fI"
    del /q "%TEMP%\idi-update-*.bat" >nul 2>nul
    set "IDI_UPDATE_REEXEC=%TEMP%\idi-update-!RANDOM!!RANDOM!.bat"
    copy /y "%~f0" "!IDI_UPDATE_REEXEC!" >nul
    "!IDI_UPDATE_REEXEC!" %*
)
set "ROOT=%IDI_UPDATE_ROOT%"

set "SOURCE_KIND=url"
set "SOURCE="
set "REF="
set "CHECK=0"
set "YES=0"
set "FORCE=0"
set "ALLOW_DIRTY=0"
set "VERIFY=1"
set "COMMIT=0"
set "BUILD_DIR=%ROOT%\build"

:parse
if "%~1"=="" goto parsed
if /I "%~1"=="-h" goto usage
if /I "%~1"=="--help" goto usage
if "%~1"=="/?" goto usage
if /I "%~1"=="--ref" ( set "REF=%~2" & shift & shift & goto parse )
if /I "%~1"=="--url" ( set "SOURCE_KIND=url" & set "SOURCE=%~2" & shift & shift & goto parse )
if /I "%~1"=="--file" ( set "SOURCE_KIND=file" & set "SOURCE=%~f2" & shift & shift & goto parse )
if /I "%~1"=="--folder" ( set "SOURCE_KIND=folder" & set "SOURCE=%~f2" & shift & shift & goto parse )
if /I "%~1"=="--check" ( set "CHECK=1" & shift & goto parse )
if /I "%~1"=="-y" ( set "YES=1" & shift & goto parse )
if /I "%~1"=="--yes" ( set "YES=1" & shift & goto parse )
if /I "%~1"=="--force" ( set "FORCE=1" & shift & goto parse )
if /I "%~1"=="--allow-dirty" ( set "ALLOW_DIRTY=1" & shift & goto parse )
if /I "%~1"=="--no-verify" ( set "VERIFY=0" & shift & goto parse )
if /I "%~1"=="--build-dir" ( set "BUILD_DIR=%~f2" & shift & shift & goto parse )
if /I "%~1"=="--commit" ( set "COMMIT=1" & shift & goto parse )
echo Unknown option: %~1
echo Run with --help for usage.
exit /b 2

:parsed
where cmake >nul 2>nul || ( echo ERROR: cmake not found on PATH & exit /b 2 )

set "STAGE_DIR=%TEMP%\idi-update-stage-%RANDOM%%RANDOM%"
mkdir "%STAGE_DIR%"
set "WORKFLOW=%ROOT%\cmake\idi\updater\update_workflow.cmake"
set "FORCE_ARG="
if "%FORCE%"=="1" set "FORCE_ARG=-DFORCE=ON"
set "DIRTY_ARG="
if "%ALLOW_DIRTY%"=="1" set "DIRTY_ARG=-DALLOW_DIRTY=ON"
set "RC=0"

rem 1. Preflight, fetch, preview
cmake "-DROOT=%ROOT%" "-DSTAGE_DIR=%STAGE_DIR%" %FORCE_ARG% %DIRTY_ARG% -DMODE=stage "-DSOURCE_KIND=%SOURCE_KIND%" "-DSOURCE=%SOURCE%" "-DREF=%REF%" -P "%WORKFLOW%"
if errorlevel 1 ( set "RC=1" & goto cleanup )

for /f "usebackq tokens=1,* delims==" %%A in ("%STAGE_DIR%\status.txt") do set "ST_%%A=%%B"
set "PATHS="
for /f "usebackq delims=" %%P in ("%STAGE_DIR%\paths.txt") do set "PATHS=!PATHS! %%P"
set "ROLLBACK=git checkout --%PATHS% && git clean -fd --%PATHS%"

if "%ST_STATUS%"=="up-to-date" (
    echo Nothing to do ^(use --force to re-apply^).
    goto cleanup
)
if "%CHECK%"=="1" (
    echo.
    echo Check only: no files were changed.
    goto cleanup
)

rem 2. Confirm
if "%YES%"=="0" (
    echo.
    set "ANSWER="
    set /p "ANSWER=Apply the update %ST_OLD% -> %ST_NEW%? [y/N] "
    set "OK=0"
    if /I "!ANSWER!"=="y" set "OK=1"
    if /I "!ANSWER!"=="yes" set "OK=1"
    if "!OK!"=="0" (
        echo Cancelled. No files were changed.
        goto cleanup
    )
)

rem 3. Apply (through the configure-time updater)
cmake "-DROOT=%ROOT%" "-DSTAGE_DIR=%STAGE_DIR%" %FORCE_ARG% -DMODE=apply -P "%WORKFLOW%"
if errorlevel 1 (
    if "%ST_GIT%"=="TRUE" echo Undo any partial changes with: !ROLLBACK!
    set "RC=1"
    goto cleanup
)

rem 4. Report, using the updated framework's workflow script
if exist "%WORKFLOW%" cmake "-DROOT=%ROOT%" "-DSTAGE_DIR=%STAGE_DIR%" -DMODE=post -P "%WORKFLOW%"

rem 5. Verify
if "%VERIFY%"=="1" (
    echo.
    echo Verifying: configure, build and test in %BUILD_DIR%
    set "VERIFY_OK=1"
    cmake -S "%ROOT%" -B "%BUILD_DIR%" || set "VERIFY_OK=0"
    if "!VERIFY_OK!"=="1" cmake --build "%BUILD_DIR%" --parallel || set "VERIFY_OK=0"
    if "!VERIFY_OK!"=="1" ctest --test-dir "%BUILD_DIR%" -C Debug --output-on-failure || set "VERIFY_OK=0"
    if "!VERIFY_OK!"=="0" (
        echo.
        echo Verification FAILED after the update %ST_OLD% -^> %ST_NEW%.
        echo Check the 'Manual steps' in cmake\idi\CHANGELOG.md, or roll back with:
        if "%ST_GIT%"=="TRUE" echo     !ROLLBACK!
        set "RC=1"
        goto cleanup
    )
)

rem 6. Commit
if "%COMMIT%"=="1" (
    if not "%ST_GIT%"=="TRUE" (
        echo Not a git work tree: skipping --commit.
    ) else (
        pushd "%ROOT%"
        git add -A --%PATHS% && git commit -q -m "Update IDI CMake framework %ST_OLD% -> %ST_NEW%" --%PATHS% && echo Committed: Update IDI CMake framework %ST_OLD% -^> %ST_NEW%
        popd
    )
)

echo.
echo Framework updated %ST_OLD% -^> %ST_NEW%.
if "%COMMIT%"=="0" if "%ST_GIT%"=="TRUE" echo Review the changes with 'git diff', then commit them.

:cleanup
if exist "%STAGE_DIR%" rmdir /s /q "%STAGE_DIR%"
if exist "%ROOT%\.idi-framework-update" rmdir /s /q "%ROOT%\.idi-framework-update"
if exist "%ROOT%\.idi_framework_dl" del /q "%ROOT%\.idi_framework_dl"
exit /b %RC%

:usage
echo Usage: cmake\idi\tools\update.bat [options]
echo.
echo Updates the framework-owned files (cmake\idi\, src\base\, .claude\skills\idi-cmake\, the root and
echo src\ CMakeLists.txt, lib\.gitignore) from a newer template, with a preview first.
echo.
echo Steps: check the git tree is clean, fetch the update, show the version change, the files that
echo will change and the changelog, ask, apply, show the diff summary, rebuild and run the tests,
echo optionally commit. Nothing outside the framework-owned paths is touched.
echo.
echo Source (default: GitHub, master branch):
echo   --ref REF           Branch or tag of the template repository (e.g. v6.4.0)
echo   --url URL           Archive URL; {ref} in it is replaced by --ref
echo   --file ARCHIVE      A local .zip of the template
echo   --folder DIR        A local checkout of the template
echo.
echo Options:
echo   --check             Only preview; change nothing
echo   -y, --yes           Don't ask for confirmation
echo   --force             Apply even if the project is already at that version
echo   --allow-dirty       Allow uncommitted changes (the update is then mixed into them)
echo   --no-verify         Skip the rebuild + ctest after updating
echo   --build-dir DIR     Build directory used for verification (default: build)
echo   --commit            Commit the framework-owned paths after a successful update
echo   -h, --help, /?      Show this help
echo.
echo Environment:
echo   IDI_TEMPLATE_UPDATE_URL   Default archive URL, with {ref} (e.g. an internal GitLab mirror)
echo.
echo Examples:
echo   cmake\idi\tools\update.bat --check
echo   cmake\idi\tools\update.bat --ref v6.4.0 --commit
echo   cmake\idi\tools\update.bat --folder ..\idi-cpp-template
exit /b 0
