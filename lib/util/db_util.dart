// import 'dart:ui' show VoidCallback;
//
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
//
// export 'package:sqflite/sqflite.dart' show OnDatabaseConfigureFn;
//
// typedef DatabaseVersionChange = Function(int oldVersion, int newVersion);
//
// typedef ValueCallback<T> = Function(T);
//
// /// Database數據庫工具
// /// 封裝對 library - sqflite 的引用
// class DBUtil {
//   /// 初始化 db, 若不存在則自動創建
//   late Database _db;
//
//   /// 初始化 db 的串流
//   Future<Database>? _dbFuture;
//
//   /// 初始化db, 不存在會自動創建
//   /// 回調按照下列順序
//   /// 1. [onConfigure] - 打開數據庫時優先回調, 可在此處執行數據庫初始化
//   /// 2. [onCreate]或[onUpgrade]或[onDowngrade] - 數據庫不存在/版本升級/版本降級 回調
//   /// 5. [onOpen] - 數據庫開啟前最後一次回調
//   Future<void> initDB({
//     required String dbName,
//     int? version,
//     OnDatabaseConfigureFn? onConfigure,
//     ValueCallback<int>? onCreate,
//     DatabaseVersionChange? onUpgrade,
//     DatabaseVersionChange? onDowngrade,
//     VoidCallback? onOpen,
//   }) async {
//     var databasesPath = await getDatabasesPath();
//
//     /// 如果 dbName 尾段包含 .db, 則不再加入
//     if (!dbName.endsWith('.db')) {
//       dbName += ".db";
//     }
//
//     /// 建立 db
//     String path = join(databasesPath, dbName);
//
//     _dbFuture = openDatabase(
//       path,
//       version: version,
//       onConfigure: onConfigure,
//       onCreate: (_, ver) {
//         onCreate?.call(ver);
//       },
//       onUpgrade: (_, oldVer, newVer) {
//         onUpgrade?.call(oldVer, newVer);
//       },
//       onDowngrade: (_, oldVer, newVer) {
//         onDowngrade?.call(oldVer, newVer);
//       },
//       onOpen: (_) {
//         onOpen?.call();
//       },
//     );
//
//     _db = await _dbFuture!;
//   }
//
//   /// 等待 db 的初始化完成
//   Future<void> _dbInitCheck() async {
//     if (_dbFuture == null) {
//       print(StackTrace.current);
//       throw "DatabaseUtil - DB 尚未初始化";
//     }
//     await _dbFuture;
//   }
//
//   /// 創建數據表
//   Future<void> createTable(SQLiteTable table) async {
//     await _dbInitCheck();
//     var command = _getCreateTableCommand(table);
//     await _db.execute(command);
//   }
//
//   /// 新增一筆
//   Future<int> insertItem(
//     SQLiteTable table, {
//     required Map<String, Object?> values,
//   }) async {
//     await _dbInitCheck();
//     return _db.insert(table.tableName, values);
//   }
//
//   /// 取得全部的資料
//   Future<List<Map<String, dynamic>>> getTotalItem(SQLiteTable table) async {
//     await _dbInitCheck();
//     var result = await _db.rawQuery("SELECT * FROM ${table.tableName} ");
//     return result.toList();
//   }
//
//   /// 查詢總筆數
//   Future<int?> getTotalCount(SQLiteTable table) async {
//     await _dbInitCheck();
//     return Sqflite.firstIntValue(
//         await _db.rawQuery("SELECT COUNT(*) FROM ${table.tableName}"));
//   }
//
//   /// 傳入條件查詢對應資料
//   /// 範例
//   /// where - "code = ?, data = ?"
//   /// whereArgs - [codeValue, dataValue]
//   Future<List<Map<String, dynamic>>> getItem(
//     SQLiteTable table, {
//     String? where,
//     List<dynamic>? whereArgs,
//   }) async {
//     await _dbInitCheck();
//     return await _db.query(table.tableName, where: where, whereArgs: whereArgs);
//   }
//
//   /// 清空數據
//   Future<int> clearItem(SQLiteTable table) async {
//     await _dbInitCheck();
//     return _db.delete(table.tableName);
//   }
//
//   /// 根據條件刪除
//   Future<int> deleteItem(
//     SQLiteTable table, {
//     String? where,
//     List<Object?>? whereArgs,
//   }) async {
//     await _dbInitCheck();
//     return _db.delete(
//       table.tableName,
//       where: where,
//       whereArgs: whereArgs,
//     );
//   }
//
//   /// 修改/更新
//   Future<int> updateItem(
//     SQLiteTable table, {
//     required Map<String, Object?> values,
//     String? where,
//     List<Object?>? whereArgs,
//   }) async {
//     await _dbInitCheck();
//     return _db.update(
//       table.tableName,
//       values,
//       where: where,
//       whereArgs: whereArgs,
//     );
//   }
//
//   /// 關閉 db
//   Future<void> close() async {
//     await _dbInitCheck();
//     _dbFuture = null;
//     await _db.close();
//   }
//
//   /// 取得創建表的命令
//   String _getCreateTableCommand(SQLiteTable table) {
//     List<String> commandList = [];
//     if (table.tableName.isEmpty) {
//       throw "DatabaseUtil 錯誤 - TableColumn 的 tableName 不得為空";
//     }
//     if (table.dataMap.isEmpty) {
//       throw "DatabaseUtil 錯誤 - TableColumn dataMap 為空, 表格至少需含有一個實體(entities): ${table.dataMap}";
//     }
//     table.dataMap.forEach((k, v) {
//       if (k == table.tablePrimary) {
//         commandList.add("$k ${v.value} PRIMARY KEY");
//       } else {
//         commandList.add("$k ${v.value}");
//       }
//     });
//     var command = commandList.join(", ");
//     return "create table ${table.tableName} ($command)";
//   }
// }
//
// /// db 的 table
// abstract class SQLiteTable {
//   String get tableName;
//
//   String get tablePrimary;
//
//   /// 所有資料對應類型
//   Map<String, SQLiteDataType> get dataMap;
// }
//
// /// db 的 date 型態
// class SQLiteDataType {
//   final String _value;
//
//   const SQLiteDataType._internal(this._value);
//
//   String get value => _value;
//
//   /// 整數型態
//   static const integer = SQLiteDataType._internal(SQLiteDataType._integer);
//
//   /// 浮點數型態
//   static const double = SQLiteDataType._internal(SQLiteDataType._double);
//
//   /// 字串型態
//   static const string = SQLiteDataType._internal(SQLiteDataType._string);
//
//   static const String _integer = "INTEGER";
//   static const String _double = "REAL";
//   static const String _string = "TEXT";
// }
