#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/.."

if [[ ! -f "$SCRIPT_DIR/tools.conf" ]]; then
    echo "ERROR: tools.conf not found. Copy tools.conf.example to tools.conf and fill in your paths."
    exit 1
fi
source "$SCRIPT_DIR/tools.conf"

export WINEPREFIX
LOGS_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOGS_DIR"

declare -A TOOLS=(
    ["1"]="Archive Unpacker|$FILEMONOLITH_DIR/Archive Unpacker.exe"
    ["2"]="Mass Texture Converter|$FILEMONOLITH_DIR/Mass Texture Converter.exe"
    ["3"]="SnakeBite|$SNAKEBITE_DIR/SnakeBite.exe"
    ["4"]="MakeBite|$SNAKEBITE_DIR/makebite.exe"
)

run_tool() {
    local tool_name=$(basename "$1" .exe)
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local log_file="$LOGS_DIR/${tool_name}_${timestamp}.log"

    echo "Running: $1"
    echo "Log file: $log_file"
    wine "$1" 2>&1 | tee "$log_file" | grep -v "^[0-9a-f]*:fixme:" &
}

# If an argument is provided, run it directly
if [[ -n "$1" ]]; then
    run_tool "$1"
    exit 0
fi

# Otherwise show menu
echo "MGSV Modding Tools"
echo "=================="
echo ""

for key in $(echo "${!TOOLS[@]}" | tr ' ' '\n' | sort -n); do
    IFS='|' read -r name path <<< "${TOOLS[$key]}"
    echo "  $key) $name"
done

echo ""
echo "  q) Quit"
echo ""
read -p "Select tool: " choice

if [[ "$choice" == "q" ]]; then
    exit 0
fi

if [[ -n "${TOOLS[$choice]}" ]]; then
    IFS='|' read -r name path <<< "${TOOLS[$choice]}"
    run_tool "$path"
else
    echo "Invalid selection"
    exit 1
fi
