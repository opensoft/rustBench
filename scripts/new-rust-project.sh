#!/usr/bin/env bash

set -euo pipefail

usage() {
    cat <<'EOF'
Usage: new-rust-project [--bin|--lib] [--edition EDITION] NAME [DIRECTORY]

Creates a Cargo project. DIRECTORY defaults to /workspace/projects/NAME when
running inside rustBench and to the current directory/NAME otherwise.
EOF
}

PROJECT_KIND="--bin"
EDITION="2024"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --bin|--lib)
            PROJECT_KIND="$1"
            shift
            ;;
        --edition)
            EDITION="${2:?--edition requires a value}"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
        *)
            break
            ;;
    esac
done

PROJECT_NAME="${1:-}"
if [[ -z "$PROJECT_NAME" ]]; then
    usage >&2
    exit 2
fi
shift

if [[ $# -gt 1 ]]; then
    usage >&2
    exit 2
fi

if [[ $# -eq 1 ]]; then
    PROJECT_DIR="$1"
elif [[ -d /workspace/projects ]]; then
    PROJECT_DIR="/workspace/projects/$PROJECT_NAME"
else
    PROJECT_DIR="$PWD/$PROJECT_NAME"
fi

if [[ -e "$PROJECT_DIR" ]]; then
    echo "Refusing to overwrite existing path: $PROJECT_DIR" >&2
    exit 1
fi

mkdir -p "$(dirname "$PROJECT_DIR")"
cargo new "$PROJECT_KIND" --edition "$EDITION" --name "$PROJECT_NAME" "$PROJECT_DIR"

echo
echo "Created Rust project: $PROJECT_DIR"
echo "Next:"
echo "  cd \"$PROJECT_DIR\""
echo "  cargo nextest run"
echo "  cargo clippy --all-targets --all-features"
