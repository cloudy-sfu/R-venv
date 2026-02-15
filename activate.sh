#!/usr/bin/env bash
set -euo pipefail

VENV_PATH="${1:-.venv}"

resolved_path="$(cd "$VENV_PATH" 2>/dev/null && pwd)"
if [ -z "$resolved_path" ]; then
    echo "Error: Path \"$VENV_PATH\" does not exist." >&2
    exit 1
fi

# Write/overwrite R_LIBS_USER in .Renviron (current directory)
RENVIRON_FILE=".Renviron"
if [ -f "$RENVIRON_FILE" ]; then
    # Remove existing R_LIBS_USER line(s)
    sed -i.bak '/^R_LIBS_USER=/d' "$RENVIRON_FILE" && rm -f "${RENVIRON_FILE}.bak"
fi
echo "R_LIBS_USER=\"${resolved_path}\"" >> "$RENVIRON_FILE"

echo "Virtual environment ${resolved_path} activated."
