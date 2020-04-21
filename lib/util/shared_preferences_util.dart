import 'package:meta/meta.dart';
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
}
