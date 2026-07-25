#!/usr/bin/env bash
# Build the user-agnostic Layer 2 rust-bench image.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
source "$REPO_DIR/scripts/lib/image-names.sh"
cd "$SCRIPT_DIR/.."

USERNAME="${1:-$(whoami)}"
if [[ "$USERNAME" == "--user" ]]; then
    USERNAME="${2:-$(whoami)}"
fi

BASE_IMAGE="$(resolve_family_base_image dev "$USERNAME" || true)"
DOCKER_BUILD_ARGS=()
if [[ "${DOCKER_BUILD_NO_CACHE:-0}" == "1" ]]; then
    DOCKER_BUILD_ARGS+=(--no-cache)
fi

# Use the existing gh login as an ephemeral BuildKit secret when available.
# This prevents GitHub API rate limits while keeping the token out of image
# layers, build arguments, and command output.
GITHUB_TOKEN_VALUE=""
if command -v gh >/dev/null 2>&1; then
    GITHUB_TOKEN_VALUE="$(gh auth token 2>/dev/null || true)"
fi
if [[ -n "$GITHUB_TOKEN_VALUE" ]]; then
    DOCKER_BUILD_ARGS+=(--secret id=github_token,env=GH_TOKEN)
fi

echo "=========================================="
echo "Building Layer 2: Rust Bench"
echo "=========================================="
echo "  Tag: rust-bench:latest"
echo "  Base image: ${BASE_IMAGE:-$(family_base_image dev)}"
echo "  No cache: ${DOCKER_BUILD_NO_CACHE:-0}"
echo

if [[ -z "$BASE_IMAGE" ]]; then
    echo "Error: Layer 1 ($(family_base_image dev)) was not found." >&2
    echo "Build it first with: ../../base-image/build.sh --user $USERNAME" >&2
    exit 1
fi

if [[ -n "$GITHUB_TOKEN_VALUE" ]]; then
    GH_TOKEN="$GITHUB_TOKEN_VALUE" docker build \
        "${DOCKER_BUILD_ARGS[@]}" \
        --build-arg BASE_IMAGE="$BASE_IMAGE" \
        -f Dockerfile.layer2 \
        -t rust-bench:latest \
        .
else
    docker build \
        "${DOCKER_BUILD_ARGS[@]}" \
        --build-arg BASE_IMAGE="$BASE_IMAGE" \
        -f Dockerfile.layer2 \
        -t rust-bench:latest \
        .
fi

echo
echo "Layer 2 built successfully: rust-bench:latest"
