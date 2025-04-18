#!/bin/bash

# Source common utilities
source "$(dirname "$0")/common.sh"

# Function to validate environment names
validate_env_name() {
    local env_name=$1
    
    # Check if name is empty
    if [ -z "$env_name" ]; then
        print_error "Environment name cannot be empty"
        return 1
    fi
    
    # Check if name contains only valid characters (letters, numbers, underscore)
    if ! [[ "$env_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
        print_error "Environment name can only contain letters, numbers, and underscores"
        return 1
    fi
    
    # Check if name is too long (arbitrary limit of 50 characters)
    if [ ${#env_name} -gt 50 ]; then
        print_error "Environment name is too long (max 50 characters)"
        return 1
    fi
    
    return 0
}

# Function to check if environment name already exists
check_env_exists() {
    local env_name=$1
    if [ -f "environments/${env_name}.json" ]; then
        print_error "Environment '${env_name}' already exists"
        return 1
    fi
    return 0
}

# Main environment setup function
setup_environments() {
    print_info "Starting environment setup..."
    
    # Create environments directory if it doesn't exist
    ensure_directory_exists "environments"
    
    # Get number of environments to create
    local num_envs
    num_envs=$(get_validated_input "How many environments do you want to create? " validate_number)
    
    # Create environments
    for ((i=1; i<=num_envs; i++)); do
        while true; do
            local env_name
            env_name=$(get_validated_input "Enter name for environment $i: " validate_env_name)
            
            if check_env_exists "$env_name"; then
                # Create environment file
                echo "{}" > "environments/${env_name}.json"
                print_success "Created environment: ${env_name}.json"
                break
            fi
        done
    done
    
    # List all created environments
    print_info "\nCreated environments:"
    find environments -name "*.json" -type f -printf "%f " | sed 's/\.json//g'
    
    print_success "\nEnvironment setup completed successfully!"
} 