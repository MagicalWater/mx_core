import '../db/ex_db.dart';
import '../repository/ex_repository.dart';

/// 範例 - 重量級 db service
class ExDbService {
  /// 取得資料
  Future<List<ExApiData>> getTotalData() {
    return ExDb.getInstance().getTotalItem();
  }

  /// 添加一筆資料進入資料庫
  Future<int> insertData(ExApiData data) {
    return ExDb.getInstance().insertItem(data);
  }

  /// 從資料庫刪除一筆資料
  Future<int> deleteData(int code) {
    return ExDb.getInstance().deleteItem(code);
  }

  /// 從資料庫更新一筆資料
  Future<int> updateData(ExApiData data) {
    return ExDb.getInstance().updateItem(data);
  }

  /// 清空資料庫的資料
  Future<int> clearData() {
    return ExDb.getInstance().clear();
  }
}

