@echo off
REM Must be sourced, not executed: call activate.bat <path>
if "%~1"=="" (
    echo Usage: activate.bat ^<path^>
    exit /b 1
)
pushd "%~1" 2>nul
if errorlevel 1 (
    echo Error: Path "%~1" does not exist.
    exit /b 1
)
set "R_LIBS_USER=%CD%"
popd
echo Virtual environment %R_LIBS_USER% activated.