#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
utils::print_colored() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to print success message
utils::print_success() {
    utils::print_colored "$GREEN" "$1"
}

# Function to print error message
utils::print_error() {
    utils::print_colored "$RED" "$1"
}

# Function to print warning message
utils::print_warning() {
    utils::print_colored "$YELLOW" "$1"
}

# Function to print info message
utils::print_info() {
    utils::print_colored "$BLUE" "$1"
}