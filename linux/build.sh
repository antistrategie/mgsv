#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/.."

if [[ ! -f "$SCRIPT_DIR/tools.conf" ]]; then
    echo "ERROR: tools.conf not found. Copy tools.conf.example to tools.conf and fill in your paths."
    exit 1
fi
source "$SCRIPT_DIR/tools.conf"

export WINEPREFIX
MOD_DIR="$REPO_DIR/mod"
MOD_WINE_PATH="M:\\mgsv\\mod"

echo "=== Building mod with MakeBite ==="
wine "$SNAKEBITE_DIR/makebite.exe" "$MOD_WINE_PATH" 2>&1 | grep -v "^[0-9a-f]*:fixme:"

# MakeBite outputs mod.mgsv inside the mod folder
MOD_FILE="$MOD_DIR/mod.mgsv"

if [[ ! -f "$MOD_FILE" ]]; then
    echo "ERROR: mod.mgsv was not created"
    exit 1
fi

echo ""
echo "=== Uninstalling previous version ==="
wine "$SNAKEBITE_DIR/SnakeBite.exe" -u "Metal Girl Solid" -x 2>&1 | grep -v "^[0-9a-f]*:fixme:"

echo ""
echo "=== Installing mod with SnakeBite ==="
wine "$SNAKEBITE_DIR/SnakeBite.exe" -i "M:\\mgsv\\mod\\mod.mgsv" -c -x 2>&1 | grep -v "^[0-9a-f]*:fixme:"

echo ""
echo "=== Done ==="
