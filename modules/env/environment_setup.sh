#!/bin/bash

# Source common utilities
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../common.sh"

# Function to validate environment names
_validate_name() {
    local env_name=$1
    
    # Check if name is empty
    if [ -z "$env_name" ]; then
        colors::print_error "Environment name cannot be empty"
        return 1
    fi
    
    # Check if name contains only valid characters (letters, numbers, underscore)
    if ! [[ "$env_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
        colors::print_error "Environment name can only contain letters, numbers, and underscores"
        return 1
    fi
    
    # Check if name is too long (arbitrary limit of 50 characters)
    if [ ${#env_name} -gt 50 ]; then
        colors::print_error "Environment name is too long (max 50 characters)"
        return 1
    fi
    
    return 0
}

# Function to check if environment name already exists
_check_exists() {
    local env_name=$1
    if [ -f "environments/${env_name}.json" ]; then
        colors::print_error "Environment '${env_name}' already exists"
        return 1
    fi
    return 0
}

# Main environment setup function
environment::setup() {
    colors::print_info "Starting environment setup..."

    # Ask user if they want to install environments
    local install_envs
    if [ "${NON_INTERACTIVE:-}" = "1" ]; then
        install_envs="y"
    else
        while true; do
            read -r -p "Do you want to install environments? (y/n): " install_envs
            case "$install_envs" in
                [Yy]) break ;;
                [Nn]) colors::print_info "Skipping environment installation."; return 0 ;;
                *) colors::print_warning "Please answer y or n." ;;
            esac
        done
    fi

    # Check for existing non-empty environment folders in project root or lib
    local env_folder_names=("env" "envs" "environment" "environments")
    local search_dirs=("." "./lib")
    for dir in "${search_dirs[@]}"; do
        for folder in "${env_folder_names[@]}"; do
            local candidate="${dir}/${folder}"
            if [ -d "$candidate" ] && [ "$(ls -A "$candidate" 2>/dev/null)" ]; then
                colors::print_error "Found non-empty environment folder: $candidate"
                colors::print_error "Please clean up or rename this folder before running environment setup."
                return 1
            fi
        done
    done
    
    # Create environments directory if it doesn't exist
    ensure_directory_exists "environments"
    
    # Ask for environment names in a single prompt
    local env_names
    if [ "${NON_INTERACTIVE:-}" = "1" ]; then
        env_names="${ENV_NAMES:-}"
        if [ -z "$env_names" ]; then
            colors::print_warning "No environment names provided in non-interactive mode. The script will use the default names: production, staging, develop, local."
            return 0
        fi
    else
        while true; do
            read -r -p "Enter environment names (space-separated, e.g., env1 env2): " env_names
            env_names=$(echo "$env_names" | xargs)
            if [ -z "$env_names" ]; then
                colors::print_warning "Please enter at least one environment name."
                continue
            fi
            break
        done
    fi
    
    # Split names and process
    local i=1
    local name
    if [ -z "$env_names" ]; then
        env_names="production staging develop local"
    fi

    for name in $env_names; do
        colors::print_info "[$i] Processing environment: $name"
        if ! _validate_name "$name"; then
            colors::print_error "Invalid environment name: $name. Skipping."
            continue
        fi
        if _check_exists "$name"; then
            colors::print_error "Environment '$name' already exists. Skipping."
            continue
        fi
        echo "{}" > "environments/${name}.json"
        colors::print_success "Created environment: ${name}.json"
        i=$((i+1))
    done
    
    # List all created environments
    colors::print_info "\nCreated environments:"
    find environments -name "*.json" -type f -printf "%f " | sed 's/\.json//g'
    
    colors::print_success "\nEnvironment setup completed successfully!"
} 