# deep_local_storage

[![pub package](https://img.shields.io/pub/v/deep_local_storage.svg)](https://pub.dev/packages/deep_local_storage)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A powerful Flutter local storage library that provides secure and persistent data storage across platforms, supporting various data types and device-level persistence.

一个强大的 Flutter 本地存储库，提供跨平台的安全持久化数据存储，支持各种数据类型和设备级持久化。

## Features

- ✅ **Multiple Data Types** - Support for String, int, double, bool, bytes, List, Map, and custom objects
- ✅ **Secure Storage** - Credentials storage using system secure storage (iOS Keychain, Android KeyStore)
- ✅ **Device ID Persistence** - Generate and persist device IDs that survive app reinstallation
- ✅ **Cross-Platform** - Works on iOS, Android, and macOS
- ✅ **Easy to Use** - Simple API with singleton pattern
- ✅ **Type Safety** - Full type safety with Dart generics
- ✅ **JSON Serialization** - Built-in support for object serialization/deserialization

## Problem Solved

Traditional Flutter storage solutions like SharedPreferences don't provide secure storage options or device-level persistence. This library addresses these issues by:

- Using system-level secure storage for sensitive data
- Providing device ID persistence that survives app deletion/reinstallation
- Offering a unified API for different storage types
- Supporting complex data structures with automatic JSON serialization

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  deep_local_storage: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Setup

Initialize the storage system in your `main()` function:

```dart
import 'package:deep_local_storage/deep_local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Optional: Control logging output (enabled by default in debug mode)
  // DeepLocalStorage.enableLogging = false; // Disable logging for production

  runApp(const MyApp());
}
```

**Note**: The library initializes automatically when first used. Logging is enabled by default in debug mode.

### Logging Control

Control debug logging output:

**Option 1: During initialization (recommended)**

```dart
// Enable logging in development
await DeepLocalStorage.initialize(enableLogging: true);

// Disable logging in production
await DeepLocalStorage.initialize(enableLogging: false);
```

**Option 2: Runtime control**

```dart
// Disable logging dynamically
DeepLocalStorage.enableLogging = false;

// Enable logging dynamically
DeepLocalStorage.enableLogging = true;
```

All debug messages will be prefixed with appropriate tags like `[DeviceID]`, `[AndroidStorage]`, `[ClearProtection]`, etc.

## Usage

### Basic Usage

```dart
import 'package:deep_local_storage/deep_local_storage.dart';

// Get the singleton instance
final storage = DeepLocalStorage();

// Store data
await storage.saveString('username', 'john_doe');
await storage.saveInt('user_age', 25);
await storage.saveBool('is_premium', true);

// Read data
final username = await storage.readString('username');
final age = await storage.readInt('user_age');
final isPremium = await storage.readBool('is_premium');
```

### Device ID Persistence

```dart
// Get a persistent device ID that survives app reinstallation
final deviceId = await storage.getDeviceId();
print('Device ID: $deviceId'); // Always returns the same ID

// Android: Uses system-level Android ID (Settings.Secure.ANDROID_ID)
// iOS/macOS: Uses Keychain storage
// Both survive app uninstall and reinstall!
```

### Secure Storage

```dart
import 'package:deep_local_storage/deep_local_storage.dart';

// Use secure storage for sensitive data
await storage.saveString('api_token', 'secret_token', type: StorageType.credentials);
await storage.saveString('refresh_token', 'refresh_token', type: StorageType.credentials);

// Read from secure storage
final token = await storage.readString('api_token', type: StorageType.credentials);
```

### Complex Data Types

```dart
// Store a list
await storage.saveList('favorites', ['music', 'sports', 'reading']);

// Store a map
final userData = {
  'name': 'John Doe',
  'email': 'john@example.com',
  'preferences': ['dark_mode', 'notifications']
};
await storage.saveMap('user_profile', userData);

// Store custom objects
class User {
  final String name;
  final int age;

  User({required this.name, required this.age});

  Map<String, dynamic> toJson() => {'name': name, 'age': age};

  factory User.fromJson(Map<String, dynamic> json) {
    return User(name: json['name'], age: json['age']);
  }
}

// Save custom object
final user = User(name: 'Alice', age: 30);
await storage.saveObject('current_user', user.toJson());

// Read custom object
final userJson = await storage.readObject('current_user', User.fromJson);
if (userJson != null) {
  final restoredUser = User.fromJson(userJson);
  print('User: ${restoredUser.name}, Age: ${restoredUser.age}');
}
```

### Data Management

```dart
// Check if key exists
final exists = await storage.containsKey('username');

// Remove specific data
await storage.remove('username');

// Clear all data
await storage.clear();

// Clear only secure storage
await storage.clear(type: StorageType.credentials);
```

## API Reference

### DeepLocalStorage

Singleton class for local storage operations.

#### Properties

| Property        | Type   | Default      | Description                             |
| --------------- | ------ | ------------ | --------------------------------------- |
| `enableLogging` | `bool` | `kDebugMode` | Controls whether debug logs are printed |

#### Methods

| Method                              | Parameters                                          | Return               | Description                     |
| ----------------------------------- | --------------------------------------------------- | -------------------- | ------------------------------- |
| `getDeviceId()`                     | -                                                   | `Future<String>`     | Get persistent device ID        |
| `saveString(key, value, [type])`    | `String key, String value, [StorageType type]`      | `Future<void>`       | Store string value              |
| `readString(key, [type])`           | `String key, [StorageType type]`                    | `Future<String?>`    | Read string value               |
| `saveInt(key, value, [type])`       | `String key, int value, [StorageType type]`         | `Future<void>`       | Store integer value             |
| `readInt(key, [type])`              | `String key, [StorageType type]`                    | `Future<int?>`       | Read integer value              |
| `saveDouble(key, value, [type])`    | `String key, double value, [StorageType type]`      | `Future<void>`       | Store double value              |
| `readDouble(key, [type])`           | `String key, [StorageType type]`                    | `Future<double?>`    | Read double value               |
| `saveBool(key, value, [type])`      | `String key, bool value, [StorageType type]`        | `Future<void>`       | Store boolean value             |
| `readBool(key, [type])`             | `String key, [StorageType type]`                    | `Future<bool?>`      | Read boolean value              |
| `saveBytes(key, value, [type])`     | `String key, Uint8List value, [StorageType type]`   | `Future<void>`       | Store byte array                |
| `readBytes(key, [type])`            | `String key, [StorageType type]`                    | `Future<Uint8List?>` | Read byte array                 |
| `saveList(key, value, [type])`      | `String key, List value, [StorageType type]`        | `Future<void>`       | Store list                      |
| `readList(key, [type])`             | `String key, [StorageType type]`                    | `Future<List?>`      | Read list                       |
| `saveMap(key, value, [type])`       | `String key, Map value, [StorageType type]`         | `Future<void>`       | Store map                       |
| `readMap(key, [type])`              | `String key, [StorageType type]`                    | `Future<Map?>`       | Read map                        |
| `saveObject(key, object, [type])`   | `String key, T object, [StorageType type]`          | `Future<void>`       | Store serializable object       |
| `readObject(key, fromJson, [type])` | `String key, Function fromJson, [StorageType type]` | `Future<T?>`         | Read and deserialize object     |
| `remove(key, [type])`               | `String key, [StorageType type]`                    | `Future<void>`       | Remove data by key              |
| `clear([type])`                     | `[StorageType? type]`                               | `Future<void>`       | Clear all data or specific type |
| `containsKey(key, [type])`          | `String key, [StorageType type]`                    | `Future<bool>`       | Check if key exists             |

### StorageType

Enum for storage types.

| Value                     | Description                                   |
| ------------------------- | --------------------------------------------- |
| `StorageType.common`      | Regular storage using system defaults         |
| `StorageType.credentials` | Secure storage using system keychain/keystore |

## Platform Support

| Platform | Common Storage    | Credentials Storage | Device ID Persistence        |
| -------- | ----------------- | ------------------- | ---------------------------- |
| Android  | SharedPreferences | Android KeyStore    | ✅ Android ID (system-level) |
| iOS      | UserDefaults      | Keychain            | ✅ Keychain                  |
| macOS    | UserDefaults      | Keychain            | ✅ Keychain                  |

**Device ID Implementation:**

- **Android**: Uses `Settings.Secure.ANDROID_ID` - a system-level identifier that persists across app reinstalls
- **iOS/macOS**: Uses Keychain storage - a secure system storage that persists across app reinstalls

## Example

See the [example](example/) directory for a complete sample app.

```bash
cd example
flutter run
```

## Security Notes

- `StorageType.credentials` uses system-level secure storage
- Credentials data is encrypted and protected by the operating system
- Device ID is stored in credentials storage to ensure persistence
- Regular storage (`StorageType.common`) may be cleared when app is uninstalled

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
