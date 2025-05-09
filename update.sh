#!/bin/bash

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source "$SCRIPT_DIR/utils/colors.sh"
source "$SCRIPT_DIR/utils/error.sh"
source "$SCRIPT_DIR/utils/file.sh"

# Configuration
REPO_URL="https://github.com/cergabr/flutter-lib-setup.git"
BRANCH="master"

# Error handling
set -e
trap 'error::handle_error $? $LINENO $BASH_LINENO "$BASH_COMMAND" $(printf "::%s" ${FUNCNAME[@]:-})' ERR

# Main update process
colors::print_info "Starting update process..."

# Create backup of current installation
backup_dir=".flutter-lib-setup-backup-$(date +%Y%m%d_%H%M%S)"
if ! cp -r . "$backup_dir" > /dev/null 2>&1; then
    colors::print_error "Failed to create backup"
    exit 1
fi

# Create temporary directory for update
temp_dir=$(mktemp -d -t flutter-lib-setup-update-XXXXXXXXXX)

# Clone the repository
if ! git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$temp_dir" > /dev/null 2>&1; then
    colors::print_error "Failed to download update"
    rm -rf "$temp_dir"
    exit 1
fi

# Copy new files
if ! cp -r "$temp_dir"/* . > /dev/null 2>&1; then
    colors::print_error "Failed to install update"
    rm -rf "$temp_dir"
    exit 1
fi

# Cleanup
rm -rf "$temp_dir"

colors::print_success "Update completed successfully!"
colors::print_info "A backup of your previous installation is available in: $backup_dir"