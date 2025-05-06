# Environment Setup Script

This script helps you set up environment configuration files for your project.

## Installation

### Quick Install

This command downloads a lightweight bootstrapper script, which clones the repository to a temporary directory and runs the full setup automatically:

```bash
curl -fsSL https://raw.githubusercontent.com/cergabr/flutter-lib-setup/master/install.sh | bash
```

- **No dependencies or files are left behind in your project directory.**
- **All setup logic and dependencies are managed from the cloned repository.**

### Manual Install (Recommended for advanced users)

Clone the repository and run the main setup script directly:

```bash
git clone https://github.com/cergabr/flutter-lib-setup.git
cd flutter-lib-setup
bash setup.sh
```

- This approach allows you to inspect or modify the setup scripts before running them.

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
$ curl -fsSL https://raw.githubusercontent.com/cergabr/flutter-lib-setup/master/install.sh | bash
Cloning https://github.com/cergabr/flutter-lib-setup.git (branch: master) to temporary directory...
Running setup script from cloned repository...
Starting installation process...
How many environments do you want to create? 2
Enter name for environment 1: development
Enter name for environment 2: production

Created environments: development.json production.json
Installation completed successfully!
Cleaning up temporary files...
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
| File      | SHA256           |
|-----------|------------------|
| install.sh| `hash_value_here`|
| setup.sh  | `hash_value_here`|

### Husky Templates
| File | SHA256 |
|------|---------|
| pre-commit | `hash_value_here` |
| commit-msg | `hash_value_here` |
| git_hooks.dart | `hash_value_here` |
| setup_hooks.dart | `hash_value_here` |
| husky.yaml | `hash_value_here` |
| hook_config.yaml | `hash_value_here` |
