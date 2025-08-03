#!/bin/bash
# Script to set up BOSS APT repository
# This should be run after each release to update the repository

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APT_ROOT="$REPO_ROOT/apt"

echo "🔧 Setting up APT repository for BOSS..."

# Check if dpkg-scanpackages is available
if ! command -v dpkg-scanpackages &> /dev/null; then
    echo "❌ dpkg-scanpackages not found. Please install dpkg-dev:"
    echo "   sudo apt-get install dpkg-dev"
    exit 1
fi

# Check if we have a .deb file
DEB_FILE=$(find "$REPO_ROOT" -maxdepth 1 -name "BOSS-*.deb" | head -1)
if [ -z "$DEB_FILE" ]; then
    echo "❌ No .deb file found in $REPO_ROOT"
    echo "   Please download the latest .deb from releases first"
    exit 1
fi

echo "📦 Found DEB package: $(basename "$DEB_FILE")"

# Copy .deb file to pool
cp "$DEB_FILE" "$APT_ROOT/pool/main/b/boss/"
echo "✅ Copied to pool directory"

# Generate Packages file
cd "$APT_ROOT"
dpkg-scanpackages pool/main > dists/stable/main/binary-amd64/Packages
gzip -9c dists/stable/main/binary-amd64/Packages > dists/stable/main/binary-amd64/Packages.gz
echo "✅ Generated Packages file"

# Create Release file
cat > dists/stable/Release << EOF
Origin: Risa Labs
Label: BOSS
Suite: stable
Codename: stable
Version: 1.0
Architectures: amd64
Components: main
Description: BOSS - Business OS plus Simulations APT Repository
Date: $(date -Ru)
EOF

# Add checksums to Release file
echo "MD5Sum:" >> dists/stable/Release
find dists/stable/main -type f -name "Packages*" | while read file; do
    SIZE=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file")
    MD5=$(md5sum "$file" | cut -d' ' -f1)
    echo " $MD5 $SIZE ${file#dists/stable/}" >> dists/stable/Release
done

echo "SHA256:" >> dists/stable/Release
find dists/stable/main -type f -name "Packages*" | while read file; do
    SIZE=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file")
    SHA256=$(sha256sum "$file" | cut -d' ' -f1)
    echo " $SHA256 $SIZE ${file#dists/stable/}" >> dists/stable/Release
done

echo "✅ Created Release file"

# Sign Release file if GPG key is available
if command -v gpg &> /dev/null && gpg --list-secret-keys | grep -q "noreply@risa-labs.com"; then
    gpg --default-key "noreply@risa-labs.com" -abs -o dists/stable/Release.gpg dists/stable/Release
    gpg --default-key "noreply@risa-labs.com" --clearsign -o dists/stable/InRelease dists/stable/Release
    echo "✅ Signed Release file"
else
    echo "⚠️  No GPG key found for noreply@risa-labs.com"
    echo "   Repository will work but packages won't be signed"
fi

echo ""
echo "🎉 APT repository setup complete!"
echo ""
echo "To use this repository, users should run:"
echo "  curl -fsSL https://raw.githubusercontent.com/risa-labs-inc/BOSS-Releases/main/scripts/add-apt-repo.sh | bash"