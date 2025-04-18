#!/bin/bash

validation::check_command() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        colors::print_error "Required command not found: $cmd"
        return 1
    fi
}

validation::check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        colors::print_error "Not a git repository"
        return 1
    fi
}

validation::check_flutter_project_root() {
    if [ ! -f "pubspec.yaml" ]; then
        colors::print_error "Not a Flutter project (pubspec.yaml not found)"
        return 1
    fi

    if ! grep -q "sdk: flutter" "pubspec.yaml"; then
        colors::print_error "Not a Flutter project (flutter SDK not found or invalid in pubspec.yaml)"
        return 1
    fi

    return 0
}
