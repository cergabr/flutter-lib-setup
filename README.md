# Environment Setup Script

This script helps you set up environment configuration files for your project.

## Installation

## Quick Install
```bash
curl -fsSL https://raw.githubusercontent.com/your-repo/main/install.sh | bash
```

## Manual Install (Recommended)
```bash
# Download the script
curl -fsSL https://raw.githubusercontent.com/your-repo/main/install.sh -o install.sh

# Verify SHA256 checksum
echo "expected-hash-here install.sh" | sha256sum -c -

# Run the installation
bash install.sh
```

## Features

- Creates an `environments` directory in your project
- Prompts for the number of environments to create
- Validates environment names:
  - Must be unique
  - Can only contain letters, numbers, and underscores
  - Maximum length of 50 characters
- Creates empty JSON files for each environment
- Lists all created environments at the end

## Example Usage

```bash
$ curl -s https://raw.githubusercontent.com/your-org/your-repo/main/install.sh | bash
Starting environment setup...
How many environments do you want to create? 2
Enter name for environment 1: development
Enter name for environment 2: production

Created environments: development.json production.json
Setup completed successfully!
```

## Environment Files

The script creates JSON files in the `environments` directory. Each file is named according to the environment name you provide, with a `.json` extension.

Example structure:
```
environments/
├── development.json
└── production.json
```

## Notes

- Make sure you have write permissions in the directory where you run the script
- The script will not overwrite existing environment files
- All environment names must be unique

## File Checksums

### Installation Scripts
| File | SHA256 |
|------|---------|
| install.sh | `hash_value_here` |

### Husky Templates
| File | SHA256 |
|------|---------|
| pre-commit | `hash_value_here` |
| commit-msg | `hash_value_here` |
| git_hooks.dart | `hash_value_here` |
| setup_hooks.dart | `hash_value_here` |
| husky.yaml | `hash_value_here` |
| hook_config.yaml | `hash_value_here` |
