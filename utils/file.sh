#!/bin/bash

file::ensure_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        colors::print_success "Created directory: $dir"
    fi
}

file::backup() {
    local path="$1"
    if [ -e "$path" ]; then
        local backup_path
        backup_path="${path}_backup_$(date +%Y%m%d_%H%M%S)"
        mv "$path" "$backup_path"
        colors::print_warning "Created backup: $backup_path"
    fi
}

file::verify_sha256() {
    local file="$1"
    local expected_hash="$2"
    
    if command -v sha256sum >/dev/null 2>&1; then
        local actual_hash
        actual_hash=$(sha256sum "$file" | cut -d' ' -f1)
    elif command -v shasum >/dev/null 2>&1; then
        local actual_hash
        actual_hash=$(shasum -a 256 "$file" | cut -d' ' -f1)
    else
        colors::print_error "No hash verification tool found"
        return 1
    fi
    
    [ "$actual_hash" = "$expected_hash" ]
}