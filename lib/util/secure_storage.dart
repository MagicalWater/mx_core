import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 永久化儲存本地設定
/// 對於 List 以及 Map, 暫時只支持 List<基本類型>, Map<String, 基本類型>
/// 基本類型 => int, double, String, bool
class KeyDataBinder<T> {
  final String key;
  T _value;

  T get value => _value ?? _defaultValue;
  final T _defaultValue;

  KeyDataBinder({
    @required this.key,
    T defaultValue,
  })  : assert(T == int ||
            T == double ||
            T == String ||
            List<int>() is T ||
            List<double>() is T ||
            List<bool>() is T ||
            List<String>() is T ||
            Map<String, int>() is T ||
            Map<String, double>() is T ||
            Map<String, bool>() is T ||
            Map<String, String>() is T),
        this._defaultValue = defaultValue;

  Future<void> write(T value) async {
    this._value = value;
    if (value == null) {
      return delete(deleteLocal: true);
    }
    if (value is int) {
      await SecureStorage.writeInt(key: key, value: value);
    } else if (value is double) {
      await SecureStorage.writeDouble(key: key, value: value);
    } else if (value is bool) {
      await SecureStorage.writeBool(key: key, value: value);
    } else if (value is String) {
      await SecureStorage.writeString(key: key, value: value);
    } else if (value is List<int>) {
      await SecureStorage.write(key: key, value: value);
    } else if (value is List<double>) {
      await SecureStorage.write(key: key, value: value);
    } else if (value is List<bool>) {
      await SecureStorage.write(key: key, value: value);
    } else if (value is List<String>) {
      await SecureStorage.write(key: key, value: value);
    } else if (value is Map<String, int>) {
      await SecureStorage.write(key: key, value: value);
    } else if (value is Map<String, double>) {
      await SecureStorage.write(key: key, value: value);
    } else if (value is Map<String, bool>) {
      await SecureStorage.write(key: key, value: value);
    } else if (value is Map<String, String>) {
      await SecureStorage.write(key: key, value: value);
    } else {
      throw '警告, SecureStorage 尚只支持 int, double, bool, String, List<基本型態>, Map<String, 基本類型> 的型態, 當前型態: $T';
    }
  }

  Future<T> read() async {
    if (T == int) {
      _value = await SecureStorage.readInt(key: key) as T;
    } else if (T == double) {
      _value = await SecureStorage.readDouble(key: key) as T;
    } else if (T == bool) {
      _value = await SecureStorage.readBool(key: key) as T;
    } else if (T == String) {
      _value = await SecureStorage.readString(key: key) as T;
    } else if (List<int>() is T) {
      _value = await SecureStorage.readList<int>(key: key) as T;
    } else if (List<double>() is T) {
      _value = await SecureStorage.readList<double>(key: key) as T;
    } else if (List<bool>() is T) {
      _value = await SecureStorage.readList<bool>(key: key) as T;
    } else if (List<String>() is T) {
      _value = await SecureStorage.readList<String>(key: key) as T;
    } else if (Map<String, int>() is T) {
      _value = await SecureStorage.readMap<String, int>(key: key) as T;
    } else if (Map<String, double>() is T) {
      _value = await SecureStorage.readMap<String, double>(key: key) as T;
    } else if (Map<String, bool>() is T) {
      _value = await SecureStorage.readMap<String, bool>(key: key) as T;
    } else if (Map<String, String>() is T) {
      _value = await SecureStorage.readMap<String, String>(key: key) as T;
    } else {
      throw '警告, SecureStorage 尚只支持 int, double, bool, String, List<基本型態>, Map<String, 基本型態> 的型態, 當前型態: $T';
    }

    return value;
  }

  /// 刪除值
  /// [deleteLocal] - 是否也將本地儲存區的值刪除
  Future<void> delete({bool deleteLocal = false}) async {
    _value = null;
    if (deleteLocal) {
      await SecureStorage.delete(key: key);
    }
  }
}

/// 加密本地儲存類別
class SecureStorage {
  SecureStorage._();

  static final _storage = FlutterSecureStorage();

  static Future<void> write({String key, dynamic value}) async {
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

  static Future<void> writeInt({String key, int value}) async {
    if (value == null) {
      return delete(key: key);
    }
    var text = value.toString();
    await writeString(key: key, value: text);
  }

  static Future<void> writeDouble({String key, double value}) async {
    if (value == null) {
      return delete(key: key);
    }
    var text = value.toString();
    await writeString(key: key, value: text);
  }

  static Future<void> writeBool({String key, bool value}) async {
    if (value == null) {
      return delete(key: key);
    }
    var text = toBoolStorage(value);
    await writeString(key: key, value: text);
  }

  static Future<void> writeString({String key, String value}) async {
    if (value == null) {
      return delete(key: key);
    }
    await _storage.write(key: key, value: value);
  }

  static Future<void> writeObject({String key, dynamic value}) async {
    if (value == null) {
      return delete(key: key);
    }

    // 嘗試使用json方式儲存
    String text;
    try {
      text = json.encode(value);
    } catch (e) {
      print('要儲存的物件轉化json儲存出錯: $e');
    }

    if (text != null) {
      await writeString(key: key, value: text);
    }
  }

  static Future<int> readInt({String key}) async {
    var value = await readString(key: key);
    if (value != null && value.isNotEmpty) {
      return int.tryParse(value);
    }
    return null;
  }

  static Future<int> readDouble({String key}) async {
    var value = await readString(key: key);
    if (value != null && value.isNotEmpty) {
      return int.tryParse(value);
    }
    return null;
  }

  static Future<bool> readBool({String key}) async {
    var value = await readString(key: key);
    if (value != null && value.isNotEmpty) {
      return _parseBoolStorage(value);
    }
    return null;
  }

  static Future<String> readString({String key}) async {
    return _storage.read(key: key);
  }

  static Future<dynamic> readObject({String key}) async {
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
  static Future<List<T>> readList<T>({String key}) async {
    var value = await readObject(key: key);
    if (value != null && value is List) {
      return value.map((e) => e as T).toList();
    }
    return null;
  }

  /// 讀取Map
  static Future<Map<T, R>> readMap<T, R>({String key}) async {
    var value = await readObject(key: key);
    if (value != null && value is Map) {
      return value.map((key, value) => MapEntry(key as T, value as R));
    }
    return null;
  }

  /// 清除值
  /// [rememberValue] - 是否也將本地儲存區的值餐廚
  static Future<void> delete({String key}) async {
    return _storage.delete(key: key);
  }

  /// 清除全部
  static Future<void> deleteAll() async {
    return _storage.deleteAll();
  }
}

const _trueString = 'true';
const _falseString = 'false';

String toBoolStorage(bool value) {
  if (value) {
    return _trueString;
  } else {
    return _falseString;
  }
}

bool _parseBoolStorage(String string) {
  if (string.toLowerCase() == _trueString) {
    return true;
  } else if (string.toLowerCase() == _falseString) {
    return false;
  }
  return null;
}

extension _ListType<T> on List<T> {
  /// 列表的類型
  Type get genericType => T;
}
