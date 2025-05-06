#!/bin/bash

# Module namespace
HUSKY_MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
TEMPLATES_DIR="$HUSKY_MODULE_DIR/templates/.husky"

# SHA256 hashes of template files
#shellcheck source=templates/templates_hashes.auto.sh
source "${HUSKY_MODULE_DIR}/templates/templates_hashes.auto.sh"

# Function to attempt Husky activation
husky::_activate_husky() {
    colors::print_info "Attempting to activate Husky..."
    # Check if husky is runnable via dart run
    if ! dart run husky --version > /dev/null 2>&1; then
        colors::print_warning "Husky command not found via 'dart run'. Attempting global activation..."
        if ! dart pub global activate husky; then
            colors::print_error "Failed to activate Husky globally. Please install it manually ('dart pub global activate husky') and ensure Dart SDK is in your PATH."
            return 1
        fi
        # Re-check after activation
        if ! dart run husky --version > /dev/null 2>&1; then
             colors::print_error "Husky activated but still not runnable via 'dart run'. Check your Dart setup."
             return 1
        fi
    fi

    # Run husky install
    if ! dart run husky install; then
        colors::print_error "Failed to run 'dart run husky install'. Check Husky setup and project configuration."
        return 1
    fi
    colors::print_success "Husky activated successfully."
    return 0
}

husky::install() {
    # Check if the current directory is a root Flutter project
    validation::check_flutter_project_root || return 1

    local target_dir="${1:-$(pwd)}"
    colors::print_info "Setting up Husky in $target_dir"

    # Backup existing installation
    file::backup "$target_dir/.husky"

    # Create .husky directory
    file::ensure_dir "$target_dir/.husky"

    # Copy and verify template files
    husky::_copy_templates "$target_dir" || return 1

    # Activate Husky (Runs 'dart run husky install')
    husky::_activate_husky || return 1

    # Set permissions AFTER copying templates
    husky::_set_permissions "$target_dir"

    # Compatibility copies to project root
    husky::_compatibility_copies "$target_dir"

    # Verify installation (includes checking files and hooks path)
    husky::_verify_installation "$target_dir" || return 1

    colors::print_success "Husky setup completed!"
}

husky::_copy_templates() {
    local target_dir="$1"
    
    echo "Copying from $TEMPLATES_DIR to $target_dir/.husky/"
    ls -l "$TEMPLATES_DIR"
    if ! rsync -a "$TEMPLATES_DIR/" "$target_dir/.husky/"; then
         colors::print_error "Failed to copy template files."
         return 1
    fi
    ls -l "$target_dir/.husky/"

    # Verify hashes after copying
    for rel_path in "${!HUSKY_FILE_HASHES[@]}"; do
        local target_file="$target_dir/.husky/$rel_path"
        local expected_hash="${HUSKY_FILE_HASHES[$rel_path]}"
        
        if [ ! -f "$target_file" ]; then
             colors::print_error "Template file missing after copy: $rel_path"
             return 1
        fi

        if [ -n "$expected_hash" ] && [ "$expected_hash" != "hash_value_here" ]; then
            if ! file::verify_sha256 "$target_file" "$expected_hash"; then
                colors::print_error "File integrity check failed: $rel_path"
                return 1
            fi
        fi
    done
    
    colors::print_info "Template files copied and verified."
    return 0
}

husky::_compatibility_copies() {
    local target_dir="$1"
    local files_to_copy=("husky.yaml" "hook_config.yaml")

    for filename in "${files_to_copy[@]}"; do
        local source_file="$target_dir/.husky/$filename"
        local dest_file="$target_dir/$filename"

        if [ -f "$source_file" ] && [ ! -f "$dest_file" ]; then
            if cp "$source_file" "$dest_file"; then
                colors::print_info "Copied $filename to project root for compatibility."
            else
                colors::print_warning "Failed to copy $filename to project root."
            fi
        fi
    done
}

husky::_set_permissions() {
    local target_dir="$1"
    local executables=(
        "pre-commit"
        "commit-msg"
        "git_hooks.dart"
    )
    
    for file_rel_path in "${executables[@]}"; do
        local file_abs_path="$target_dir/.husky/$file_rel_path"
        if [ -f "$file_abs_path" ]; then
             if ! chmod +x "$file_abs_path"; then
                 colors::print_warning "Failed to set executable permission for: $file_rel_path"
             fi
        else
             colors::print_warning "Executable template file not found: $file_rel_path"
        fi
    done
}

husky::_verify_installation() {
    local target_dir="$1"
    local required_files=(
        "pre-commit"
        "commit-msg"
        "git_hooks.dart"
        "husky.yaml"
        "hook_config.yaml"
    )
    
    colors::print_info "Verifying installation..."
    
    for file_rel_path in "${required_files[@]}"; do
        local file_abs_path="$target_dir/.husky/$file_rel_path"
        if [ ! -f "$file_abs_path" ]; then
            colors::print_error "Verification failed: Missing required file: $file_rel_path"
            return 1
        fi
    done

    local current_hooks_path
    current_hooks_path=$(git config --local core.hooksPath)
    
    local expected_hooks_path_abs
    expected_hooks_path_abs=$(cd "$target_dir" && pwd)/.husky 
    local current_hooks_path_abs
    if [[ "$current_hooks_path" != /* ]]; then
        current_hooks_path_abs=$(cd "$target_dir" && cd "$current_hooks_path" && pwd)
    else
        current_hooks_path_abs=$(cd "$current_hooks_path" && pwd)
    fi
    
    expected_hooks_path_abs=${expected_hooks_path_abs%/}
    current_hooks_path_abs=${current_hooks_path_abs%/}

    if [ "$current_hooks_path_abs" != "$expected_hooks_path_abs" ]; then
        colors::print_error "Verification failed: Git hooks path not set correctly."
        colors::print_error "Expected: $expected_hooks_path_abs"
        colors::print_error "Got: $current_hooks_path_abs (from '$current_hooks_path')"
        colors::print_warning "Attempting to set Git hooks path again..."
         if ! git config core.hooksPath ".husky"; then
             colors::print_error "Failed to set core.hooksPath again."
             return 1
         else
             colors::print_success "Set core.hooksPath to '.husky'."
         fi
    fi

    colors::print_success "Installation verification passed."
    return 0
}