/// 重量級 db 資料儲存類, 若 db 含有邏輯返回(非單純db儲存, 或者預設值, 初始化則透過 storage)
/// service 透過此類取得 db 資料
class ExDbStorage {
  static final _singleton = ExDbStorage._internal();

  static ExDbStorage getInstance() => _singleton;

  factory ExDbStorage() => _singleton;

  ExDbStorage._internal();
}
