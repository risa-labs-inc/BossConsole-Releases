#!/bin/bash
# BOSS APT Repository Removal Script
# Run: curl -fsSL https://raw.githubusercontent.com/risa-labs-inc/BOSS-Releases/main/scripts/remove-apt-repo.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}BOSS APT Repository Removal${NC}"
echo "============================"

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

REPO_FILE="/etc/apt/sources.list.d/boss.list"

if [ -f "$REPO_FILE" ]; then
    echo "🗑️  Removing BOSS repository..."
    rm -f "$REPO_FILE"
    echo -e "${GREEN}✅ Repository removed${NC}"
    
    echo "📦 Updating package list..."
    apt-get update
    
    echo -e "${GREEN}✅ BOSS repository has been removed${NC}"
else
    echo -e "${YELLOW}⚠️  BOSS repository not found${NC}"
    echo "Nothing to remove."
fi