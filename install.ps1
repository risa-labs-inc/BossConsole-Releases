#Requires -Version 5.1
<#
.SYNOPSIS
    BOSS Universal Installation Script for Windows

.DESCRIPTION
    Downloads and installs BOSS from GitHub releases.

.PARAMETER Version
    Specific version to install. If not specified, installs latest.

.PARAMETER Uninstall
    Uninstall BOSS instead of installing.

.PARAMETER DryRun
    Show what would be done without making changes.

.EXAMPLE
    # Remote installation (pipe from web)
    iwr -useb https://raw.githubusercontent.com/risa-labs-inc/BossConsole-Releases/main/install.ps1 | iex

    # Local installation with options
    .\install.ps1 -Version 8.15.10
    .\install.ps1 -Uninstall
    .\install.ps1 -DryRun

.LINK
    https://github.com/risa-labs-inc/BossConsole-Releases
#>

param(
    [string]$Version,
    [switch]$Uninstall,
    [switch]$DryRun,
    [switch]$Help
)

# ============================================================================
# Configuration
# ============================================================================

$GitHubRepo = "risa-labs-inc/BossConsole-Releases"
$GitHubReleaseUrl = "https://github.com/$GitHubRepo/releases/download"
$GitHubApiUrl = "https://api.github.com/repos/$GitHubRepo/releases/latest"
$ScriptVersion = "1.0.0"

# ============================================================================
# Output Helpers
# ============================================================================

function Write-Info {
    param([string]$Message)
    Write-Host "==> " -ForegroundColor Blue -NoNewline
    Write-Host $Message
}

function Write-Success {
    param([string]$Message)
    Write-Host "==> " -ForegroundColor Green -NoNewline
    Write-Host $Message
}

function Write-Warn {
    param([string]$Message)
    Write-Host "Warning: " -ForegroundColor Yellow -NoNewline
    Write-Host $Message
}

function Write-Err {
    param([string]$Message)
    Write-Host "Error: " -ForegroundColor Red -NoNewline
    Write-Host $Message
}

# ============================================================================
# Platform Detection
# ============================================================================

function Get-Architecture {
    $arch = $env:PROCESSOR_ARCHITECTURE
    switch ($arch) {
        "AMD64" { return "x64" }
        "ARM64" { return "arm64" }
        default { return "x64" }
    }
}

# ============================================================================
# Version Management
# ============================================================================

function Get-LatestVersion {
    try {
        $response = Invoke-RestMethod -Uri $GitHubApiUrl -UseBasicParsing
        $version = $response.tag_name -replace '^v', ''
        return $version
    }
    catch {
        Write-Err "Failed to fetch latest version: $_"
        exit 1
    }
}

# ============================================================================
# Installation
# ============================================================================

function Install-BOSS {
    param(
        [string]$Version,
        [string]$Arch
    )

    # Determine MSI filename based on architecture
    if ($Arch -eq "arm64") {
        $msiFileName = "BOSS-$Version-arm64.msi"
    } else {
        $msiFileName = "BOSS-$Version.msi"
    }

    $downloadUrl = "$GitHubReleaseUrl/v$Version/$msiFileName"
    $tempPath = Join-Path $env:TEMP $msiFileName

    Write-Info "Installing BOSS version $Version ($Arch)..."

    if ($DryRun) {
        Write-Info "[DRY-RUN] Would download: $downloadUrl"
        Write-Info "[DRY-RUN] Would run MSI installer"
        return
    }

    # Download MSI
    Write-Info "Downloading from $downloadUrl"
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath -UseBasicParsing
    }
    catch {
        Write-Err "Failed to download MSI: $_"
        exit 1
    }

    # Run MSI installer
    Write-Info "Running installer..."
    try {
        $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", "`"$tempPath`"", "/qb" -Wait -PassThru
        if ($process.ExitCode -ne 0) {
            Write-Err "MSI installer failed with exit code: $($process.ExitCode)"
            exit 1
        }
    }
    catch {
        Write-Err "Failed to run installer: $_"
        exit 1
    }
    finally {
        # Cleanup
        if (Test-Path $tempPath) {
            Remove-Item $tempPath -Force
        }
    }

    Write-Success "BOSS installed successfully!"
}

# ============================================================================
# Uninstallation
# ============================================================================

function Uninstall-BOSS {
    Write-Info "Uninstalling BOSS..."

    if ($DryRun) {
        Write-Info "[DRY-RUN] Would uninstall BOSS"
        return
    }

    # Find BOSS in installed programs
    $uninstallKey = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -like "*BOSS*" }

    if (-not $uninstallKey) {
        $uninstallKey = Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -like "*BOSS*" }
    }

    if ($uninstallKey) {
        $uninstallString = $uninstallKey.UninstallString
        if ($uninstallString -match "msiexec") {
            # Extract product code and run uninstall
            if ($uninstallString -match "\{[A-F0-9-]+\}") {
                $productCode = $Matches[0]
                Write-Info "Uninstalling product: $productCode"
                Start-Process -FilePath "msiexec.exe" -ArgumentList "/x", $productCode, "/qb" -Wait
                Write-Success "BOSS uninstalled successfully!"
            }
        }
    }
    else {
        Write-Warn "BOSS installation not found in registry"
    }

    # Ask about config
    $configPath = Join-Path $env:USERPROFILE ".boss"
    if (Test-Path $configPath) {
        $response = Read-Host "Remove configuration at $configPath? [y/N]"
        if ($response -eq 'y' -or $response -eq 'Y') {
            Remove-Item $configPath -Recurse -Force
            Write-Success "Configuration removed"
        }
        else {
            Write-Info "Configuration preserved at $configPath"
        }
    }
}

# ============================================================================
# Usage
# ============================================================================

function Show-Usage {
    @"
BOSS Universal Installer v$ScriptVersion

Usage:
    iwr -useb https://raw.githubusercontent.com/risa-labs-inc/BossConsole-Releases/main/install.ps1 | iex

    Or with options:
    .\install.ps1 [-Version <version>] [-Uninstall] [-DryRun] [-Help]

Options:
    -Version     Install specific version (default: latest)
    -Uninstall   Uninstall BOSS
    -DryRun      Show what would be done without making changes
    -Help        Show this help message

Examples:
    # Install latest version
    iwr -useb .../install.ps1 | iex

    # Install specific version
    .\install.ps1 -Version 8.15.10

    # Uninstall
    .\install.ps1 -Uninstall

Supported:
    - Windows x64
    - Windows ARM64

"@
    exit 0
}

# ============================================================================
# Main
# ============================================================================

function Main {
    if ($Help) {
        Show-Usage
    }

    $arch = Get-Architecture
    Write-Info "Detected: Windows / $arch"

    # Handle uninstall
    if ($Uninstall) {
        Uninstall-BOSS
        return
    }

    # Get version
    if (-not $Version) {
        Write-Info "Fetching latest version..."
        $Version = Get-LatestVersion
    }

    Write-Info "Version: $Version"

    # Install
    Install-BOSS -Version $Version -Arch $arch

    Write-Host ""
    Write-Success "BOSS installation complete!"
    Write-Host ""
    Write-Info "Launch BOSS from the Start Menu or Desktop shortcut"
}

# Run main
Main
