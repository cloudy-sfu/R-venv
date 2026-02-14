#!/usr/bin/env bash
# Must be sourced, not executed: source activate.sh <path>
if [ -z "$1" ]; then
    echo "Usage: source activate.sh <path>" >&2
    return 1 2>/dev/null || exit 1
fi

resolved_path="$(cd "$1" 2>/dev/null && pwd)"
if [ -z "$resolved_path" ]; then
    echo "Error: Path \"$1\" does not exist." >&2
    return 1 2>/dev/null || exit 1
fi

export R_LIBS_USER="$resolved_path"
echo "Virtual environment $resolvedPath activated."