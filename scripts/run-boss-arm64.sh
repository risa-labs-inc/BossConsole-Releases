#!/bin/bash
# BOSS Runner for ARM64 Linux Systems
# This script helps run BOSS on ARM64 systems using x86_64 emulation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}BOSS ARM64 Runner${NC}"
echo "=================="
echo ""

# Check if we're on ARM64
ARCH=$(uname -m)
if [ "$ARCH" != "aarch64" ] && [ "$ARCH" != "arm64" ]; then
    echo -e "${YELLOW}Note: This script is designed for ARM64 systems.${NC}"
    echo "Your architecture: $ARCH"
    echo ""
fi

# Option 1: Try with box64 (x86_64 emulation)
if command -v box64 &> /dev/null; then
    echo -e "${GREEN}✓ Found box64${NC}"
    echo "Attempting to run BOSS with x86_64 emulation..."
    echo ""
    echo -e "${YELLOW}Command:${NC} box64 java -jar BOSS-*.jar"
    box64 java -jar BOSS-*.jar
    exit $?
fi

# Option 2: Native ARM64 Java workaround
echo -e "${YELLOW}⚠️  box64 not found${NC}"
echo ""
echo "Options to run BOSS on ARM64:"
echo ""
echo -e "${BLUE}1. Install box64 for x86_64 emulation:${NC}"
echo "   sudo apt update"
echo "   sudo apt install box64"
echo ""
echo -e "${BLUE}2. Use Docker with x86_64 emulation:${NC}"
echo "   docker run --platform linux/amd64 -it ubuntu:22.04"
echo ""
echo -e "${BLUE}3. Use QEMU user mode:${NC}"
echo "   sudo apt install qemu-user-static"
echo "   Then use an x86_64 Java runtime"
echo ""
echo -e "${BLUE}4. Wait for native ARM64 support${NC}"
echo "   BOSS currently uses Skiko (Skia for Kotlin) which doesn't"
echo "   fully support Linux ARM64 yet."
echo ""

# Try running anyway (might work with some Java versions)
echo -e "${YELLOW}Attempting to run with native Java...${NC}"
echo "(This may fail due to missing native libraries)"
echo ""

# Set environment variable that might help
export SKIKO_LIBRARY_PATH="/usr/lib/aarch64-linux-gnu"

# Try to run
java -jar BOSS-*.jar 2>&1 | while read line; do
    if [[ "$line" == *"Cannot find libskiko-linux-arm64"* ]]; then
        echo ""
        echo -e "${RED}Error: Missing native ARM64 libraries${NC}"
        echo "BOSS requires Skiko native libraries for ARM64 which are not yet available."
        echo "Please use one of the workarounds mentioned above."
        exit 1
    else
        echo "$line"
    fi
done