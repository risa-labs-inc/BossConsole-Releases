@echo off
setlocal EnableDelayedExpansion

:: ============================================================================
:: BOSS Universal Installation Script for Windows (CMD)
:: https://github.com/risa-labs-inc/BossConsole-Releases
::
:: Usage:
::   install.bat              - Install latest version
::   install.bat /version:X.Y.Z - Install specific version
::   install.bat /uninstall   - Uninstall BOSS
::   install.bat /dryrun      - Preview only
::   install.bat /help        - Show help
:: ============================================================================

set "GITHUB_REPO=risa-labs-inc/BossConsole-Releases"
set "GITHUB_RELEASE_URL=https://github.com/%GITHUB_REPO%/releases/download"
set "GITHUB_API_URL=https://api.github.com/repos/%GITHUB_REPO%/releases/latest"

:: Primary release source. The latest-release edge function needs no API key and
:: is not subject to GitHub's rate limit; unauthenticated api.github.com allows
:: 60 requests per hour per IP, which a shared address or a CI runner can
:: exhaust — and this script's only recourse then is to fail and ask for
:: /version by hand. GitHub stays as the fallback on both lookups and downloads.
set "LATEST_RELEASE_API=https://api.risaboss.com/functions/v1/latest-release?app=boss"
set "CDN_RELEASE_URL=https://api.risaboss.com/storage/v1/object/public/app-releases/boss"
set "SCRIPT_VERSION=1.0.0"

set "VERSION="
set "DO_UNINSTALL=0"
set "DRY_RUN=0"

:: Parse arguments
:parse_args
if "%~1"=="" goto :main
if /i "%~1"=="/help" goto :show_usage
if /i "%~1"=="-help" goto :show_usage
if /i "%~1"=="--help" goto :show_usage
if /i "%~1"=="/?" goto :show_usage
if /i "%~1"=="/uninstall" (
    set "DO_UNINSTALL=1"
    shift
    goto :parse_args
)
if /i "%~1"=="/dryrun" (
    set "DRY_RUN=1"
    shift
    goto :parse_args
)
:: Check for /version: prefix
set "ARG=%~1"
if /i "!ARG:~0,9!"=="/version:" (
    set "VERSION=!ARG:~9!"
    shift
    goto :parse_args
)
echo Unknown option: %~1
goto :show_usage

:: ============================================================================
:: Main
:: ============================================================================

:main
echo.
echo ========================================
echo  BOSS Universal Installer v%SCRIPT_VERSION%
echo ========================================
echo.

:: Detect architecture
set "ARCH=x64"
if "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "ARCH=arm64"
echo Detected: Windows / %ARCH%

:: Handle uninstall
if "%DO_UNINSTALL%"=="1" goto :uninstall

:: Get version if not specified
if "%VERSION%"=="" (
    echo Fetching latest version...
    call :get_latest_version
    if "!VERSION!"=="" (
        echo Error: Failed to fetch latest version
        exit /b 1
    )
)

echo Installing BOSS version %VERSION%...

:: Determine MSI filename
if "%ARCH%"=="arm64" (
    set "MSI_FILE=BOSS-%VERSION%-arm64.msi"
) else (
    set "MSI_FILE=BOSS-%VERSION%.msi"
)

set "DOWNLOAD_URL=%CDN_RELEASE_URL%/%VERSION%/%MSI_FILE%"
set "FALLBACK_URL=%GITHUB_RELEASE_URL%/v%VERSION%/%MSI_FILE%"
set "TEMP_MSI=%TEMP%\%MSI_FILE%"

if "%DRY_RUN%"=="1" (
    echo [DRY-RUN] Would download: %DOWNLOAD_URL%
    echo [DRY-RUN] Would run MSI installer
    goto :success
)

:: Download MSI. Both URLs point at the same asset — the CDN copy and the
:: GitHub release copy — so a bucket that has not caught up, or a version
:: predating the bucket, still installs.
echo Downloading from %DOWNLOAD_URL%...
call :download_file "%DOWNLOAD_URL%" "%TEMP_MSI%"
if errorlevel 1 (
    echo Warning: Download failed; retrying from GitHub
    echo Downloading from !FALLBACK_URL!...
    call :download_file "!FALLBACK_URL!" "%TEMP_MSI%"
    if errorlevel 1 (
        echo Error: Failed to download MSI
        exit /b 1
    )
)

:: Run installer
echo Running installer...
msiexec /i "%TEMP_MSI%" /qb
if errorlevel 1 (
    echo Error: Installation failed
    del /q "%TEMP_MSI%" 2>nul
    exit /b 1
)

:: Cleanup
del /q "%TEMP_MSI%" 2>nul

:success
echo.
echo ========================================
echo  BOSS installed successfully!
echo ========================================
echo.
echo Launch BOSS from the Start Menu or Desktop shortcut
echo.
exit /b 0

:: ============================================================================
:: Uninstall
:: ============================================================================

:uninstall
echo Uninstalling BOSS...

if "%DRY_RUN%"=="1" (
    echo [DRY-RUN] Would uninstall BOSS
    exit /b 0
)

:: Try to find and uninstall via registry
for /f "tokens=*" %%a in ('reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "BOSS" 2^>nul ^| findstr /i "UninstallString"') do (
    for /f "tokens=2,*" %%b in ("%%a") do (
        set "UNINSTALL_CMD=%%c"
    )
)

if defined UNINSTALL_CMD (
    echo Running uninstaller...
    !UNINSTALL_CMD! /qb
    echo BOSS uninstalled successfully!
) else (
    echo BOSS installation not found
)

exit /b 0

:: ============================================================================
:: Get Latest Version
:: ============================================================================

:get_latest_version
:: PowerShell does the parsing on both paths. Splitting a one-line JSON body
:: on delims in batch is far too fragile for a payload that also carries the
:: full release notes, and PowerShell ships with every supported Windows.
for /f "tokens=*" %%a in ('powershell -NoProfile -Command "try { (Invoke-RestMethod -Uri '%LATEST_RELEASE_API%' -UseBasicParsing).version } catch { }" 2^>nul') do (
    set "VERSION=%%a"
)
if not "!VERSION!"=="" goto :eof

echo Warning: Could not reach the release API; falling back to GitHub
for /f "tokens=*" %%a in ('powershell -NoProfile -Command "try { (Invoke-RestMethod -Uri '%GITHUB_API_URL%' -UseBasicParsing).tag_name.TrimStart('v') } catch { }" 2^>nul') do (
    set "VERSION=%%a"
)
goto :eof

:: ============================================================================
:: Download File
:: ============================================================================

:download_file
set "URL=%~1"
set "OUTPUT=%~2"

:: Try curl first
where curl >nul 2>&1
if %errorlevel%==0 (
    curl -fsSL "%URL%" -o "%OUTPUT%"
    exit /b %errorlevel%
)

:: Fallback to PowerShell
powershell -NoProfile -Command "Invoke-WebRequest -Uri '%URL%' -OutFile '%OUTPUT%' -UseBasicParsing"
exit /b %errorlevel%

:: ============================================================================
:: Usage
:: ============================================================================

:show_usage
echo.
echo BOSS Universal Installer v%SCRIPT_VERSION%
echo.
echo Usage:
echo     install.bat                  Install latest version
echo     install.bat /version:X.Y.Z  Install specific version
echo     install.bat /uninstall      Uninstall BOSS
echo     install.bat /dryrun         Preview only
echo     install.bat /help           Show this help
echo.
echo Examples:
echo     install.bat
echo     install.bat /version:8.15.10
echo     install.bat /uninstall
echo.
echo Supported:
echo     - Windows x64
echo     - Windows ARM64
echo.
exit /b 0
