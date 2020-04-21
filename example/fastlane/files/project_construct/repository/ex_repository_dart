import 'package:mx_core/mx_core.dart';
import 'package:rxdart/rxdart.dart';

import '../bean/bean_converter.dart';
import '../service/ex_db_service.dart';
import '../service/ex_request_service.dart';
import '../service/ex_sp_service.dart';

/// 範例 - 倉庫, 含有下列功能
/// 透過 ex_request_service 發起請求
/// 透過 ex_sp_service 取得輕量級資料
/// 透過 ex_db_service 取得重量級資料
class ExRepository {
  final _requestService = ExRequestService();
  final _spService = ExSpService();
  final _dbService = ExDbService();

  /// 透過 _requestService 取得 exApi 的資料
  /// 並且將 資料轉換為 ExApiData
  Observable<ExApiData> getRequestData() {
    return _requestService
        .exApi("titlePath", "aId", "bToken", "cBody", "rawBody",
            FileInfo(filepath: "filepath", filename: "filename"),
            opId: "opId",
            opToken: "opToken",
            opBody: "opBody",
            opBodyFile: FileInfo(filepath: "filepath", filename: "filename"),
            optRawBody: "optRawBody")
        .map((response) => _convertToExApiData(response));
  }

  /// 透過 _dpService 取得 db 資料
  Future<List<ExApiData>> getDbData() {
    return _dbService.getTotalData();
  }

  /// 透過 _sbService 取得 sb 資料
  Future<String> getSpData() {
    return _spService.getExData();
  }

  /// 將 exApi 請求撈回來的資料轉化為吐給外面的資料
  ExApiData _convertToExApiData(ServerResponse response) {
    var bean = BeanConverter.convert<ExApiBean>(response.getString());
    return ExApiData(code: bean.code, data: bean.data);
  }
}

/// ex api 轉化的資料, 給外層使用
class ExApiData {
  int code;
  String data;

  ExApiData({this.code, this.data});
}
