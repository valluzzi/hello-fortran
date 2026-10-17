@echo off
setlocal enabledelayedexpansion

REM CMake build script for hello-fortran project
REM Usage: compile.bat [Release^|Debug] [ifort^|gfortran] [clean^|run]
REM Example: compile.bat Release ifort
REM          compile.bat Debug gfortran clean
REM          compile.bat Release ifort run

REM Configuration
set BUILD_DIR=build
set BUILD_TYPE=%1
if "!BUILD_TYPE!"=="" set BUILD_TYPE=Release
set COMPILER=%2
if "!COMPILER!"=="" set COMPILER=ifort
set CLEAN_FLAG=%3
set TARGET=hello-fortran

REM Helper functions
goto start

:print_info
echo [INFO] %~1
goto :eof

:print_step
echo [STEP] %~1
goto :eof

:print_warn
echo [WARN] %~1
goto :eof

:start
REM Check CMake availability
where cmake >nul 2>nul
if !errorlevel! neq 0 (
    REM CMake not in PATH, check common installation locations
    if exist "C:\cmake\bin\cmake.exe" (
        set "PATH=C:\cmake\bin;!PATH!"
    ) else if exist "C:\Program Files\CMake\bin\cmake.exe" (
        set "PATH=C:\Program Files\CMake\bin;!PATH!"
    ) else (
        call :print_warn "CMake not found. Please install CMake or add it to PATH."
        exit /b 1
    )
)

for /f "tokens=*" %%i in ('cmake --version ^| findstr /r "version"') do set CMAKE_VERSION=%%i
call :print_info "Using CMake: !CMAKE_VERSION!"
call :print_info "Build type: !BUILD_TYPE!"
call :print_info "Compiler: !COMPILER!"

REM Clean build option
if /i "!CLEAN_FLAG!"=="clean" (
    call :print_step "Cleaning build directory"
    if exist "!BUILD_DIR!" (
        rmdir /s /q "!BUILD_DIR!"
    )
)

REM For ifort, clean the cache to avoid generator conflicts
if /i "!COMPILER!"=="ifort" (
    if exist "!BUILD_DIR!\CMakeCache.txt" (
        call :print_step "Cleaning CMake cache for generator switch"
        del /q "!BUILD_DIR!\CMakeCache.txt" 2>nul
        rmdir /s /q "!BUILD_DIR!\CMakeFiles" 2>nul
    )
)

REM Check compiler availability
where !COMPILER! >nul 2>nul
if !errorlevel! neq 0 (
    REM Compiler not in PATH, check common locations
    if /i "!COMPILER!"=="ifort" (
        REM Check Intel OneAPI installation paths
        if exist "C:\Program Files (x86)\Intel\oneAPI\compiler\latest\windows\bin\intel64\ifort.exe" (
            call :print_info "Found ifort"
            set "PATH=C:\Program Files (x86)\Intel\oneAPI\compiler\latest\windows\bin\intel64;!PATH!"
        ) else if exist "C:\Program Files\Intel\oneAPI\compiler\latest\windows\bin\intel64\ifort.exe" (
            call :print_info "Found ifort"
            set "PATH=C:\Program Files\Intel\oneAPI\compiler\latest\windows\bin\intel64;!PATH!"
        ) else if exist "C:\Program Files (x86)\Intel\oneAPI\setvars.bat" (
            call :print_info "Running Intel OneAPI setvars.bat..."
            REM Set Visual Studio installation paths for setvars.bat
            if exist "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools" (
                set "VS2022INSTALLDIR=C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools"
            ) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2022\Community" (
                set "VS2022INSTALLDIR=C:\Program Files (x86)\Microsoft Visual Studio\2022\Community"
            ) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2022\Professional" (
                set "VS2022INSTALLDIR=C:\Program Files (x86)\Microsoft Visual Studio\2022\Professional"
            )
            call "C:\Program Files (x86)\Intel\oneAPI\setvars.bat" intel64 >nul 2>&1
        ) else (
            call :print_warn "Intel Fortran (ifort) not found"
            call :print_warn "Install Intel HPC Toolkit: https://www.intel.com/content/www/us/en/developer/tools/oneapi/hpc-toolkit-download.html"
            exit /b 1
        )
    ) else if /i "!COMPILER!"=="gfortran" (
        REM Check Scoop/MinGW installation
        if exist "C:\Users\%USERNAME%\scoop\apps\gcc\current\bin\gfortran.exe" (
            set "PATH=C:\Users\%USERNAME%\scoop\apps\gcc\current\bin;!PATH!"
        ) else if exist "C:\mingw64\bin\gfortran.exe" (
            set "PATH=C:\mingw64\bin;!PATH!"
        ) else (
            call :print_warn "GFortran not found"
            call :print_warn "Install via Scoop: scoop install gcc"
            exit /b 1
        )
    ) else (
        call :print_warn "Compiler !COMPILER! not found in PATH"
        exit /b 1
    )
)

REM Verify compiler is now available
where !COMPILER! >nul 2>nul
if !errorlevel! neq 0 (
    call :print_warn "Compiler still not found"
    exit /b 1
)

for /f "tokens=*" %%i in ('!COMPILER! --version 2^>nul ^| findstr /r "version"') do set COMPILER_VERSION=%%i
call :print_info "Using: !COMPILER! !COMPILER_VERSION!"

REM Get full path to compiler
for /f "tokens=*" %%i in ('where !COMPILER!') do set COMPILER_PATH=%%i
if not "!COMPILER_PATH!"=="" (
    call :print_info "Compiler path: !COMPILER_PATH!"
) else (
    set "COMPILER_PATH=!COMPILER!"
    call :print_warn "Could not resolve full path, using: !COMPILER!"
)

REM Configure
call :print_step "Configuring project with CMake"
set CMAKE_ARGS=-B "!BUILD_DIR!" -DCMAKE_BUILD_TYPE="!BUILD_TYPE!" -DFORTRAN_COMPILER="!COMPILER_PATH!" -G "Ninja"

cmake !CMAKE_ARGS!
if !errorlevel! neq 0 (
    call :print_warn "CMake configuration failed"
    exit /b 1
)

REM Build
call :print_step "Building project"
cmake --build "!BUILD_DIR!" --parallel %NUMBER_OF_PROCESSORS%
if !errorlevel! neq 0 (
    call :print_warn "Build failed"
    exit /b 1
)

call :print_info "Build completed successfully"

REM Check if run flag was provided
if /i "!CLEAN_FLAG!"=="run" (
    call :print_step "Running application"
    "%~dp0hello-fortran.exe"
    if !errorlevel! neq 0 (
        call :print_warn "Application exited with code !errorlevel!"
    )
)

endlocal
