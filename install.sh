#!/bin/bash
set -euo pipefail

REPO_URL="https://github.com/cergabr/flutter-lib-setup.git"
BRANCH="master" # Change to "main" if your default branch is main
TMP_DIR="$(mktemp -d -t flutter-lib-setup-XXXXXXXXXX)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo "Cloning $REPO_URL (branch: $BRANCH) to temporary directory..."
git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMP_DIR"

cd "$TMP_DIR"

echo "Running setup script from cloned repository..."
bash setup.sh "$@"

echo "Cleaning up temporary files..."
