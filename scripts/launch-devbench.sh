#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BENCH_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if ! docker info >/dev/null 2>&1; then
    echo "Docker is not running. Start Docker and try again." >&2
    exit 1
fi

if ! command -v code >/dev/null 2>&1; then
    echo "VS Code is not on PATH. Install VS Code and Dev Containers first." >&2
    exit 1
fi

echo "Opening rustBench in VS Code..."
cd "$BENCH_DIR"
exec code .
