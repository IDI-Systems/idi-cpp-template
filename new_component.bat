@echo off
rem
rem @author Cliff Foster (Nou) <cliff@idi-systems.com>
rem
rem @copyright Copyright (c) 2026 International Development & Integration Systems LLC
rem
rem Licensed under a modified MIT License, see TEMPLATE_LICENSE for full license details
rem
rem Create a new component in src\<name>\ from cmake\idi\templates\template_component.
rem
setlocal EnableExtensions EnableDelayedExpansion

if "%~1"=="" (
    call :usage
    exit /b 1
)
if /I "%~1"=="-h" goto help
if /I "%~1"=="--help" goto help
if "%~1"=="/?" goto help
if not "%~2"=="" (
    echo Error: expected one component name. Run new_component.bat --help for usage.
    exit /b 1
)

set "NAME=%~1"
for %%I in ("%~dp0.") do set "ROOT=%%~fI"
if not defined BUILD_DIR set "BUILD_DIR=%ROOT%\build"

rem lower_snake_case: starts with a-z, then a-z 0-9 _ only (findstr classes are case-insensitive, so check case separately)
echo(!NAME!| findstr /R /X "[a-z][a-z0-9_]*" >nul
if errorlevel 1 goto bad_name
for %%U in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    echo(!NAME!| findstr /C:"%%U" >nul && goto bad_name
)
if /I "%NAME%"=="main" goto reserved
if /I "%NAME%"=="core" goto reserved
if /I "%NAME%"=="public" goto reserved

if exist "%ROOT%\src\%NAME%" (
    echo Error: src\%NAME% already exists. The template would overwrite its files; pick another name or remove it first.
    exit /b 1
)
where cmake >nul 2>nul || ( echo Error: cmake not found on PATH & exit /b 1 )

echo Creating component '%NAME%' in src\%NAME% ...
cmake -S "%ROOT%" -B "%BUILD_DIR%" "-DNEW_COMPONENT_NAME=%NAME%"
if errorlevel 1 (
    echo Error: CMake failed while creating component '%NAME%' ^(see output above^).
    exit /b 1
)
if not exist "%ROOT%\src\%NAME%\CMakeLists.txt" (
    echo Error: src\%NAME% was not created ^(see output above^).
    exit /b 1
)

echo.
echo Component '%NAME%' created in src\%NAME%.
echo Next: add this line to src\components.cmake, then re-configure:
echo.
echo     add_subdirectory(%NAME%)
echo.
exit /b 0

:bad_name
echo Error: '%NAME%' is not a valid component name. Use lower_snake_case: a-z, 0-9 and _, starting with a letter.
exit /b 1

:reserved
echo Error: '%NAME%' is reserved by the framework (src\main, ^<project^>_core, ^<project^>_public).
exit /b 1

:help
call :usage
exit /b 0

:usage
echo Usage: new_component.bat ^<component_name^>
echo.
echo Creates src\^<component_name^>\ from the framework's component template:
echo   src\^<name^>\CMakeLists.txt              idi_component(^<name^> base) - list dependencies here
echo   src\^<name^>\objects.cmake               .cpp files (idi_add_sources)
echo   src\^<name^>\^<name^>.cpp                  example source
echo   src\^<name^>\include\^<project^>\          C++ headers (include.cmake)
echo   src\^<name^>\include\^<project^>\public\   exported C headers for shared builds (public.cmake)
echo   src\^<name^>\tests\                      Catch2 tests (tests.cmake)
echo.
echo The name must be lower_snake_case (a-z, 0-9, _; starts with a letter). It becomes the
echo target ^<project^>_^<name^> and the C++ namespace ^<vendor^>::^<app^>::^<name^>.
echo.
echo Afterwards, add the component to src\components.cmake:
echo   add_subdirectory(^<name^>)
echo and re-configure (cmake -S . -B build).
echo.
echo Options:
echo   -h, --help, /?   Show this help
echo.
echo Environment:
echo   BUILD_DIR        Build directory to configure (default: build)
echo.
echo Same as running: cmake -S . -B build -DNEW_COMPONENT_NAME=^<name^>
exit /b 0
