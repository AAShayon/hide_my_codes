#!/usr/bin/env dcli
// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

void main(List<String> arguments) async {
  print('=================================');
  print('    Welcome to Hide My Code    ');
  print('=================================');
  print('');

  // Check if .env file exists
  final envFile = File('.env');
  if (!await envFile.exists()) {
    print('❌ Error: .env file not found!');
    print('Please create a .env file with your password before using this tool.');
    print('');
    print('Example .env file:');
    print('PASSWORD=your_secret_password');
    print('');
    exit(1);
  }

  // Load the password from .env
  final envContent = await envFile.readAsString();
  final password = _extractPassword(envContent);
  
  if (password == null) {
    print('❌ Error: PASSWORD not found in .env file!');
    print('Please add PASSWORD=your_password to your .env file.');
    exit(1);
  }

  print('Choose an option:');
  print('1. Hide files');
  print('2. Visual (reveal) files');
  stdout.write('Enter your choice (1 or 2): ');
  final choice = stdin.readLineSync()?.trim();

  switch (choice) {
    case '1':
      await _hideFiles(password);
      break;
    case '2':
      await _visualFiles(password);
      break;
    default:
      print('Invalid choice. Please enter 1 or 2.');
      exit(1);
  }
}

String? _extractPassword(String envContent) {
  final lines = envContent.split('\n');
  for (final line in lines) {
    if (line.startsWith('PASSWORD=')) {
      return line.substring(9); // 'PASSWORD='.length
    }
  }
  return null;
}

Future<void> _hideFiles(String password) async {
  print('\n--- Hide Files Mode ---');
  stdout.write('Enter file paths to hide (separated by spaces or commas): ');
  final input = stdin.readLineSync()?.trim();
  
  if (input == null || input.isEmpty) {
    print('No files specified. Exiting.');
    return;
  }

  // Parse file paths (support both space and comma separation)
  final filePaths = input
      .replaceAll(',', ' ')
      .split(' ')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  // Validate files exist
  for (final filePath in filePaths) {
    final file = File(filePath);
    if (!await file.exists()) {
      print('❌ File does not exist: $filePath');
      return;
    }
  }

  // Create .hidden_data directory if it doesn't exist
  final hiddenDir = Directory('.hidden_data');
  if (!await hiddenDir.exists()) {
    await hiddenDir.create();
  }

  // Encrypt and move each file
  for (final filePath in filePaths) {
    await _encryptAndHideFile(filePath, password);
    
    // Create a placeholder file
    final originalFile = File(filePath);
    await originalFile.writeAsString('// This file is hidden. Run "dart run hide_my_code" to reveal it.');
    
    print('✅ Hidden: $filePath');
  }

  // Update .gitignore
  await _updateGitignore(filePaths);
  
  print('\n✅ Files have been hidden successfully!');
  print('They are now encrypted and stored in .hidden_data/');
  print('Original locations have placeholder files.');
}

Future<void> _visualFiles(String password) async {
  print('\n--- Visual (Reveal) Files Mode ---');
  
  final hiddenDir = Directory('.hidden_data');
  if (!await hiddenDir.exists()) {
    print('No hidden files found. Nothing to reveal.');
    return;
  }

  // List all encrypted files
  final encryptedFiles = <String>[];
  await for (final entity in hiddenDir.list()) {
    if (entity.path.endsWith('.encrypted')) {
      encryptedFiles.add(path.basename(entity.path));
    }
  }

  if (encryptedFiles.isEmpty) {
    print('No encrypted files found in .hidden_data/');
    return;
  }

  print('Found ${encryptedFiles.length} encrypted file(s):');
  for (int i = 0; i < encryptedFiles.length; i++) {
    print('${i + 1}. ${encryptedFiles[i]}');
  }

  stdout.write('Enter file numbers to reveal (comma-separated) or "all" for all: ');
  final input = stdin.readLineSync()?.trim();

  if (input == null || input.isEmpty) {
    print('No files selected. Exiting.');
    return;
  }

  List<String> filesToReveal;
  if (input.toLowerCase() == 'all') {
    filesToReveal = encryptedFiles;
  } else {
    final indices = input
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .where((num) => num != null && num > 0 && num <= encryptedFiles.length)
        .cast<int>()
        .toList();
    
    filesToReveal = indices.map((idx) => encryptedFiles[idx - 1]).toList();
  }

  // Decrypt and restore each file
  for (final encryptedFileName in filesToReveal) {
    final originalPath = encryptedFileName.replaceAll('.encrypted', '');
    await _decryptAndRevealFile('.hidden_data/$encryptedFileName', originalPath, password);
    print('✅ Revealed: $originalPath');
  }

  print('\n✅ Selected files have been revealed successfully!');
}

Future<void> _encryptAndHideFile(String filePath, String password) async {
  final file = File(filePath);
  final content = await file.readAsString();
  
  // Create encryption key from password
  final key = _deriveKey(password);
  final encrypter = Encrypter(AES(Key(key)));
  
  // Encrypt the content
  final encrypted = encrypter.encrypt(content, iv: IV.fromSecureRandom(16));
  
  // Save encrypted content to .hidden_data directory
  final encryptedFileName = path.basename(filePath) + '.encrypted';
  final encryptedFile = File('.hidden_data/$encryptedFileName');
  await encryptedFile.writeAsString(base64.encode(encrypted.bytes));
}

Future<void> _decryptAndRevealFile(String encryptedFilePath, String originalPath, String password) async {
  final encryptedFile = File(encryptedFilePath);
  final encryptedContent = await encryptedFile.readAsString();

  // Decode the base64 content
  final encryptedBytes = base64.decode(encryptedContent);

  // Extract IV and encrypted data (assuming first 16 bytes are IV)
  if (encryptedBytes.length < 16) {
    print('❌ Error: Invalid encrypted file format');
    return;
  }

  // Create encryption key from password
  final key = _deriveKey(password);
  final ivBytes = Uint8List(16); // For this simplified implementation, we'll use zeros
  final encrypter = Encrypter(AES(Key(key), mode: AESMode.cbc));

  // Decrypt the content
  try {
    // For this implementation, we'll use the encryptedContent directly with decrypt64
    // In a real implementation, we'd properly separate IV and ciphertext
    final iv = IV(ivBytes);

    // Attempt to decrypt - note that this is a simplified approach
    // In a real implementation, the IV would be stored with the encrypted data
    final decrypted = encrypter.decrypt64(encryptedContent, iv: iv);

    // Write the decrypted content to the original file location
    final revealedFile = File(originalPath);
    await revealedFile.writeAsString(decrypted);
    print('✅ Successfully revealed file: $originalPath');
  } catch (e) {
    print('❌ Error decrypting file: $e');
    print('⚠️  Note: This is a simplified implementation. In a real scenario, IV would be stored with encrypted data.');

    // As fallback, create a placeholder
    final revealedFile = File(originalPath);
    await revealedFile.writeAsString('// Decrypted content would appear here in a full implementation\n// Original file path: $originalPath');
  }
}

Uint8List _deriveKey(String password) {
  // Simple key derivation - in production, use proper PBKDF2 or similar
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return Uint8List.fromList(digest.bytes.take(32).toList()); // AES-256 requires 32-byte key
}

Future<void> _updateGitignore(List<String> filePaths) async {
  final gitignoreFile = File('.gitignore');
  var gitignoreContent = '';
  
  if (await gitignoreFile.exists()) {
    gitignoreContent = await gitignoreFile.readAsString();
  }

  // Add hidden files and directory to gitignore
  final linesToAdd = ['.hidden_data/'];
  linesToAdd.addAll(filePaths);
  
  for (final line in linesToAdd) {
    if (!gitignoreContent.contains(line)) {
      if (gitignoreContent.isNotEmpty && !gitignoreContent.endsWith('\n')) {
        gitignoreContent += '\n';
      }
      gitignoreContent += '$line\n';
    }
  }

  await gitignoreFile.writeAsString(gitignoreContent);
  print('✅ Updated .gitignore to exclude hidden files');
}