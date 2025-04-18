#!/bin/bash

set -e  # Exit on error
trap 'error::handle_error $? $LINENO $BASH_LINENO "$BASH_COMMAND" $(printf "::%s" ${FUNCNAME[@]:-})' ERR

error::handle_error() {
    local exit_code=$1
    local line_no=$2
    local bash_lineno=$3
    local last_command=$4
    local func_trace=$5

    print_error "Error occurred in script at line: $line_no"
    print_error "Last command executed: $last_command"
    print_error "Exit code: $exit_code"
    print_error "Function trace: $func_trace"
    print_error "Bash line number: $bash_lineno"
    
    # Cleanup on error
    cleanup_on_error
}

error::cleanup_on_error() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
    print_info "Cleaned up temporary files"
}