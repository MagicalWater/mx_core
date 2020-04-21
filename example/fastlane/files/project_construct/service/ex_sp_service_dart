import '../storage/ex_sp_storage.dart';

/// 範例 - 輕量級 api service
class ExSpService {

  /// 儲存資料進入輕量級資料儲存區
  Future<String> getExData() {
    return ExSpStorage.getInstance().getExData();
  }

  /// 從輕量級資料儲存區取得資料
  Future<void> setExData(String exValue) {
    return ExSpStorage.getInstance().setExData(exValue);
  }
}
