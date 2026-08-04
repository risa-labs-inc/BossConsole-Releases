#!/usr/bin/env bash
#
# BOSS Universal Installation Script
# https://github.com/risa-labs-inc/BossConsole-Releases
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/risa-labs-inc/BossConsole-Releases/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/risa-labs-inc/BossConsole-Releases/main/install.sh | bash -s -- --version 8.15.10
#   curl -fsSL https://raw.githubusercontent.com/risa-labs-inc/BossConsole-Releases/main/install.sh | bash -s -- --uninstall
#
# Or run locally:
#   ./install.sh
#   ./install.sh --uninstall
#   ./install.sh --dry-run
#

set -e

# ============================================================================
# Configuration
# ============================================================================

GITHUB_REPO="risa-labs-inc/BossConsole-Releases"
GITHUB_RELEASE_URL="https://github.com/${GITHUB_REPO}/releases/download"
GITHUB_API_URL="https://api.github.com/repos/${GITHUB_REPO}/releases/latest"

# Primary release source. The latest-release edge function needs no API key and
# is not subject to GitHub's rate limit; unauthenticated api.github.com allows
# 60 requests per hour per IP, which a shared address or a CI runner can
# exhaust — and this script's only recourse then is to tell the user to pass
# --version by hand. GitHub stays as the fallback on both lookups and downloads.
LATEST_RELEASE_API="https://api.risaboss.com/functions/v1/latest-release?app=boss"
CDN_RELEASE_URL="https://api.risaboss.com/storage/v1/object/public/app-releases/boss"

# Installation paths
MACOS_APP_PATH="/Applications/BOSS.app"
CLI_SYSTEM_PATH="/usr/local/bin/boss"
CLI_USER_PATH="${HOME}/.local/bin/boss"
CONFIG_PATH="${HOME}/.boss"

# Script version
SCRIPT_VERSION="1.0.0"

# ============================================================================
# Colors and Output
# ============================================================================

if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    BOLD=''
    NC=''
fi

info() {
    echo -e "${BLUE}==>${NC} ${BOLD}$1${NC}"
}

success() {
    echo -e "${GREEN}==>${NC} ${BOLD}$1${NC}"
}

# Diagnostics go to stderr, like error(). get_latest_version's stdout IS its
# return value, so a warning on stdout would be captured into the version
# string and produce a download URL built from the warning text.
warn() {
    echo -e "${YELLOW}Warning:${NC} $1" >&2
}

error() {
    echo -e "${RED}Error:${NC} $1" >&2
}

# ============================================================================
# Platform Detection
# ============================================================================

detect_os() {
    local os
    os="$(uname -s)"
    case "$os" in
        Darwin) echo "darwin" ;;
        Linux)  echo "linux" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *)      echo "unknown" ;;
    esac
}

detect_arch() {
    local arch
    arch="$(uname -m)"
    case "$arch" in
        x86_64|amd64)  echo "amd64" ;;
        arm64|aarch64) echo "arm64" ;;
        *)             echo "unknown" ;;
    esac
}

detect_distro() {
    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        echo "${ID:-unknown}"
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/redhat-release ]; then
        echo "rhel"
    else
        echo "unknown"
    fi
}

has_command() {
    command -v "$1" >/dev/null 2>&1
}

has_sudo() {
    if has_command sudo; then
        sudo -n true 2>/dev/null || sudo -v 2>/dev/null
        return $?
    fi
    return 1
}

is_root() {
    [ "$(id -u)" -eq 0 ]
}

# True when we can run commands as root, either directly or via sudo.
# Containers and minimal servers often run as root without sudo installed.
has_root_access() {
    is_root || has_sudo
}

# Run a command as root: directly when already root, via sudo otherwise.
as_root() {
    if is_root; then
        "$@"
    else
        sudo "$@"
    fi
}

# ============================================================================
# Version Management
# ============================================================================

fetch_url() {
    local url="$1"
    if has_command curl; then
        curl -sL "$url" 2>/dev/null
    elif has_command wget; then
        wget -qO- "$url" 2>/dev/null
    fi
}

get_latest_version() {
    local version

    # The edge function answers with {"app":"boss","version":"X.Y.Z",...}.
    # `release_notes` in that payload escapes its own quotes, so a literal
    # "version": inside the notes cannot match this pattern.
    version=$(fetch_url "$LATEST_RELEASE_API" \
        | grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' \
        | head -1 \
        | sed -E 's/.*"([^"]+)"$/\1/')

    if [ -z "$version" ]; then
        warn "Could not reach the release API; falling back to GitHub"
        version=$(fetch_url "$GITHUB_API_URL" | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/' | head -1)
    fi

    if [ -z "$version" ]; then
        error "Failed to fetch latest version. Please specify a version with --version"
        exit 1
    fi

    # Refuse anything that is not a bare version. This function's stdout is its
    # return value, so any stray output here would otherwise be pasted into a
    # download URL and fail much later with an unrecognisable message.
    if ! echo "$version" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+(-(alpha|beta|rc)\.[0-9]+)?$'; then
        error "Resolved version is not a version number: '$version'"
        error "Please specify a version with --version"
        exit 1
    fi

    echo "$version"
}

# ============================================================================
# Download Helpers
# ============================================================================

fetch_to_file() {
    local url="$1"
    local output="$2"

    if has_command curl; then
        curl -fL --progress-bar "$url" -o "$output"
    elif has_command wget; then
        wget -q --show-progress "$url" -O "$output"
    else
        error "Neither curl nor wget found. Please install one of them."
        exit 1
    fi
}

# Downloads $1, falling back to $3 if given. Both point at the same asset —
# the CDN copy and the GitHub release copy — so a bucket that has not caught
# up, or a version predating the bucket, still installs.
download_file() {
    local url="$1"
    local output="$2"
    local fallback_url="${3:-}"

    info "Downloading from $url"

    if fetch_to_file "$url" "$output"; then
        return 0
    fi

    if [ -n "$fallback_url" ]; then
        warn "Download failed; retrying from GitHub"
        info "Downloading from $fallback_url"
        if fetch_to_file "$fallback_url" "$output"; then
            return 0
        fi
        error "Failed to download from both sources:"
        error "  $url"
        error "  $fallback_url"
        exit 1
    fi

    error "Failed to download $url"
    exit 1
}

# ============================================================================
# Installation Detection
# ============================================================================

check_installed() {
    local os="$1"

    case "$os" in
        darwin)
            [ -d "$MACOS_APP_PATH" ] && return 0
            ;;
        linux)
            has_command boss && return 0
            dpkg -l boss >/dev/null 2>&1 && return 0
            rpm -q boss >/dev/null 2>&1 && return 0
            ;;
    esac

    return 1
}

# ============================================================================
# macOS Installation
# ============================================================================

install_macos_dmg() {
    local version="$1"
    local asset="BOSS-${version}-Universal.dmg"
    local dmg_url="${CDN_RELEASE_URL}/${version}/${asset}"
    local dmg_fallback_url="${GITHUB_RELEASE_URL}/v${version}/${asset}"
    local tmp_dmg
    local mount_point

    info "Installing BOSS from DMG (version ${version})..."

    if [ "$DRY_RUN" = true ]; then
        info "[DRY-RUN] Would download: $dmg_url"
        info "[DRY-RUN] Would install to: $MACOS_APP_PATH"
        return 0
    fi

    # Create temp file
    tmp_dmg=$(mktemp /tmp/BOSS-XXXXXX.dmg)

    # Download Universal DMG (works on Apple Silicon and Intel via Rosetta 2)
    download_file "$dmg_url" "$tmp_dmg" "$dmg_fallback_url"

    # Mount DMG
    info "Mounting DMG..."
    mount_point=$(hdiutil attach "$tmp_dmg" -nobrowse -noautoopen | grep "/Volumes/" | sed 's/.*\/Volumes/\/Volumes/')

    if [ -z "$mount_point" ]; then
        error "Failed to mount DMG"
        rm -f "$tmp_dmg"
        exit 1
    fi

    # Copy app to Applications
    info "Installing to /Applications..."
    if [ -d "$MACOS_APP_PATH" ]; then
        warn "Removing existing installation..."
        rm -rf "$MACOS_APP_PATH"
    fi

    cp -R "${mount_point}/BOSS.app" "$MACOS_APP_PATH"

    # Unmount and cleanup
    hdiutil detach "$mount_point" -quiet
    rm -f "$tmp_dmg"

    # Remove quarantine attribute
    xattr -rd com.apple.quarantine "$MACOS_APP_PATH" 2>/dev/null || true

    success "BOSS installed to /Applications"
}

# ============================================================================
# Linux Installation
# ============================================================================

install_linux_deb() {
    local version="$1"
    local arch="$2"
    local asset="BOSS-${version}-${arch}.deb"
    local deb_url="${CDN_RELEASE_URL}/${version}/${asset}"
    local deb_fallback_url="${GITHUB_RELEASE_URL}/v${version}/${asset}"
    local tmp_deb

    info "Installing BOSS from Deb package (version ${version}, arch ${arch})..."

    if [ "$DRY_RUN" = true ]; then
        info "[DRY-RUN] Would download: $deb_url"
        info "[DRY-RUN] Would install via dpkg"
        return 0
    fi

    # Create temp file
    tmp_deb=$(mktemp /tmp/boss-XXXXXX.deb)

    # Download Deb
    download_file "$deb_url" "$tmp_deb" "$deb_fallback_url"

    # Install
    info "Installing package..."
    if has_root_access; then
        as_root dpkg -i "$tmp_deb" || true
        as_root apt-get install -f -y
    else
        error "root privileges (or sudo) are required to install Deb packages"
        rm -f "$tmp_deb"
        exit 1
    fi

    # Cleanup
    rm -f "$tmp_deb"

    success "BOSS installed via Deb package"
}

install_linux_rpm() {
    local version="$1"
    local arch="$2"
    local rpm_arch
    local asset
    local rpm_url
    local rpm_fallback_url
    local tmp_rpm

    # Map architecture
    case "$arch" in
        amd64) rpm_arch="x86_64" ;;
        arm64) rpm_arch="aarch64" ;;
        *)
            error "Unsupported architecture for RPM package: $arch"
            return 1
            ;;
    esac

    asset="BOSS-${version}-${arch}.rpm"
    rpm_url="${CDN_RELEASE_URL}/${version}/${asset}"
    rpm_fallback_url="${GITHUB_RELEASE_URL}/v${version}/${asset}"

    info "Installing BOSS from RPM package (version ${version}, arch ${rpm_arch})..."

    if [ "$DRY_RUN" = true ]; then
        info "[DRY-RUN] Would download: $rpm_url"
        info "[DRY-RUN] Would install via rpm/dnf"
        return 0
    fi

    # Create temp file
    tmp_rpm=$(mktemp /tmp/boss-XXXXXX.rpm)

    # Download RPM
    download_file "$rpm_url" "$tmp_rpm" "$rpm_fallback_url"

    # Install
    info "Installing package..."
    if has_root_access; then
        if has_command dnf; then
            as_root dnf install -y "$tmp_rpm"
        elif has_command yum; then
            as_root yum install -y "$tmp_rpm"
        else
            as_root rpm -i "$tmp_rpm"
        fi
    else
        error "root privileges (or sudo) are required to install RPM packages"
        rm -f "$tmp_rpm"
        exit 1
    fi

    # Cleanup
    rm -f "$tmp_rpm"

    success "BOSS installed via RPM package"
}

install_linux() {
    local version="$1"
    local arch="$2"
    local distro

    distro=$(detect_distro)

    case "$distro" in
        ubuntu|debian|linuxmint|pop|elementary|zorin)
            install_linux_deb "$version" "$arch"
            ;;
        fedora|rhel|centos|rocky|almalinux|opensuse*)
            install_linux_rpm "$version" "$arch"
            ;;
        *)
            # Default to deb if dpkg available, else rpm
            if has_command dpkg; then
                install_linux_deb "$version" "$arch"
            elif has_command rpm; then
                install_linux_rpm "$version" "$arch"
            else
                error "Unsupported Linux distribution: $distro"
                error "Please install manually from: https://github.com/${GITHUB_REPO}/releases"
                exit 1
            fi
            ;;
    esac
}

# ============================================================================
# CLI Launcher
# ============================================================================

install_cli() {
    local os="$1"
    local install_path

    if [ "$SKIP_CLI" = true ]; then
        return 0
    fi

    info "Installing CLI launcher..."

    # Determine installation path
    if [ -w "/usr/local/bin" ] || has_root_access; then
        install_path="$CLI_SYSTEM_PATH"
    else
        install_path="$CLI_USER_PATH"
        mkdir -p "$(dirname "$install_path")"
    fi

    if [ "$DRY_RUN" = true ]; then
        info "[DRY-RUN] Would create CLI at: $install_path"
        return 0
    fi

    # Create launcher script
    local launcher_content
    case "$os" in
        darwin)
            launcher_content='#!/bin/bash
# BOSS CLI Launcher
open -a BOSS "$@"'
            ;;
        linux)
            launcher_content='#!/bin/bash
# BOSS CLI Launcher
/opt/boss/bin/BOSS "$@"'
            ;;
    esac

    if [ "$install_path" = "$CLI_SYSTEM_PATH" ] && ! [ -w "/usr/local/bin" ]; then
        echo "$launcher_content" | as_root tee "$install_path" > /dev/null
        as_root chmod +x "$install_path"
    else
        echo "$launcher_content" > "$install_path"
        chmod +x "$install_path"
    fi

    success "CLI launcher installed at $install_path"

    # Warn about PATH if user-level install
    if [ "$install_path" = "$CLI_USER_PATH" ]; then
        warn "Add ~/.local/bin to your PATH to use 'boss' command"
    fi
}

# ============================================================================
# Uninstall
# ============================================================================

uninstall() {
    local os="$1"

    info "Uninstalling BOSS..."

    if [ "$DRY_RUN" = true ]; then
        info "[DRY-RUN] Would remove BOSS installation"
        return 0
    fi

    case "$os" in
        darwin)
            if [ -d "$MACOS_APP_PATH" ]; then
                rm -rf "$MACOS_APP_PATH"
                success "Removed $MACOS_APP_PATH"
            fi
            ;;
        linux)
            if dpkg -l boss >/dev/null 2>&1; then
                as_root dpkg -r boss
                success "Removed BOSS deb package"
            elif rpm -q boss >/dev/null 2>&1; then
                as_root rpm -e boss
                success "Removed BOSS rpm package"
            fi
            ;;
    esac

    # Remove CLI
    if [ -f "$CLI_SYSTEM_PATH" ]; then
        if has_root_access; then
            as_root rm -f "$CLI_SYSTEM_PATH"
        else
            rm -f "$CLI_SYSTEM_PATH"
        fi
        success "Removed CLI launcher"
    fi

    if [ -f "$CLI_USER_PATH" ]; then
        rm -f "$CLI_USER_PATH"
        success "Removed user CLI launcher"
    fi

    # Ask about config
    if [ -d "$CONFIG_PATH" ]; then
        echo ""
        read -p "Remove configuration at $CONFIG_PATH? [y/N] " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$CONFIG_PATH"
            success "Removed configuration"
        else
            info "Configuration preserved at $CONFIG_PATH"
        fi
    fi

    success "BOSS uninstalled successfully"
}

# ============================================================================
# Usage
# ============================================================================

show_usage() {
    cat << EOF
BOSS Universal Installer v${SCRIPT_VERSION}

Usage:
    curl -fsSL https://raw.githubusercontent.com/risa-labs-inc/BossConsole-Releases/main/install.sh | bash
    curl -fsSL ... | bash -s -- [OPTIONS]

Options:
    --version VERSION    Install specific version (default: latest)
    --uninstall          Uninstall BOSS
    --dry-run            Show what would be done without making changes
    --skip-cli           Skip CLI launcher installation
    --help               Show this help message

Examples:
    # Install latest version
    curl -fsSL .../install.sh | bash

    # Install specific version
    curl -fsSL .../install.sh | bash -s -- --version 8.15.10

    # Uninstall
    curl -fsSL .../install.sh | bash -s -- --uninstall

    # Dry run
    ./install.sh --dry-run

Supported Platforms:
    - macOS (Intel & Apple Silicon)
    - Linux (AMD64 & ARM64, Debian/Ubuntu/Fedora/RHEL)

EOF
    exit 0
}

# ============================================================================
# Main
# ============================================================================

main() {
    local os
    local arch
    local version=""
    local do_uninstall=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --version)
                version="$2"
                shift 2
                ;;
            --uninstall)
                do_uninstall=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --skip-cli)
                SKIP_CLI=true
                shift
                ;;
            --help|-h)
                show_usage
                ;;
            *)
                error "Unknown option: $1"
                show_usage
                ;;
        esac
    done

    # Detect platform
    os=$(detect_os)
    arch=$(detect_arch)

    info "Detected: $os / $arch"

    if [ "$os" = "unknown" ]; then
        error "Unsupported operating system"
        exit 1
    fi

    if [ "$os" = "windows" ]; then
        error "Windows detected. Please use install.ps1 or install.bat instead."
        error "PowerShell: iwr -useb .../install.ps1 | iex"
        exit 1
    fi

    # Handle uninstall
    if [ "$do_uninstall" = true ]; then
        uninstall "$os"
        exit 0
    fi

    # Get version
    if [ -z "$version" ]; then
        info "Fetching latest version..."
        version=$(get_latest_version)
    fi

    info "Installing BOSS version $version"

    # Check for existing installation
    if check_installed "$os"; then
        warn "BOSS appears to be already installed"
        if [ "$FORCE" != true ]; then
            read -p "Continue with installation? [y/N] " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                info "Installation cancelled"
                exit 0
            fi
        fi
    fi

    # Install based on OS
    case "$os" in
        darwin)
            install_macos_dmg "$version"
            ;;
        linux)
            install_linux "$version" "$arch"
            ;;
    esac

    # Install CLI launcher
    install_cli "$os"

    echo ""
    success "BOSS installation complete!"
    echo ""
    info "Launch BOSS:"
    case "$os" in
        darwin)
            echo "    open -a BOSS"
            echo "    or use Spotlight: Cmd+Space, type 'BOSS'"
            ;;
        linux)
            echo "    boss"
            echo "    or find BOSS in your application menu"
            ;;
    esac
}

# Run main with all arguments
main "$@"
