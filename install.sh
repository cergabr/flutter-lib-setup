#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# Source utilities
source "$SCRIPT_DIR/utils/colors.sh"
source "$SCRIPT_DIR/utils/error.sh"
source "$SCRIPT_DIR/utils/file.sh"
source "$SCRIPT_DIR/utils/validation.sh"

# Source modules
source "$SCRIPT_DIR/modules/husky/husky_install.sh"
source "$SCRIPT_DIR/modules/environment/environment_setup.sh"

# Error handling
set -e
trap 'error::handle_error $? $LINENO $BASH_LINENO "$BASH_COMMAND" $(printf "::%s" ${FUNCNAME[@]:-})' ERR

# Main installation process
colors::print_info "Starting installation process..."

# Setup environments
environment::setup

# Install modules
husky::install

colors::print_success "Installation completed successfully!" 