# BOSS - Business OS + Simulator

[![BOSS Version](https://img.shields.io/github/v/release/risa-labs-inc/BossConsole-Releases.svg?label=BOSS&color=brightgreen)](https://github.com/risa-labs-inc/BossConsole-Releases/releases/latest)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Windows%20%7C%20Linux-blue.svg)](https://github.com/risa-labs-inc/BossConsole-Releases/releases/latest)
[![License](https://img.shields.io/badge/license-Apache_2.0-blue.svg)](https://github.com/risa-labs-inc/BossConsole-Releases/blob/main/LICENSE)
[![Downloads](https://img.shields.io/github/downloads/risa-labs-inc/BossConsole-Releases/total.svg)](https://github.com/risa-labs-inc/BossConsole-Releases/releases)

BOSS (Business OS + Simulator) is a sophisticated, AI-powered workspace designed for complex business operations, with specialized features for healthcare administration, workflow automation, and intelligent process management.

## 🚀 Latest Release

Every link below downloads the newest release directly — no version to look up, nothing to keep current.

| Platform | Architecture | Download |
|----------|--------------|----------|
| **macOS** | Universal (Apple Silicon + Intel) | [🍺 Homebrew](https://formulae.brew.sh/cask/boss) \| [📦 DMG](https://api.risaboss.com/functions/v1/latest-release?app=boss&download=dmg) |
| **Windows** | x64 | [📦 MSI](https://api.risaboss.com/functions/v1/latest-release?app=boss&download=msi) |
| **Windows** | ARM64 | [📦 MSI](https://api.risaboss.com/functions/v1/latest-release?app=boss&download=msi&arch=arm64) |
| **Linux** | AMD64 | [📦 DEB](https://api.risaboss.com/functions/v1/latest-release?app=boss&download=deb&arch=amd64) \| [📦 RPM](https://api.risaboss.com/functions/v1/latest-release?app=boss&download=rpm&arch=amd64) \| [📦 JAR](https://api.risaboss.com/functions/v1/latest-release?app=boss&download=jar&arch=amd64) |
| **Linux** | ARM64 | [📦 DEB](https://api.risaboss.com/functions/v1/latest-release?app=boss&download=deb&arch=arm64) \| [📦 RPM](https://api.risaboss.com/functions/v1/latest-release?app=boss&download=rpm&arch=arm64) \| [📦 JAR](https://api.risaboss.com/functions/v1/latest-release?app=boss&download=jar&arch=arm64) |

These redirect to the current installer and need no API key. Release metadata — version, every asset, sha256 checksums — is at [`?app=boss`](https://api.risaboss.com/functions/v1/latest-release?app=boss). Pre-releases are excluded by default; add `&prerelease=true` to any link to consider them too, and `&channel=beta` (or `alpha`, `rc`) to track a single channel. To browse or pin a specific version, see [all releases](https://github.com/risa-labs-inc/BossConsole-Releases/releases).

> 💡 **Quick Install (Recommended)**:
> ```bash
> # macOS/Linux
> curl -fsSL https://raw.githubusercontent.com/risa-labs-inc/BossConsole-Releases/main/install.sh | bash
> ```
> ```powershell
> # Windows (PowerShell)
> iwr -useb https://raw.githubusercontent.com/risa-labs-inc/BossConsole-Releases/main/install.ps1 | iex
> ```

## 📋 What is BOSS?

BOSS is an integrated workspace that combines **AI automation**, **configurable layouts**, and **intelligent workflow management** into a unified platform. It's designed for organizations that need:

- 🏥 **Healthcare Operations**: Prior authorization, patient triage, EHR management
- 🤖 **AI-Powered Automation**: LLM integration with robotic process automation
- ⚙️ **Workflow Optimization**: Configurable workspaces for different business roles
- 🔗 **System Integration**: Unified interface for multiple tools and data sources

## ✨ Key Features

### 🏗️ Modular Workspace Architecture
- **Configurable Panels**: Customizable layout with specialized components
- **Multi-Tab Browser**: Integrated web browsing with automation capabilities  
- **Code Editor**: Built-in development environment
- **Terminal Integration**: Full command-line interface

### 🤖 AI & Automation
- **LLM RPA Engine**: Large Language Model integration with process automation
- **Smart Workflows**: AI-powered task resolution and pattern recognition
- **Browser Automation**: Automated web-based task execution
- **Intelligent Routing**: Context-aware workflow optimization

### 📊 Specialized Modules
- **EHR Explorer**: Electronic Health Records navigation and analysis
- **System of Records**: Centralized data source management
- **Task Resolver**: Registry for workflow resolution patterns
- **Activity Monitor**: Real-time process tracking and analytics

### 🔧 Enterprise Features
- **Auto-Update System**: Seamless application updates
- **Configuration Management**: Save and restore workspace layouts
- **Version Control Integration**: Built-in Git support
- **Cross-Platform Support**: macOS, Windows, Linux compatibility

## 🏥 Healthcare Focus

BOSS excels in healthcare administrative workflows:

- **Prior Authorization**: Streamlined CPT-Code processing and approval workflows
- **Patient Triage**: Intelligent patient routing and priority management
- **Medical Authorization**: Automated authorization request processing
- **Surgery Coordination**: EV/BV procedure management and scheduling
- **Compliance Management**: Regulatory workflow automation

## 🎯 Preconfigured Workspaces

BOSS includes optimized layouts for different roles:

- **🏥 PriorAuth**: PA Dashboard, OncoEMR, CoverMyMeds integration
- **🎨 Designer**: Figma, Canva, Notion workspace
- **💻 Coder**: GitHub, Terminal, Stack Overflow environment
- **📧 Mail**: Gmail, LinkedIn, Twitter communication hub

## 💻 System Requirements

### macOS
- **OS**: macOS 13.0 (Ventura) or later
- **Architecture**: Universal (Apple Silicon native, Intel via Rosetta 2)
- **Memory**: 4 GB RAM minimum, 8 GB recommended
- **Storage**: 500 MB available space

### Windows
- **OS**: Windows 10 (64-bit) or later
- **Memory**: 4 GB RAM minimum, 8 GB recommended
- **Storage**: 500 MB available space
- **Runtime**: Java 17+ (bundled with installer)

### Linux
- **DEB Package**: Ubuntu 18.04+ / Debian 10+ / Linux Mint 19+
- **RPM Package**: RHEL 8+ / Fedora 30+ / openSUSE 15+ / CentOS 8+
- **JAR Package**: Any Linux distribution with Java 17+
- **Architecture**: AMD64 (x86_64) and ARM64 (aarch64)
- **Memory**: 4 GB RAM minimum, 8 GB recommended
- **Storage**: 500 MB available space

## 📥 Installation

### Universal Install Script (Recommended)

The easiest way to install BOSS on any platform. The script automatically detects your OS and architecture.

#### macOS / Linux
```bash
curl -fsSL https://raw.githubusercontent.com/risa-labs-inc/BossConsole-Releases/main/install.sh | bash
```

**Options:**
```bash
# Install specific version
curl -fsSL .../install.sh | bash -s -- --version 8.15.10

# Dry run (preview without installing)
curl -fsSL .../install.sh | bash -s -- --dry-run

# Reinstall over an existing install without being asked
curl -fsSL .../install.sh | bash -s -- --force

# Uninstall
curl -fsSL .../install.sh | bash -s -- --uninstall
```

Upgrading over an existing install is the normal path and needs no flag: when
there is a terminal you are asked to confirm, and when there isn't — a CI step,
a provisioning script — it proceeds. `--force` skips the question outright. It
never removes your configuration; an uninstall only does that if you confirm it
at a terminal.

#### Windows (PowerShell)
```powershell
iwr -useb https://raw.githubusercontent.com/risa-labs-inc/BossConsole-Releases/main/install.ps1 | iex
```

**Options:**
```powershell
# Install specific version
.\install.ps1 -Version 8.15.10

# Dry run
.\install.ps1 -DryRun

# Uninstall
.\install.ps1 -Uninstall
```

#### Windows (CMD)
```batch
curl -fsSL https://raw.githubusercontent.com/risa-labs-inc/BossConsole-Releases/main/install.bat -o install.bat && install.bat
```

---

### Alternative Installation Methods

<details>
<summary><strong>macOS: Homebrew</strong></summary>

```bash
# Add Risa Labs tap for fastest access to new releases
brew tap risa-labs-inc/homebrew
brew install --cask boss

# Or from official Homebrew (may have slight delay for new releases)
brew install --cask boss

# Upgrade
brew update && brew upgrade --cask boss
```
</details>

<details>
<summary><strong>macOS: Direct Download (DMG)</strong></summary>

1. Download [BOSS for macOS](https://api.risaboss.com/functions/v1/latest-release?app=boss&download=dmg) — one Universal DMG covers Apple Silicon and Intel
2. Mount the DMG and drag BOSS to Applications
3. Launch BOSS from Applications folder
</details>

<details>
<summary><strong>Windows: Direct Download (MSI)</strong></summary>

1. Download the installer for your architecture — [x64](https://api.risaboss.com/functions/v1/latest-release?app=boss&download=msi) or [ARM64](https://api.risaboss.com/functions/v1/latest-release?app=boss&download=msi&arch=arm64)
2. Run the installer with administrator privileges
3. Launch BOSS from Start Menu or Desktop shortcut
</details>

<details>
<summary><strong>Linux: Manual Package Installation</strong></summary>

> **📝 Note**: BOSS packages are large (~250MB) and exceed GitHub's file size limits for APT repositories. We provide direct downloads instead.

Swap `arch=amd64` for `arch=arm64` on an aarch64 machine. Quote the URL — the shell would otherwise read `&` as "run in background".

**Ubuntu/Debian (DEB Package)**
```bash
# Download latest DEB package
curl -fL -o boss-latest.deb "https://api.risaboss.com/functions/v1/latest-release?app=boss&download=deb&arch=amd64"

# Install — apt resolves dependencies and honours Recommends (dpkg -i skips those)
sudo apt-get install ./boss-latest.deb

# Launch
boss
```

**RHEL/Fedora/openSUSE (RPM Package)**
```bash
# Download latest RPM package
curl -fL -o boss-latest.rpm "https://api.risaboss.com/functions/v1/latest-release?app=boss&download=rpm&arch=amd64"

# Install
sudo rpm -i boss-latest.rpm
# OR for Fedora: sudo dnf install boss-latest.rpm

# Launch
boss
```

**Universal Linux (JAR)**
```bash
# Ensure Java 17+ is installed
java -version

# Download and run latest JAR
curl -fL -o boss-latest.jar "https://api.risaboss.com/functions/v1/latest-release?app=boss&download=jar&arch=amd64"
java -jar boss-latest.jar
```

> Pass `-o <name>`, not `-O`. There is no `Content-Disposition` header on these
> downloads, so `curl -O` would name the file after the URL's last path
> segment — `latest-release` — rather than the installer. A browser resolves
> the redirect first and does save `BOSS-<version>-amd64.deb`.
</details>

## 🔄 Updates

### Built-in Auto-Update
BOSS includes an intelligent auto-update system:
- **Automatic Detection**: Checks for updates on startup
- **Background Downloads**: Updates download while you work
- **Staged Installation**: Applies updates on next restart
- **Rollback Support**: Easy reversion if issues occur

> **⚠️ Important for versions < 8.11.4**: If you're running BOSS version 8.11.3 or earlier, the auto-update system has a version comparison bug that prevents it from detecting newer versions. Please manually update to 8.11.4 or later using the methods below to restore proper auto-update functionality.

### Manual Updates
**Homebrew Users (macOS)**
```bash
# Update to latest version via Homebrew
brew update && brew upgrade --cask boss
```

**Direct Download Users**
- Download the latest version from the [table at the top of this page](#-latest-release)
- Install over existing installation (settings preserved)

> **🍎 Apple Silicon Users**: Version 8.11.4 includes a critical fix for a crash that prevented BOSS from launching on Apple Silicon Macs. If you're experiencing startup crashes, please update to 8.11.4 or later immediately.

## 🛠️ Configuration

### First Launch
1. **Workspace Selection**: Choose from preconfigured layouts or create custom
2. **LLM Integration**: Configure AI providers (optional)
3. **Data Sources**: Connect to your systems of record
4. **Automation Setup**: Configure RPA workflows

### Custom Layouts
- **Panel Management**: Drag and drop panels to customize workspace
- **Tab Configuration**: Set up specialized tabs for your workflows
- **Keyboard Shortcuts**: Customize hotkeys for efficiency
- **Profile Export**: Save and share workspace configurations

## 🆘 Support & Documentation

- **Issues**: Report bugs and feature requests in this repository
- **Community**: Join discussions in GitHub Discussions
- **Enterprise Support**: Contact [support@risalabs.ai](mailto:support@risalabs.ai)
- **Documentation**: Comprehensive guides available in-app

## 🔐 Security

BOSS takes security seriously:
- **Code Signing**: All releases are digitally signed
- **Encrypted Storage**: Sensitive data encrypted at rest
- **Secure Communication**: TLS encryption for all network traffic
- **Regular Updates**: Security patches delivered via auto-update

See our [Security Policy](SECURITY.md) for detailed information.

## 📊 Release History

BOSS follows semantic versioning with regular updates including new features, performance improvements, and security patches. Each release includes:

- **Performance Enhancements**: Continuous optimization for better speed and efficiency
- **New Features**: Regular addition of AI capabilities and workflow improvements  
- **Security Updates**: Proactive security patches and vulnerability fixes
- **UI/UX Improvements**: Enhanced user experience and interface refinements
- **Bug Fixes**: Resolution of reported issues and stability improvements

[View detailed release history and download previous versions →](https://github.com/risa-labs-inc/BossConsole-Releases/releases)

## 🏢 About Risa Labs

BOSS is developed by [Risa Labs](https://www.risalabs.ai), a company focused on building intelligent automation solutions for complex business operations.

---

**© 2025-2026 Risa Labs Inc.** Licensed under the [Apache License, Version 2.0](LICENSE). The installers bundle third-party components under their own terms — including a commercial browser library and a GPL+CE Java runtime. See [NOTICE](NOTICE).

For enterprise licensing and custom deployments, contact [enterprise@risalabs.ai](mailto:enterprise@risalabs.ai)