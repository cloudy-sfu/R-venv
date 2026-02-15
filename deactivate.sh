#!/usr/bin/env bash
set -euo pipefail

RENVIRON_FILE=".Renviron"
if [ ! -f "$RENVIRON_FILE" ]; then
    echo "No .Renviron file found in current directory." >&2
    exit 1
fi

sed -i.bak '/^R_LIBS_USER=/d' "$RENVIRON_FILE" && rm -f "${RENVIRON_FILE}.bak"

# Remove file if empty (only whitespace/blank lines remain)
if [ ! -s "$RENVIRON_FILE" ] || ! grep -q '[^[:space:]]' "$RENVIRON_FILE"; then
    rm -f "$RENVIRON_FILE"
fi

echo "Virtual environment deactivated."
