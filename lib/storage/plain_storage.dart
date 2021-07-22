import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'secure_storage.dart';

/// 明文的永久儲存
class PlainStorage {
  PlainStorage._();

  static Future<SharedPreferences> get _preferencesIns =>
      SharedPreferences.getInstance();

  static Future<bool> write({required String key, dynamic value}) async {
    if (value == null) {
      return delete(key: key);
    }

    if (value is int) {
      return writeInt(key: key, value: value);
    } else if (value is double) {
      return writeDouble(key: key, value: value);
    } else if (value is bool) {
      return writeBool(key: key, value: value);
    } else if (value is String) {
      return writeString(key: key, value: value);
    } else {
      return writeObject(key: key, value: value);
    }
  }

  static Future<bool> writeInt({required String key, int? value}) async {
    if (value == null) {
      return delete(key: key);
    }
    return (await _preferencesIns).setInt(key, value);
  }

  static Future<bool> writeDouble({required String key, double? value}) async {
    if (value == null) {
      return delete(key: key);
    }
    return (await _preferencesIns).setDouble(key, value);
  }

  static Future<bool> writeBool({required String key, bool? value}) async {
    if (value == null) {
      return delete(key: key);
    }
    return (await _preferencesIns).setBool(key, value);
  }

  static Future<bool> writeString({required String key, String? value}) async {
    if (value == null) {
      return delete(key: key);
    }
    return (await _preferencesIns).setString(key, value);
  }

  static Future<bool> writeObject({required String key, dynamic value}) async {
    if (value == null) {
      return delete(key: key);
    }

    // 嘗試使用json方式儲存
    String? text;
    try {
      text = json.encode(value);
    } catch (e) {
      print('要儲存的物件轉化json儲存出錯: $e');
    }

    if (text != null) {
      return writeString(key: key, value: text);
    } else {
      return false;
    }
  }

  static Future<int?> readInt({required String key}) async {
    return (await _preferencesIns).getInt(key);
  }

  static Future<double?> readDouble({required String key}) async {
    return (await _preferencesIns).getDouble(key);
  }

  static Future<bool?> readBool({required String key}) async {
    return (await _preferencesIns).getBool(key);
  }

  static Future<String?> readString({required String key}) async {
    return (await _preferencesIns).getString(key);
  }

  static Future<dynamic> readObject({required String key}) async {
    var value = await readString(key: key);
    if (value != null && value.isNotEmpty) {
      // 嘗試使用json方式解析
      try {
        return json.decode(value);
      } catch (e) {
        print('取出的字串無法轉化json: $e');
      }
    }
    return null;
  }

  /// 讀取列表
  static Future<List<T>?> readList<T>({required String key}) async {
    var value = await readObject(key: key);
    if (value != null && value is List) {
      return value.map((e) => e as T).toList();
    }
    return null;
  }

  /// 讀取Map
  static Future<Map<T, R>?> readMap<T, R>({required String key}) async {
    var value = await readObject(key: key);
    if (value != null && value is Map) {
      return value.map((key, value) => MapEntry(key as T, value as R));
    }
    return null;
  }

  /// 清除值
  /// [rememberValue] - 是否也將本地儲存區的值餐廚
  static Future<bool> delete({required String key}) async {
    return (await _preferencesIns).remove(key);
  }

  /// 清除全部
  static Future<bool> deleteAll() async {
    return (await _preferencesIns).clear();
  }

  /// 遍歷全部的key
  static Future<Map<String, dynamic>> readAll() async {
    var ins = await _preferencesIns;
    var keys = ins.getKeys();
    Map<String, dynamic> dataMap = {};

    for (var key in keys) {
      var value = ins.get(key);
      if (value == null) {
        continue;
      }
      dataMap[key] = value;
    }

    return dataMap;
  }

  /// 將資料全部移轉至加密的儲存區
  /// [migrateDecide] - 確認是否轉移
  static Future<void> migrateToSecureStorage({
    bool Function(String key, dynamic value)? migrateDecide,
  }) async {
    var dataMap = await readAll();

    // 排除 [_firstInstallKey]
    dataMap.removeWhere((key, value) => key == _firstInstallKey);

    var ins = await _preferencesIns;

    for (var entry in dataMap.entries) {
      var key = entry.key;
      var value = entry.value;

      var isConfirmMigrate = migrateDecide?.call(key, value) ?? true;
      if (!isConfirmMigrate) {
        continue;
      }

      if (value is String) {
        await SecureStorage.writeString(key: key, value: value);
      } else if (value is bool) {
        await SecureStorage.writeBool(key: key, value: value);
      } else if (value is double) {
        await SecureStorage.writeDouble(key: key, value: value);
      } else if (value is int) {
        await SecureStorage.writeInt(key: key, value: value);
      } else if (value is List<String>) {
        await SecureStorage.write(key: key, value: value);
      } else {
        // 未知的儲存類型
        print('PlainStorage尚不支持遷移至加密儲存區的類型');
        continue;
      }

      // 最後將此 key 自 PlainStorage 移除
      await ins.remove(key);
    }
  }
}
