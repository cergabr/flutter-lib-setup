#!/bin/bash
set -euo pipefail

REPO_URL="https://github.com/cergabr/flutter-lib-setup.git"
BRANCH="master" # Change to "main" if your default branch is main
TMP_DIR="$(mktemp -d -t flutter-lib-setup-XXXXXXXXXX)"
ORIGINAL_PWD="$(pwd)"

# Set default values if not provided
NON_INTERACTIVE="${NON_INTERACTIVE:-1}"
ENV_NAMES="${ENV_NAMES:-production staging develop local}"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# Check if this is an update
if [ -d ".flutter-lib-setup" ]; then
    echo "Updating existing installation..."
    git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMP_DIR"
    cp -r "$TMP_DIR"/* .flutter-lib-setup/
    cd .flutter-lib-setup
    bash setup.sh "$@"
else
    echo "Cloning $REPO_URL (branch: $BRANCH) to temporary directory..."
    git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMP_DIR"
    cd "$ORIGINAL_PWD"
    echo "Running setup script from cloned repository..."
    NON_INTERACTIVE="$NON_INTERACTIVE" ENV_NAMES="$ENV_NAMES" bash "$TMP_DIR/setup.sh" "$@"
fi

echo "Cleaning up temporary files..."
