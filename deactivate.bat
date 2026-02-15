@echo off
set "RENVIRON_FILE=.Renviron"

if not exist "%RENVIRON_FILE%" (
    echo No .Renviron file found in current directory.
    exit /b 1
)

findstr /v /b "R_LIBS_USER=" "%RENVIRON_FILE%" > "%RENVIRON_FILE%.tmp" 2>nul
move /y "%RENVIRON_FILE%.tmp" "%RENVIRON_FILE%" >nul

REM Delete .Renviron if empty
for %%A in ("%RENVIRON_FILE%") do if %%~zA==0 del "%RENVIRON_FILE%"

echo Virtual environment deactivated.
