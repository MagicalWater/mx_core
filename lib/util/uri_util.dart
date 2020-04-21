
class UriUtil {

  UriUtil._();

  /// 新加入一個query進入原本的uri
  static Uri addParams(Uri uri, String key, dynamic value) {
    final regex = "[\\w]+(?=\\[[0-x9]+\\])";
    Map<String, dynamic> newParams = {};
    RegExp regExp = RegExp(regex);
    uri.queryParameters.forEach((key, value) {
      String realKey = key;
      if (regExp.hasMatch(key)) {
        /// 代表是個陣列
        realKey = regExp.firstMatch(key).group(0);
        _addPair(target: newParams, key: realKey, value: [value]);
      } else {
        /// 代表並非陣列
        _addPair(target: newParams, key: realKey, value: value);
      }
    });
    return Uri(scheme: uri.scheme, host: uri.host, path: uri.path, queryParameters: newParams);
  }

  static void _addPair({Map<String, dynamic> target, String key, dynamic value}) {
    if (target.containsKey(key)) {
      var oriValue = target[key];
      if (value is List<String>) {
        if (oriValue is String) {
          /// 原先元素是個字串, 更改為陣列並添加
          target[key] = [oriValue] + value;
        } else if (oriValue is List<String>) {
          /// 原先元素是個陣列, 直接添加
          target[key] = oriValue + value;
        }
      } else if (value is String) {
        if (oriValue is String) {
          /// 原先元素是個字串, 直接修改參數
          target[key] = value;
        } else if (oriValue is List<String>) {
          /// 原先元素是個陣列, 直接添加
          oriValue.add(value);
          target[key] = oriValue;
        }
      }
    } else {
      target[key] = value;
    }
  }
}