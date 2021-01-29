part of 'plain_storage.dart';

final _firstInstallKey = '_isAppFirstInstallKey';

/// 加密本地儲存類別
/// 注意: 於ios存至key chain中, 因此app刪除後重新安裝仍會存在
/// 因此若要第一次安裝時清除則要搭配 [PlainStorage] 使用
class SecureStorage {
  SecureStorage._();

  static final _storage = FlutterSecureStorage();

  /// 再重新安裝app時, 將所有的儲存資料重置
  /// 檢查方式 -
  ///   檢查 [PlainStorage] 是否含有 key - [_firstInstallKey] 的 bool
  /// 基本上只有ios需要做這件事情
  static Future<void> resetWhenFirstActiveApp() async {
    var isFirstActive = await PlainStorage.readBool(key: _firstInstallKey);
    if (isFirstActive != null) {
      // 並非第一次運行, 因此相關鍵值保留
    } else {
      // 第一次運行app
      await PlainStorage.writeBool(key: _firstInstallKey, value: true);
      return deleteAll();
    }
  }

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

  static Future<double> readDouble({String key}) async {
    var value = await readString(key: key);
    if (value != null && value.isNotEmpty) {
      return double.tryParse(value);
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

  /// 遍歷全部的key
  static Future<Map<String, String>> readAll() async {
    return _storage.readAll();
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
