#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$SCRIPT_DIR/tools.conf" ]]; then
    echo "ERROR: tools.conf not found. Copy tools.conf.example to tools.conf and fill in your paths."
    exit 1
fi
source "$SCRIPT_DIR/tools.conf"

export WINEPREFIX

for file in "$@"; do
    # Convert Linux path to Wine Z: drive path
    winpath="Z:$(echo "$file" | sed 's|/|\\|g')"
    wine "$FTEXTOOL" -i "$winpath"
done
