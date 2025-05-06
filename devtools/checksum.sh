#!/bin/bash

# Script to generate SHA256 hashes for template files
# Usage: ./checksum.sh <module_name> or ./checksum.sh <full_path>

calculate_hashes() {
    local template_dir="$1"
    
    # Check if directory exists
    if [ ! -d "$template_dir" ]; then
        echo "Error: Directory '$template_dir' not found"
        exit 1
    fi

    # Get the base directory name
    local base_dir_name
    base_dir_name=$(basename "$template_dir")
    # Create output filename in the module directory
    local output_file="${template_dir}/${base_dir_name}_hashes.auto.sh"

    # Create output file with warning comments
    cat > "$output_file" << 'EOF'
#!/bin/bash

# =====================================================
# WARNING: This is an auto-generated file
# DO NOT MODIFY THIS FILE MANUALLY
# Changes will be overwritten by the checksum script
# =====================================================

#shellcheck disable=SC2034
EOF

    # Convert base_dir_name to uppercase for variable name
    local var_name
    var_name=$(echo "$base_dir_name" | tr '[:lower:]' '[:upper:]')
    echo "declare -A ${var_name}_FILE_HASHES=(" >> "$output_file"

    # Find all files in the directory and calculate their hashes
    find "$template_dir" -type f -not -name "*_hashes.auto.sh" -print0 | while IFS= read -r -d '' file; do
        # Get relative path from template directory
        local rel_path="${file#"${template_dir}/"}"
        
        # If the path contains templates/.husky/, remove that prefix
        if [[ "$rel_path" == templates/.husky/* ]]; then
            rel_path="${rel_path#templates/.husky/}"
        fi
        
        # Calculate hash using shasum or sha256sum
        local hash
        if command -v sha256sum > /dev/null; then
            hash=$(sha256sum "$file" | cut -d' ' -f1)
        else
            hash=$(shasum -a 256 "$file" | cut -d' ' -f1)
        fi
        
        echo "    [\"$rel_path\"]=\"$hash\"" >> "$output_file"
    done

    echo ")" >> "$output_file"
    echo "Hashes generated and saved to: $output_file"
}

# Function to validate if the input is a valid module name
is_valid_module() {
    local module_name="$1"
    local modules_dir="modules"
    
    if [ -d "${modules_dir}/${module_name}" ]; then
        return 0
    else
        return 1
    fi
}

# Main script logic
if [ $# -eq 0 ]; then
    echo "Error: No argument provided"
    echo "Usage: <module_name> or <full_path>"a
    exit 1
fi

input="$1"

# Check if input is a valid module name
if is_valid_module "$input"; then
    template_dir="modules/${input}"
else
    # Assume it's a direct path
    template_dir="$input"
fi

calculate_hashes "$template_dir"
