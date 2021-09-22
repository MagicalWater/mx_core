import 'package:mx_core/mx_core.dart';

/// 輕量級 sp 資料儲存類
/// service 透過此類取得 sp 資料
class ExSpStorage {
  static final _singleton = ExSpStorage._internal();

  static ExSpStorage getInstance() => _singleton;

  factory ExSpStorage() => _singleton;

  ExSpStorage._internal();

  final String exDataKey = "exDataKey";

  Future<String?> getExData() {
    return PlainStorage.readString(key: exDataKey);
  }

  Future<void> setExData(String exValue) {
    return PlainStorage.writeString(key: exDataKey, value: exValue);
  }
}
