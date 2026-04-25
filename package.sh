#!/usr/bin/env bash
#
# package.sh - Build a distributable zip for EllasUtilities
#
# Downloads the required Ace3 libraries, bundles them into libs/,
# and produces a ready-to-install zip file.
#
# Usage:  ./package.sh
# Output: EllasUtilities-<version>.zip

set -euo pipefail

ADDON_NAME="EllasUtilities"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$(mktemp -d)"
ACE3_REPO="https://github.com/WoWUIDev/Ace3.git"

# Read version from TOC
VERSION=$(grep -m1 '## Version:' "$SCRIPT_DIR/${ADDON_NAME}.toc" | sed 's/## Version: *//' | tr -d '\r')
VERSION="${VERSION:-dev}"
ZIPNAME="${ADDON_NAME}-${VERSION}.zip"

# Parse library list from .pkgmeta externals (single source of truth)
REQUIRED_LIBS=()
while IFS= read -r line; do
    # Match "  libs/<name>:" directory lines
    if [[ "$line" =~ ^[[:space:]]+libs/([^:]+): ]]; then
        REQUIRED_LIBS+=("${BASH_REMATCH[1]}")
    fi
done < "$SCRIPT_DIR/.pkgmeta"

if [ ${#REQUIRED_LIBS[@]} -eq 0 ]; then
    echo "ERROR: No externals found in .pkgmeta" >&2
    exit 1
fi

echo "==> Building ${ADDON_NAME} v${VERSION}"
echo "==> Required libraries: ${REQUIRED_LIBS[*]}"

# ---------- Fetch Ace3 libraries ----------
echo "==> Fetching Ace3 libraries..."
ACE3_DIR="${BUILD_DIR}/Ace3"
git clone --depth 1 --quiet "$ACE3_REPO" "$ACE3_DIR"

# ---------- Install libraries into libs/ ----------
echo "==> Installing libraries into libs/..."
for lib in "${REQUIRED_LIBS[@]}"; do
    # Skip LibStub and LibRangeCheck - they are already bundled
    if [ "$lib" = "LibStub" ] || [ "$lib" = "LibRangeCheck-3.0" ]; then
        echo "    Skipping $lib (already bundled)"
        continue
    fi

    if [ -d "$ACE3_DIR/$lib" ]; then
        rm -rf "$SCRIPT_DIR/libs/$lib"
        cp -r "$ACE3_DIR/$lib" "$SCRIPT_DIR/libs/$lib"
        echo "    Installed $lib"
    else
        echo "    WARNING: Library $lib not found in Ace3 repo" >&2
    fi
done

# ---------- Assemble addon folder ----------
DEST="${BUILD_DIR}/${ADDON_NAME}"
mkdir -p "$DEST"

# Copy top-level addon files
for f in *.toc *.lua *.xml LICENSE.md; do
    [ -f "$SCRIPT_DIR/$f" ] && cp "$SCRIPT_DIR/$f" "$DEST/"
done

# Copy subdirectories
for d in Core UI libs media; do
    if [ -d "$SCRIPT_DIR/$d" ]; then
        cp -r "$SCRIPT_DIR/$d" "$DEST/"
    fi
done

# ---------- Create zip ----------
echo "==> Creating ${ZIPNAME}..."
(cd "$BUILD_DIR" && zip -r -q "$SCRIPT_DIR/$ZIPNAME" "$ADDON_NAME")

# ---------- Cleanup ----------
rm -rf "$BUILD_DIR"

echo "==> Done: ${ZIPNAME} ($(du -h "$SCRIPT_DIR/$ZIPNAME" | cut -f1))"
