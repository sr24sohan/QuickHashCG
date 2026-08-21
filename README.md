# Hash Genify & Hash Checkify

A lightweight and modern file hashing and checksum verification suite for generating, exporting, and verifying file integrity with support for CRC32, MD5, SHA-1, SHA-256, SHA-384, and SHA-512.

## Hash Genify

Hash Genify is a file hashing utility designed to generate and manage checksums quickly and reliably.

<p align="center">
  <img src="Screenshots\image1787232079.jpg" width="32%" />
  <img src="Screenshots\image1787232083.jpg" width="32%" />
  <img src="Screenshots\image1787232085.jpg" width="32%" />
</p>

### Features

- CRC32, MD5, SHA-1, SHA-256, SHA-384, and SHA-512 support
- Drag and drop files and folders
- Generate hashes for multiple files
- Re-Generate Hash for selected files
- Save hashes separately for each file
- Automatic checksum file type detection
- Export to Checkifier
- Embedded Checkifier executable support
- Set Root Path Depth for flexible path handling
- File Size information
- Automatically sets generated hash files as read-only
- Keyboard shortcuts and ListView management
- Improved folder drag-and-drop handling
- Accurate progress tracking

## Hash Checkify

Hash Checkify is a portable checksum verification tool for validating file integrity against generated hash files.

### Features

- CRC32, MD5, SHA-1, SHA-256, SHA-384, and SHA-512 support
- Automatic checksum verification
- Portable verification with no separate checksum file required
- Filter results by All, Genuine Only, Mismatched Only, or Missing Only
- Command-line parameter support
- Supports `.md5` checksum files
- Skips invalid and comment lines
- Supports comment symbols: `\`, `//`, `;`, `#`, and `*`
- Scan Again and Stop Checking options
- Keyboard shortcuts
- Accurate progress tracking

## Supported Algorithms

| Algorithm | Hash Genify | Hash Checkify |
|---|:---:|:---:|
| CRC32 | Yes | Yes |
| MD5 | Yes | Yes |
| SHA-1 | Yes | Yes |
| SHA-256 | Yes | Yes |
| SHA-384 | Yes | Yes |
| SHA-512 | Yes | Yes |

## Portable Verification

Hash Genify can export a checksum together with an embedded Checkifier executable. The resulting file can be shared independently and used to verify file integrity without requiring a separate checksum file.

## Version

**Current Version:** 3.0

## Requirements

- Windows
- RAD Studio 13.1 Florence
- Win32 platform
- No third-party runtime required


## License

See the repository license for licensing information.

## Project

Developed by **SR Studio 24**.

Copyright © 2026 SR Studio 24.
