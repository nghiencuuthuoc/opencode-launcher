@echo off
setlocal EnableExtensions DisableDelayedExpansion
title OpenCode Launcher

set "DEFAULT_MODEL=opencode/muse-spark-1.3-contributor-free"
set "SCRIPT_DIR=%~dp0"

:START
cls
echo ============================================================
echo OpenCode Launcher
echo ============================================================
echo.
echo Folder path:
echo   - Paste/type a folder path
echo   - Press ENTER to use this launcher's folder:
echo     %SCRIPT_DIR%
echo.
set "TARGET_DIR="
set /p "TARGET_DIR=Folder [ENTER = launcher folder]: "

if not defined TARGET_DIR set "TARGET_DIR=%SCRIPT_DIR%"

rem Remove surrounding quotes if user pasted a quoted path
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
echo.
echo ------------------------------------------------------------
echo Model
echo ------------------------------------------------------------
echo [1] Muse Spark 1.3 Contributor Free   ^(DEFAULT^)
echo     %DEFAULT_MODEL%
echo [2] Custom model ID
echo.
set "MODEL_CHOICE="
set /p "MODEL_CHOICE=Choose [1/2, ENTER=1]: "
if not defined MODEL_CHOICE set "MODEL_CHOICE=1"

if "%MODEL_CHOICE%"=="1" (
    set "MODEL=%DEFAULT_MODEL%"
) else if "%MODEL_CHOICE%"=="2" (
    set "MODEL="
    set /p "MODEL=Enter model ID (provider/model): "
    if not defined MODEL (
        echo [ERROR] Model ID cannot be empty.
        goto SELECT_MODEL
    )
    set "MODEL=%MODEL:"=%"
) else (
    echo [ERROR] Invalid choice. Please enter 1 or 2.
    goto SELECT_MODEL
)

echo.
echo ============================================================
echo OpenCode configuration
echo ============================================================
echo Folder : %CD%
echo Model  : %MODEL%
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

echo Starting OpenCode...
echo.

if defined AUTO_FLAG (
    opencode -m "%MODEL%" %AUTO_FLAG%
) else (
    opencode -m "%MODEL%"
)

set "EXIT_CODE=%ERRORLEVEL%"

echo.
echo ============================================================
echo OpenCode exited. Exit code: %EXIT_CODE%
echo ============================================================
echo Press ENTER to run again.
echo Press Ctrl+C to close.
echo ============================================================
set /p "_RESTART="
goto START
