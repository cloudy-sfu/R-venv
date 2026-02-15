@echo off
if "%~1"=="" (
    set "VENV_PATH=.venv"
) else (
    set "VENV_PATH=%~1"
)
pushd "%VENV_PATH%" 2>nul
if errorlevel 1 (
    echo Error: Path "%VENV_PATH%" does not exist.
    exit /b 1
)
set "RESOLVED_PATH=%CD%"
popd

set "RENVIRON_FILE=.Renviron"

REM Remove existing R_LIBS_USER line(s) and rewrite
if exist "%RENVIRON_FILE%" (
    findstr /v /b "R_LIBS_USER=" "%RENVIRON_FILE%" > "%RENVIRON_FILE%.tmp" 2>nul
    move /y "%RENVIRON_FILE%.tmp" "%RENVIRON_FILE%" >nul
)
echo R_LIBS_USER="%RESOLVED_PATH%">> "%RENVIRON_FILE%"

echo Virtual environment %RESOLVED_PATH% activated.
