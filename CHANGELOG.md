# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1]

## [1.0.0]

### Added

- Initial release of deep_local_storage
- Support for multiple data types: String, int, double, bool, bytes, List, Map
- Secure credentials storage using system keychain/keystore
- Device ID persistence that survives app reinstallation
  - Android: Uses system-level Android ID (Settings.Secure.ANDROID_ID)
  - iOS/macOS: Uses Keychain storage
- Singleton pattern for easy access
- Cross-platform support (iOS, Android, macOS)
- JSON serialization support for custom objects
- Optimized initialization with logging control
- Comprehensive example application

### Features

- Two storage types: common and credentials
- Automatic data type handling
- Error handling and logging
- Type-safe API with Dart generics
- Based on rcache_flutter for robust storage implementation
