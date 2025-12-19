import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:rcache_flutter/rcache.dart';
import 'package:rcache_flutter/rcaching.dart';
import 'package:uuid/uuid.dart';

import 'storage_type.dart';

/// 深度本地存储服务类
/// 基于rcache_flutter提供强大的本地数据持久化功能
/// 支持普通数据和凭据数据的安全存储
class DeepLocalStorage {
  static final DeepLocalStorage _instance = DeepLocalStorage._internal();

  /// 获取单例实例
  factory DeepLocalStorage() => _instance;

  /// 初始化存储系统
  /// 建议在main函数中WidgetsFlutterBinding.ensureInitialized()之后调用
  ///
  /// [enableLogging] 可选参数，控制是否启用调试日志。默认为true。
  /// 如果设置为false，将禁用所有调试日志输出。
  static Future<void> initialize({bool enableLogging = true}) async {
    if (_instance._isInitialized) return;

    _instance._enableLogging = enableLogging;
    _instance._isInitialized = true;
    _log('DeepLocalStorage初始化成功', tag: 'Init');
  }

  DeepLocalStorage._internal();

  final Uuid _uuid = const Uuid();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // 标记是否已初始化
  bool _isInitialized = false;

  // 缓存Android ID
  String? _cachedAndroidId;

  // 设备ID的存储键（用于iOS/macOS Keychain存储）
  static const String _deviceIdKey = 'deep_local_storage_device_id';

  static const String _fallbackKey = 'deep_local_storage_android_fallback_device_id';

  /// 控制是否启用调试日志
  bool _enableLogging = true;

  /// 统一的日志打印方法
  static void _log(String message, {String? tag}) {
    if (!_instance._enableLogging || !kDebugMode) return;

    final logMessage = tag != null ? '[DeepLocalStorage $tag] $message' : '[DeepLocalStorage] $message';
    debugPrint(logMessage);
  }

  /// 获取设备唯一标识符
  /// 此方法返回设备的永久唯一ID，删除应用后重装仍可获取相同的值
  ///
  /// 平台实现：
  /// - Android: 使用系统级Android ID（Settings.Secure.ANDROID_ID）
  /// - iOS/macOS: 使用Keychain存储
  ///
  /// 返回设备的唯一标识符
  Future<String> getDeviceId() async {
    try {
      // Android平台使用系统级Android ID
      if (Platform.isAndroid) {
        return await _getAndroidDeviceId();
      }

      // iOS/macOS平台使用Keychain存储
      return await _getKeychainDeviceId();
    } catch (e) {
      _log('获取设备ID失败: $e', tag: 'DeviceID');
      // 如果获取失败，返回临时的ID
      final tempId = _uuid.v4();
      _log('返回临时设备ID: $tempId', tag: 'DeviceID');
      return tempId;
    }
  }

  /// 获取Android系统级设备ID
  Future<String> _getAndroidDeviceId() async {
    // 使用缓存避免重复调用
    if (_cachedAndroidId != null && _cachedAndroidId!.isNotEmpty) {
      return _cachedAndroidId!;
    }

    try {
      final androidInfo = await _deviceInfo.androidInfo;
      final androidId = androidInfo.id;

      if (androidId.isNotEmpty) {
        _cachedAndroidId = androidId;
        _log('获取Android系统ID成功: $androidId', tag: 'DeviceID');
        return androidId;
      }

      // 如果Android ID为空，从本地存储获取或生成fallback ID
      _log('Android系统ID为空，使用fallback设备ID', tag: 'DeviceID');
      _cachedAndroidId = await _getOrCreateFallbackDeviceId();
      return _cachedAndroidId!;
    } catch (e) {
      _log('获取Android系统ID失败: $e，使用fallback设备ID', tag: 'DeviceID');
      _cachedAndroidId = await _getOrCreateFallbackDeviceId();
      return _cachedAndroidId!;
    }
  }

  /// 获取或创建fallback设备ID（用于Android系统ID获取失败的情况）
  Future<String> _getOrCreateFallbackDeviceId() async {
    // 先尝试从本地存储读取已有的fallback ID
    final storedId = await readString(_fallbackKey, type: StorageType.credentials);
    if (storedId != null && storedId.isNotEmpty) {
      _log('使用已存储的fallback设备ID: $storedId', tag: 'DeviceID');
      return storedId;
    }

    // 生成新的fallback ID并存储
    final newFallbackId = _uuid.v4();
    await saveString(_fallbackKey, newFallbackId, type: StorageType.credentials);
    _log('生成了新的fallback设备ID: $newFallbackId', tag: 'DeviceID');

    return newFallbackId;
  }

  /// 获取iOS/macOS的设备ID（使用Keychain）
  Future<String> _getKeychainDeviceId() async {
    final storedId = await readString(_deviceIdKey, type: StorageType.credentials);
    if (storedId != null && storedId.isNotEmpty) {
      _log('读取已存在的设备ID: $storedId', tag: 'DeviceID');
      return storedId;
    }

    // 生成新的设备ID并存储到Keychain
    final newDeviceId = _uuid.v4();
    await saveString(_deviceIdKey, newDeviceId, type: StorageType.credentials);
    _log('生成了新的设备ID: $newDeviceId', tag: 'DeviceID');

    return newDeviceId;
  }

  /// 存储字符串
  Future<void> saveString(String key, String value, {StorageType type = StorageType.common}) async {
    final cache = _getCache(type);
    await cache.saveString(value, key: RCacheKey(key));
  }

  /// 读取字符串
  Future<String?> readString(String key, {StorageType type = StorageType.common}) async {
    final cache = _getCache(type);
    return await cache.readString(key: RCacheKey(key));
  }

  /// 存储整数
  Future<void> saveInt(String key, int value, {StorageType type = StorageType.common}) async {
    final cache = _getCache(type);
    await cache.saveInteger(value, key: RCacheKey(key));
  }

  /// 读取整数
  Future<int?> readInt(String key, {StorageType type = StorageType.common}) async {
    final cache = _getCache(type);
    return await cache.readInteger(key: RCacheKey(key));
  }

  /// 存储双精度浮点数
  Future<void> saveDouble(String key, double value, {StorageType type = StorageType.common}) async {
    final cache = _getCache(type);
    await cache.saveDouble(value, key: RCacheKey(key));
  }

  /// 读取双精度浮点数
  Future<double?> readDouble(String key, {StorageType type = StorageType.common}) async {
    final cache = _getCache(type);
    return await cache.readDouble(key: RCacheKey(key));
  }

  /// 存储布尔值
  Future<void> saveBool(String key, bool value, {StorageType type = StorageType.common}) async {
    final cache = _getCache(type);
    await cache.saveBool(value, key: RCacheKey(key));
  }

  /// 读取布尔值
  Future<bool?> readBool(String key, {StorageType type = StorageType.common}) async {
    final cache = _getCache(type);
    return await cache.readBool(key: RCacheKey(key));
  }

  /// 存储字节数组
  Future<void> saveBytes(String key, Uint8List value, {StorageType type = StorageType.common}) async {
    final cache = _getCache(type);
    await cache.saveUint8List(value, key: RCacheKey(key));
  }

  /// 读取字节数组
  Future<Uint8List?> readBytes(String key, {StorageType type = StorageType.common}) async {
    final cache = _getCache(type);
    return await cache.readUint8List(key: RCacheKey(key));
  }

  /// 存储列表
  Future<void> saveList(String key, List<dynamic> value, {StorageType type = StorageType.common}) async {
    final cache = _getCache(type);
    await cache.saveArray(value, key: RCacheKey(key));
  }

  /// 读取列表
  Future<List<dynamic>?> readList(String key, {StorageType type = StorageType.common}) async {
    final cache = _getCache(type);
    return await cache.readArray(key: RCacheKey(key));
  }

  /// 存储Map
  Future<void> saveMap(String key, Map<String, dynamic> value, {StorageType type = StorageType.common}) async {
    final cache = _getCache(type);
    await cache.saveMap(value, key: RCacheKey(key));
  }

  /// 读取Map
  Future<Map<String, dynamic>?> readMap(String key, {StorageType type = StorageType.common}) async {
    final cache = _getCache(type);
    return await cache.readMap(key: RCacheKey(key));
  }

  /// 存储对象（通过JSON序列化）
  Future<void> saveObject<T>(String key, T object, {StorageType type = StorageType.common}) async {
    final jsonString = jsonEncode(object);
    await saveString(key, jsonString, type: type);
  }

  /// 读取对象（通过JSON反序列化）
  Future<T?> readObject<T>(String key, T Function(Map<String, dynamic>) fromJson,
      {StorageType type = StorageType.common}) async {
    final jsonString = await readString(key, type: type);
    if (jsonString == null || jsonString.isEmpty) return null;

    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(jsonMap);
    } catch (e) {
      _log('读取对象失败: $e', tag: 'ObjectStorage');
      return null;
    }
  }

  /// 删除指定键的数据
  Future<void> remove(String key, {StorageType type = StorageType.common}) async {
    final cache = _getCache(type);
    await cache.remove(key: RCacheKey(key));
  }

  /// 清空所有数据
  /// 注意：此方法会保护iOS/macOS的device_id不被清除
  Future<void> clear({StorageType? type}) async {
    if (type != null) {
      if (type == StorageType.credentials && !Platform.isAndroid) {
        // iOS/macOS需要保护Keychain中的device_id
        await _clearWithDeviceIdProtection();
      } else {
        final cache = _getCache(type);
        await cache.clear();
      }
    } else {
      // 清空所有类型的存储
      if (Platform.isAndroid) {
        // Android的设备ID来自系统，无需保护
        await RCache.clear();
      } else {
        // iOS/macOS需要保护device_id
        await _clearAllWithDeviceIdProtection();
      }
    }
  }

  /// iOS/macOS：保护device_id的清空操作
  Future<void> _clearWithDeviceIdProtection() async {
    // 备份device_id
    final deviceId = await readString(_deviceIdKey, type: StorageType.credentials);

    // 清空credentials存储
    final cache = _getCache(StorageType.credentials);
    await cache.clear();

    // 恢复device_id
    if (deviceId != null && deviceId.isNotEmpty) {
      await saveString(_deviceIdKey, deviceId, type: StorageType.credentials);
      _log('设备ID已保护并恢复: $deviceId', tag: 'ClearProtection');
    }
  }

  /// iOS/macOS：保护device_id的全局清空操作
  Future<void> _clearAllWithDeviceIdProtection() async {
    // 备份device_id
    final deviceId = await readString(_deviceIdKey, type: StorageType.credentials);

    // 清空所有存储
    await RCache.clear();

    // 恢复device_id
    if (deviceId != null && deviceId.isNotEmpty) {
      await saveString(_deviceIdKey, deviceId, type: StorageType.credentials);
      _log('设备ID已保护并恢复: $deviceId', tag: 'ClearProtection');
    }
  }

  /// 检查键是否存在
  Future<bool> containsKey(String key, {StorageType type = StorageType.common}) async {
    final cache = _getCache(type);
    final value = await cache.readString(key: RCacheKey(key));
    return value != null;
  }

  /// 获取存储统计信息
  Future<Map<String, dynamic>> getStorageStats() async {
    return {
      'device_id': await getDeviceId(),
      'platform': Platform.isAndroid ? 'Android' : (Platform.isIOS ? 'iOS' : 'macOS'),
      'device_id_source': Platform.isAndroid ? 'Android System ID' : 'Keychain',
    };
  }

  /// 根据存储类型获取对应的RCaching实例
  RCaching _getCache(StorageType type) {
    switch (type) {
      case StorageType.common:
        return RCache.common;
      case StorageType.credentials:
        return RCache.credentials;
    }
  }
}
