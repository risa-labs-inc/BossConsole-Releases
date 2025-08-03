#!/bin/bash
# BOSS APT Repository Installation Script
# Run: curl -fsSL https://raw.githubusercontent.com/risa-labs-inc/BOSS-Releases/main/scripts/add-apt-repo.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}BOSS APT Repository Setup${NC}"
echo "=========================="

# Check if running on Debian/Ubuntu
if ! command -v apt-get &> /dev/null; then
    echo -e "${RED}Error: This script requires apt-get (Debian/Ubuntu)${NC}"
    exit 1
fi

# Check for sudo/root
if [ "$EUID" -ne 0 ]; then 
    if command -v sudo &> /dev/null; then
        echo "🔐 This script needs sudo privileges. You may be prompted for your password."
        exec sudo "$0" "$@"
    else
        echo -e "${RED}Error: This script must be run as root${NC}"
        exit 1
    fi
fi

# Detect architecture
ARCH=$(dpkg --print-architecture)
echo "🔍 Detected architecture: $ARCH"

# Check architecture before proceeding
if [ "$ARCH" != "amd64" ]; then
    if [ "$ARCH" = "arm64" ]; then
        echo -e "${RED}Error: BOSS is currently only available for amd64 (x86_64) architecture${NC}"
        echo ""
        echo "You are running on ARM64 architecture (Apple Silicon or ARM processor)."
        echo "BOSS does not yet support ARM64, but support may be added in the future."
        echo ""
        echo "Workarounds:"
        echo "1. Use an x86_64 virtual machine or container"
        echo "2. Use the JAR version with Java (if available for ARM64)"
    else
        echo -e "${RED}Error: Unsupported architecture: $ARCH${NC}"
        echo "BOSS is only available for amd64 (x86_64) architecture."
    fi
    exit 1
fi

# Add repository to sources.list.d
REPO_FILE="/etc/apt/sources.list.d/boss.list"
echo "📝 Adding BOSS repository to $REPO_FILE..."

cat > "$REPO_FILE" << EOF
# BOSS - Business OS plus Simulations
# Official APT repository
deb [trusted=yes arch=amd64] https://github.com/risa-labs-inc/BOSS-Releases/raw/main/apt stable main
EOF

echo -e "${GREEN}✅ Repository added${NC}"

# Update package list
echo "📦 Updating package list..."
apt-get update

# Check if BOSS is available
if apt-cache show boss &> /dev/null; then
    echo -e "${GREEN}✅ BOSS package is available!${NC}"
    echo ""
    echo "To install BOSS, run:"
    echo -e "  ${YELLOW}sudo apt-get install boss${NC}"
    echo ""
    echo "To remove this repository later, run:"
    echo -e "  ${YELLOW}sudo rm $REPO_FILE${NC}"
    echo -e "  ${YELLOW}sudo apt-get update${NC}"
else
    echo -e "${YELLOW}⚠️  Warning: BOSS package not found in repository${NC}"
    echo "The repository may still be updating. Try again in a few minutes."
fi