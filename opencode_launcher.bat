@echo off
setlocal EnableExtensions DisableDelayedExpansion
title OpenCode

set "SCRIPT_DIR=%~dp0"
set "MODEL_FILE=%SCRIPT_DIR%opencode_model.md"
set "UPDATE_SCRIPT=%SCRIPT_DIR%update_opencode_models.py"
set "DEFAULT_MODEL=opencode/muse-spark-1.3-contributor-free"
set "DEFAULT_MODEL_LABEL=Muse Spark 1.3 Contributor Free"

:START
cls
echo ============================================================
echo OpenCode Launcher
echo ============================================================
echo.

echo Folder path:
echo   - Paste/type a folder path
Echo   - Press ENTER to use this launcher's folder:
echo     %SCRIPT_DIR%
echo.
set "TARGET_DIR="
set /p "TARGET_DIR=Folder [ENTER = launcher folder]: "
if not defined TARGET_DIR set "TARGET_DIR=%SCRIPT_DIR%"
set "TARGET_DIR=%TARGET_DIR:"=%"

if not exist "%TARGET_DIR%\" (
    echo.
    echo [ERROR] Folder does not exist:
    echo %TARGET_DIR%
    echo.
    pause
    goto START
)

cd /d "%TARGET_DIR%"
if errorlevel 1 (
    echo.
    echo [ERROR] Cannot change directory to:
    echo %TARGET_DIR%
    echo.
    pause
    goto START
)

:SELECT_AUTO
echo.
echo ------------------------------------------------------------
echo Permission mode
echo ------------------------------------------------------------
echo [1] Normal / ask when required   ^(DEFAULT^)
echo [2] Auto approve ^(--auto^)
echo.
set "AUTO_CHOICE="
set /p "AUTO_CHOICE=Choose [1/2, ENTER=1]: "
if not defined AUTO_CHOICE set "AUTO_CHOICE=1"

if "%AUTO_CHOICE%"=="1" (
    set "AUTO_FLAG="
    set "AUTO_LABEL=Normal (non-auto)"
) else if "%AUTO_CHOICE%"=="2" (
    set "AUTO_FLAG=--auto"
    set "AUTO_LABEL=Auto approve"
) else (
    echo [ERROR] Invalid choice. Please enter 1 or 2.
    goto SELECT_AUTO
)

:SELECT_MODEL
call :LOAD_MODELS

echo.
echo ------------------------------------------------------------
echo Free OpenCode models
echo ------------------------------------------------------------
if "%MODEL_COUNT%"=="0" (
    echo [WARN] No model rows found in:
    echo        %MODEL_FILE%
    echo.
    echo [1] %DEFAULT_MODEL_LABEL%   ^(DEFAULT fallback^)
    echo     %DEFAULT_MODEL%
) else (
    call :PRINT_MODELS
)
echo.
echo [U] Update free-model list from OpenCode web API
echo [C] Custom model ID
Echo [R] Reload model file
Echo.
set "MODEL_CHOICE="
set /p "MODEL_CHOICE=Choose model [ENTER = Muse]: "

if not defined MODEL_CHOICE (
    set "MODEL=%DEFAULT_MODEL%"
    set "MODEL_LABEL=%DEFAULT_MODEL_LABEL%"
    goto MODEL_SELECTED
)

if /i "%MODEL_CHOICE%"=="U" (
    call :UPDATE_MODELS
    goto SELECT_MODEL
)
if /i "%MODEL_CHOICE%"=="R" goto SELECT_MODEL
if /i "%MODEL_CHOICE%"=="C" goto CUSTOM_MODEL

call :GET_MODEL_BY_INDEX "%MODEL_CHOICE%"
if defined MODEL goto MODEL_SELECTED

echo [ERROR] Invalid model choice.
goto SELECT_MODEL

:CUSTOM_MODEL
set "MODEL="
set /p "MODEL=Enter model ID (provider/model): "
if not defined MODEL (
    echo [ERROR] Model ID cannot be empty.
    goto SELECT_MODEL
)
set "MODEL=%MODEL:"=%"
set "MODEL_LABEL=Custom"
goto MODEL_SELECTED

:MODEL_SELECTED
echo.
echo ============================================================
echo OpenCode configuration
echo ============================================================
echo Folder : %CD%
echo Model  : %MODEL%
echo Name   : %MODEL_LABEL%
echo Mode   : %AUTO_LABEL%
echo ============================================================
echo.

where opencode >nul 2>&1
if errorlevel 1 (
    echo [ERROR] "opencode" was not found in PATH.
    echo Please install/configure OpenCode first.
    echo.
    pause
    goto START
)

echo [%DATE% %TIME%] Starting OpenCode...
echo.
if defined AUTO_FLAG (
    opencode -m "%MODEL%" %AUTO_FLAG%
) else (
    opencode -m "%MODEL%"
)
set "EXIT_CODE=%ERRORLEVEL%"

echo.
echo ============================================================
echo [%DATE% %TIME%] OpenCode exited. Exit code: %EXIT_CODE%
echo ============================================================
echo Press ENTER to run again.
echo Press Ctrl+C to close.
echo ============================================================
set /p "_RESTART="
goto START

:LOAD_MODELS
set "MODEL_COUNT=0"
if not exist "%MODEL_FILE%" exit /b 0
for /f "usebackq tokens=2,3,4 delims=|" %%A in (`findstr /b /c:"| M |" "%MODEL_FILE%"`) do (
    call :REGISTER_MODEL "%%B" "%%C"
)
exit /b 0

:REGISTER_MODEL
set "_LABEL=%~1"
set "_ID=%~2"
call :TRIM _LABEL
call :TRIM _ID
set "_ID=%_ID:`=%"
if not defined _ID exit /b 0
set /a MODEL_COUNT+=1
call set "MODEL_ID_%MODEL_COUNT%=%_ID%"
call set "MODEL_LABEL_%MODEL_COUNT%=%_LABEL%"
exit /b 0

:PRINT_MODELS
set /a _I=1
:PRINT_MODELS_LOOP
if %_I% GTR %MODEL_COUNT% exit /b 0
call set "_MID=%%MODEL_ID_%_I%%%"
call set "_MLABEL=%%MODEL_LABEL_%_I%%%"
if /i "%_MID%"=="%DEFAULT_MODEL%" (
    echo [%_I%] %_MLABEL%   ^(DEFAULT^)
) else (
    echo [%_I%] %_MLABEL%
)
echo     %_MID%
set /a _I+=1
goto PRINT_MODELS_LOOP

:GET_MODEL_BY_INDEX
set "MODEL="
set "MODEL_LABEL="
set "_IDX=%~1"
for /f "delims=0123456789" %%Z in ("%_IDX%") do exit /b 0
if "%_IDX%"=="" exit /b 0
if %_IDX% LSS 1 exit /b 0
if %_IDX% GTR %MODEL_COUNT% exit /b 0
call set "MODEL=%%MODEL_ID_%_IDX%%%"
call set "MODEL_LABEL=%%MODEL_LABEL_%_IDX%%%"
exit /b 0

:UPDATE_MODELS
echo.
echo ------------------------------------------------------------
echo Updating free models from OpenCode...
echo ------------------------------------------------------------
if not exist "%UPDATE_SCRIPT%" (
    echo [ERROR] Missing updater:
    echo        %UPDATE_SCRIPT%
    pause
    exit /b 1
)

set "PY_CMD="
where python >nul 2>&1 && set "PY_CMD=python"
if not defined PY_CMD where py >nul 2>&1 && set "PY_CMD=py -3"
if not defined PY_CMD (
    echo [ERROR] Python was not found in PATH.
    echo Install Python 3.8+ or update opencode_model.md manually.
    pause
    exit /b 1
)

%PY_CMD% "%UPDATE_SCRIPT%" --output "%MODEL_FILE%"
set "_UPD_RC=%ERRORLEVEL%"
if not "%_UPD_RC%"=="0" (
    echo.
    echo [WARN] Web update failed. Keeping last known model list.
) else (
    echo.
    echo [OK] Model list refreshed.
)
echo.
pause
exit /b %_UPD_RC%

:TRIM
setlocal EnableDelayedExpansion
set "s=!%~1!"
for /f "tokens=*" %%A in ("!s!") do set "s=%%A"
:TRIM_RIGHT
if defined s if "!s:~-1!"==" " set "s=!s:~0,-1!" & goto TRIM_RIGHT
endlocal & set "%~1=%s%"
exit /b 0
