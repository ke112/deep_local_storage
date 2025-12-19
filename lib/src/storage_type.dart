/// 存储类型枚举
enum StorageType {
  /// 普通数据存储 - 使用系统默认存储位置
  common,

  /// 凭据数据存储 - 使用系统安全存储（如iOS钥匙串、Android KeyStore）
  credentials,
}

/// 存储类型扩展，提供便捷的方法
extension StorageTypeExtension on StorageType {
  String get description {
    switch (this) {
      case StorageType.common:
        return '普通数据存储';
      case StorageType.credentials:
        return '凭据数据存储';
    }
  }

  bool get isSecure {
    return this == StorageType.credentials;
  }
}
