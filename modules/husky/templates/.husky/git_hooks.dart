import 'dart:io';

/// Main entry point for Git Hooks
void main(List<String> arguments) {
  // This file will be executed by the git_hooks package
  // The hook type is determined by the script name (commit-msg, pre-commit, etc.)
  final hookName = arguments.isNotEmpty ? arguments.first : '';

  switch (hookName) {
    case 'commit-msg':
      if (!validateCommitMessage(arguments.skip(1).toList())) {
        exit(1);
      }
      break;
    case 'pre-commit':
      if (!runPreCommitChecks()) {
        exit(1);
      }
      break;
    default:
      print('Unknown hook type: $hookName');
      break;
  }
}

bool validateCommitMessage(List<String> arguments) {
  print('Validating commit message...');

  if (arguments.isEmpty) {
    print('\x1B[31mNo commit message file provided.\x1B[0m');
    return false;
  }

  final commitMsgFile = arguments.first;

  // Use commitlint_cli to validate the commit message
  final result = Process.runSync('dart', [
    'run',
    'commitlint_cli',
    commitMsgFile,
  ], runInShell: true);

  if (result.exitCode != 0) {
    print(result.stdout);
    print(result.stderr);
    print(
      '\x1B[31mCommit message does not follow conventional commit format.\x1B[0m',
    );
    print('Example format: feat(scope): message');
    return false;
  }

  print('\x1B[32mCommit message format is valid!\x1B[0m');
  return true;
}

bool runPreCommitChecks() {
  print('Running pre-commit checks...');
  
  // Read configuration from YAML file
  final configFile = File('hook_config.yaml');
  bool analyzeEnabled = false;
  bool formatEnabled = false;

  if (configFile.existsSync()) {
    final configContent = configFile.readAsStringSync();
    
    // Parse configuration using regular expressions for better portability
    final analyzeMatch = RegExp(r'analyze:\s*(true|false)').firstMatch(configContent);
    final formatMatch = RegExp(r'format:\s*(true|false)').firstMatch(configContent);
    
    analyzeEnabled = analyzeMatch != null && analyzeMatch.group(1) == 'true';
    formatEnabled = formatMatch != null && formatMatch.group(1) == 'true';
  }

  // Run flutter analyze
  if (analyzeEnabled) {
    print('\x1B[33mRunning Flutter analyze...\x1B[0m');
    final analyzeResult = Process.runSync('flutter', [
      'analyze',
      '--no-fatal-infos',
    ], runInShell: true);

    if (analyzeResult.exitCode != 0) {
      print(
        '\x1B[31mFlutter analyze found issues. Please fix them before committing.\x1B[0m',
      );
      print(analyzeResult.stdout);
      return false;
    }
  } else {
    print('\x1B[33mFlutter analyze check is disabled.\x1B[0m');
  }

  // Run dart format check
  if (formatEnabled) {
    print('\x1B[33mRunning Dart format verification...\x1B[0m');
    
    final findResult = Process.runSync('find', [
      '.',
      '-name',
      '*.dart',
      '-type',
      'f',
      '-not',
      '-path',
      '*/\\.*',
    ], runInShell: true);
    
    if (findResult.exitCode != 0 || findResult.stdout.toString().trim().isEmpty) {
      print('\x1B[32mNo files to check for formatting.\x1B[0m');
    } else {
      final files = findResult.stdout.toString().trim().split('\n');
      final filesToCheck = files.where((file) {
        final content = File(file).readAsStringSync();
        return !content.contains('@git-hooks-test-file');
      }).toList();
      
      if (filesToCheck.isEmpty) {
        print('\x1B[32mNo files to check for formatting.\x1B[0m');
      } else {
        final formatResult = Process.runSync('dart', [
          'format',
          '--output=none',
          '--set-exit-if-changed',
          ...filesToCheck,
        ], runInShell: true);

        if (formatResult.exitCode != 0) {
          print(
            '\x1B[31mDart format check failed. Please format your code before committing:\x1B[0m',
          );
          print('Run: dart format .');
          return false;
        }
      }
    }
  } else {
    print('\x1B[33mDart format check is disabled.\x1B[0m');
  }

  print('\x1B[32mAll checks passed!\x1B[0m');
  return true;
}
