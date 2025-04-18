#!/bin/bash

# Module namespace
COMMON_MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
PROJECT_ROOT="$(cd "${COMMON_MODULE_DIR}/.." &> /dev/null && pwd)"

# Source utility functions
#shellcheck source=../utils/colors.sh
source "${PROJECT_ROOT}/utils/colors.sh"

# Function to validate input is a number
validate_number() {
    local input=$1
    if [[ "$input" =~ ^[0-9]+$ ]] && [ "$input" -gt 0 ]; then
        return 0
    else
        print_error "Please enter a valid number greater than 0"
        return 1
    fi
}

# Function to create directory if it doesn't exist
ensure_directory_exists() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        print_success "Created directory: $dir"
    fi
}

# Function to check if a file exists
check_file_exists() {
    local file=$1
    if [ -f "$file" ]; then
        return 0
    else
        return 1
    fi
}

# Function to get user input with validation
get_validated_input() {
    local prompt=$1
    local validation_func=$2
    local error_message=$3
    
    while true; do
        read -r -p "$prompt" input
        if $validation_func "$input"; then
            echo "$input"
            break
        fi
        if [ -n "$error_message" ]; then
            print_error "$error_message"
        fi
    done
} 