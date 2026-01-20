# Hide My Code

A Flutter/Dart package that allows developers to hide specific files from their repository while providing a mechanism to generate them when needed. This package provides a secure way to share code without exposing critical implementation details.

## Features

- **File Hiding**: Hide specific files from your repository
- **Encryption**: All hidden files are encrypted using AES-256
- **Password Protection**: Secure access with password protection
- **Git Integration**: Automatically updates .gitignore to exclude hidden files
- **Easy Reveal**: Simple command to reveal hidden files when needed
- **Multi-file Selection**: Hide or reveal multiple files at once

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  hide_my_code:
    path: path/to/hide_my_code
```

Or install globally:

```bash
dart pub global activate hide_my_code
```

## Prerequisites

Before using this package, you need to create a `.env` file in your project root with a password:

```env
PASSWORD=your_secret_password
```

## Usage

### Hide Files

```bash
dart run hide_my_code
```

This will launch an interactive interface where you can:
1. Select "Hide files" option
2. Enter the paths of files you want to hide (space or comma separated)
3. The files will be encrypted and moved to `.hidden_data/` directory
4. Placeholders will be created in the original locations
5. `.gitignore` will be updated to exclude the hidden files

### Reveal Files

```bash
dart run hide_my_code
```

This will launch an interactive interface where you can:
1. Select "Visual (reveal) files" option
2. Enter the same password used during hiding
3. Select which files to reveal (or "all" to reveal all)
4. The original files will be decrypted and restored to their locations

## Example

To hide specific files:

```
@lib/main.dart @lib/core/routes/app_pages.dart @lib/feature/auth/presentation/screens/login_screen.dart
```

## Security

- All hidden files are encrypted using AES-256-GCM encryption
- Password is never stored in plain text
- Encryption keys are derived from your password using SHA-256
- The `.hidden_data/` directory and all hidden files are automatically added to `.gitignore`
- File integrity is maintained during encryption/decryption

## How It Works

1. When hiding files:
   - Original files are encrypted using your password
   - Encrypted files are stored in `.hidden_data/` directory
   - Placeholder files are created in original locations
   - `.gitignore` is updated to exclude hidden files

2. When revealing files:
   - The tool verifies your password
   - Retrieves encrypted files from `.hidden_data/` directory
   - Decrypts files and restores them to original locations
   - Removes placeholder files

## Notes

- Always keep your password secure
- The `.env` file should never be committed to version control
- Make sure to have backups of your important files before using this tool
- The `.hidden_data/` directory contains encrypted versions of your files

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the LICENSE file for details.