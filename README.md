# Hide My Code

A Flutter/Dart package that allows developers to hide specific files from their repository while providing a mechanism to generate them when needed. This package provides a secure way to share code without exposing critical implementation details.

## Features

- Interactive CLI interface for hiding/revealing files
- AES-256 encryption for file protection
- Password protection using .env file
- Automatic .gitignore management
- Multi-layer encryption (source code, file content, metadata)
- File integrity verification
- Mandatory .env file requirement for security

## Installation

```bash
dart pub add hide_my_code
```

Or add this to your `pubspec.yaml`:

```yaml
dependencies:
  hide_my_code: ^1.0.1
```

## Usage

### Hide Files
```bash
dart run hide_my_code
```

This will launch an interactive interface that asks:
1. "Hide or Visual?" - Select "Hide"
2. "Enter password" - Enter a password to protect the reveal process
3. "Enter file paths to hide" - Provide paths like:
   ```
   lib/main.dart lib/core/utils/helper.dart
   ```

### Reveal Files
```bash
dart run hide_my_code
```

This will launch an interactive interface that asks:
1. "Hide or Visual?" - Select "Visual"
2. "Enter password" - Enter the password set during hiding
3. "Select files to reveal" - Choose specific files or "all" to reveal all hidden files

## Security Features

- **Mandatory .env Requirement**: The package will not run without a `.env` file
- **Git Protection**: Automatically adds hidden files to `.gitignore`
- **Multi-Layer Encryption**: Source code, file content, and metadata encryption
- **Secure Password Handling**: Passwords are never stored in plain text
- **Integrity Verification**: SHA-256 checksums for file integrity verification