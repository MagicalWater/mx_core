import 'package:meta/meta.dart';
import 'package:mx_core/mx_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// shared_preferences 封裝
class SpUtil {
  SpUtil._();

  static Future<bool> setString(
      {@required String key, @required String value}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(key, value);
  }

  static Future<bool> setBool(
      {@required String key, @required bool value}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setBool(key, value);
  }

  static Future<bool> setDouble(
      {@required String key, @required double value}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setDouble(key, value);
  }

  static Future<bool> setInt(
      {@required String key, @required int value}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setInt(key, value);
  }

  static Future<bool> setStringList(
      {@required String key, @required List<String> value}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setStringList(key, value);
  }

  static dynamic get({@required String key}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.get(key);
  }

  static Future<String> getString({@required String key}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(key);
  }

  static Future<bool> getBool({@required String key}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(key);
  }

  static Future<int> getInt({@required String key}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getInt(key);
  }

  static Future<double> getDouble({@required String key}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getDouble(key);
  }

  static Future<List<String>> getStringList({@required String key}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(key);
  }

  static Future<bool> remove({@required String key}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.remove(key);
  }

  /// 將資料全部移轉至加密的儲存區
  static Future<void> migrateToSecureStorage() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var keys = preferences.getKeys();

    // 將資料全部提出, 用 is 判斷類型, 轉存至 LocalStorage
    for (var key in keys) {
      var value = preferences.get(key);

      if (value == null) {
        continue;
      }

      // print('需要轉移 key = $key');
      // continue;

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
        print('SpUtil尚不支持遷移至加密儲存區的類型');
        continue;
      }

      // 最後將此 key 自 SpUtil 移除
      await preferences.remove(key);
    }
  }
}
