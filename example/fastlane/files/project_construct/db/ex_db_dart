import 'package:mx_core/mx_core.dart';

import '../repository/ex_repository.dart';

class _ExDataTable extends SQLiteTable {
  @override
  Map<String, SQLiteDataType> get dataMap => {
        code: SQLiteDataType.integer,
        code: SQLiteDataType.string,
      };

  @override
  String get tableName => 'ex_table_name';

  @override
  String get tablePrimary => code;

  final String code = "code";
  final String data = "data";
}

/// 範例 - 數據庫 db
class ExDb {
  static final _singleton = ExDb._internal();

  static ExDb getInstance() => _singleton;

  factory ExDb() => _singleton;

  final DBUtil _dbUtil = DBUtil();

  final _ExDataTable _dataTable = _ExDataTable();

  ExDb._internal() {
    _dbUtil.initDB(
        dbName: _dataTable.tableName, version: 1, onCreate: _onCreate);
  }

  /// 創建數據表
  Future<void> _onCreate(int version) async {
    await _dbUtil.createTable(_dataTable);
  }

  /// 新增一筆
  Future<int> insertItem(ExApiData data) async {
    return _dbUtil.insertItem(_dataTable, values: _getMapFrom(data));
  }

  /// 取得全部的資料
  Future<List<ExApiData>> getTotalItem() async {
    var total = await _dbUtil.getTotalItem(_dataTable);
    return total.map((element) => _getDataFrom(element)).toList();
  }

  /// 查詢總筆數
  Future<int> getTotalCount() async {
    return _dbUtil.getTotalCount(_dataTable);
  }

  /// 從id查詢對應資料, 若查詢到多筆, 只取第一筆
  Future<ExApiData> getItem(int code) async {
    var result = await _dbUtil
        .getItem(_dataTable, where: "${_dataTable.code} = ?", whereArgs: [code]);
    return _getDataFrom(result.first);
  }

  /// 清空數據
  Future<int> clear() async {
    return _dbUtil.clearItem(_dataTable);
  }

  /// 根據id刪除
  Future<int> deleteItem(int code) async {
    return _dbUtil.deleteItem(_dataTable,
        where: "${_dataTable.code} = ?", whereArgs: [code]);
  }

  /// 修改
  Future<int> updateItem(ExApiData data) async {
    return _dbUtil.updateItem(_dataTable,
        values: _getMapFrom(data),
        where: "${_dataTable.code} = ?",
        whereArgs: [data.code]);
  }

  /// 關閉
  Future close() async {
    _dbUtil.close();
  }

  /// 取得data對表格資料的轉換
  Map<String, dynamic> _getMapFrom(ExApiData data) {
    return {
      _dataTable.code: data.code,
      _dataTable.data: data.data,
    };
  }

  /// 取得資料表格對data的轉換
  ExApiData _getDataFrom(Map<String, dynamic> map) {
    return ExApiData(
      code: map[_dataTable.code],
      data: map[_dataTable.data],
    );
  }
}
