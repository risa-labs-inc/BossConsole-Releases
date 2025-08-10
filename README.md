# BOSS - Business OS + Simulator

[![BOSS Version](https://img.shields.io/github/v/release/risa-labs-inc/BOSS-Releases.svg?label=BOSS&color=brightgreen)](https://github.com/risa-labs-inc/BOSS-Releases/releases/latest)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Windows%20%7C%20Linux-blue.svg)](https://github.com/risa-labs-inc/BOSS-Releases/releases/latest)
[![License](https://img.shields.io/badge/license-Proprietary-red.svg)](https://github.com/risa-labs-inc/BOSS-Releases/blob/main/LICENSE)
[![Downloads](https://img.shields.io/github/downloads/risa-labs-inc/BOSS-Releases/total.svg)](https://github.com/risa-labs-inc/BOSS-Releases/releases)

BOSS (Business OS + Simulator) is a sophisticated, AI-powered workspace designed for complex business operations, with specialized features for healthcare administration, workflow automation, and intelligent process management.

## 🚀 Latest Release

| Platform | Download |
|----------|----------|
| **macOS (Universal)** | [🍺 Homebrew](https://formulae.brew.sh/cask/boss) \| [📦 Download DMG](https://github.com/risa-labs-inc/BOSS-Releases/releases/latest) |
| **Windows (x64)** | [📦 Download MSI](https://github.com/risa-labs-inc/BOSS-Releases/releases/latest) |
| **Linux (DEB)** | [📦 Download DEB](https://github.com/risa-labs-inc/BOSS-Releases/releases/latest) |
| **Linux (RPM)** | [📦 Download RPM](https://github.com/risa-labs-inc/BOSS-Releases/releases/latest) |
| **Linux (JAR)** | [📦 Download JAR](https://github.com/risa-labs-inc/BOSS-Releases/releases/latest) |

> 💡 **Quick Install**: 
> - **macOS**: `brew install --cask boss` or `brew install risa-labs-inc/homebrew/boss`
> - **Linux**: Download and install DEB/RPM packages directly (see installation guide below)
> - **Windows**: Download MSI installer from releases

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
- **OS**: macOS 11.0 (Big Sur) or later
- **Architecture**: Universal (Apple Silicon + Intel)
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
- **Architecture**: x86_64 (64-bit)
- **Memory**: 4 GB RAM minimum, 8 GB recommended
- **Storage**: 500 MB available space

## 📥 Installation

### macOS

#### Option 1: Homebrew (Recommended)

**For Latest Updates (Recommended)**
```bash
# Add Risa Labs tap for fastest access to new releases
brew tap risa-labs-inc/homebrew
brew install boss
```

**Official Homebrew Cask**
```bash
# Install from official Homebrew (may have slight delay for new releases)
brew install --cask boss
```

#### Option 2: Direct Download (DMG)
1. Download the latest DMG file from [Releases](https://github.com/risa-labs-inc/BOSS-Releases/releases/latest)
2. Mount the DMG and drag BOSS to Applications
3. Launch BOSS from Applications folder

### Windows (MSI)
1. Download the latest MSI installer from [Releases](https://github.com/risa-labs-inc/BOSS-Releases/releases/latest)
2. Run the installer with administrator privileges
3. Launch BOSS from Start Menu or Desktop shortcut

### Linux

> **📝 Note**: BOSS packages are large (~250MB) and exceed GitHub's file size limits for APT repositories. We provide direct downloads from GitHub Releases instead, which is actually simpler and more reliable for large applications.

#### Ubuntu/Debian (DEB Package)

```bash
# Download latest DEB package
wget $(curl -s https://api.github.com/repos/risa-labs-inc/BOSS-Releases/releases/latest | grep "browser_download_url.*\.deb" | cut -d '"' -f 4)

# Install
sudo dpkg -i BOSS-*.deb
sudo apt-get install -f  # Fix any missing dependencies

# Launch
boss
```

**Alternative: Direct download with specific version**
```bash
# Download specific version (replace 8.11.3 with desired version)
wget https://github.com/risa-labs-inc/BOSS-Releases/releases/download/v8.11.3/BOSS-8.11.3.deb
sudo dpkg -i BOSS-8.11.3.deb
sudo apt-get install -f
```

#### RHEL/Fedora/openSUSE (RPM Package)
```bash
# Download latest RPM package
wget $(curl -s https://api.github.com/repos/risa-labs-inc/BOSS-Releases/releases/latest | grep "browser_download_url.*\.rpm" | cut -d '"' -f 4)

# Install
sudo rpm -i BOSS-*.rpm
# OR for Fedora: sudo dnf install BOSS-*.rpm

# Launch
boss
```

#### Universal Linux (JAR)
```bash
# Ensure Java 17+ is installed
java -version

# Download and run latest JAR
wget $(curl -s https://api.github.com/repos/risa-labs-inc/BOSS-Releases/releases/latest | grep "browser_download_url.*\.jar" | cut -d '"' -f 4)
java -jar BOSS-*.jar
```

## 🔄 Auto-Update

BOSS includes an intelligent auto-update system:
- **Automatic Detection**: Checks for updates on startup
- **Background Downloads**: Updates download while you work
- **Staged Installation**: Applies updates on next restart
- **Rollback Support**: Easy reversion if issues occur

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

[View detailed release history and download previous versions →](https://github.com/risa-labs-inc/BOSS-Releases/releases)

## 🏢 About Risa Labs

BOSS is developed by [Risa Labs](https://www.risalabs.ai), a company focused on building intelligent automation solutions for complex business operations.

---

**© 2025 Risa Labs Inc. All rights reserved.**

For enterprise licensing and custom deployments, contact [enterprise@risalabs.ai](mailto:enterprise@risalabs.ai)