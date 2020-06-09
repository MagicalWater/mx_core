class UriUtil {

  UriUtil._();

  /// 新加入一個query進入原本的uri
  /// 若key已存在, 則會進行替代
  static Uri addParams(Uri uri, String key, dynamic value) {
    Map<String, dynamic> oriQuery;
    if (value is List) {
      oriQuery = Map.from(uri.queryParametersAll);
      oriQuery[key] = value;
    } else {
      oriQuery = Map.from(uri.queryParameters);
      oriQuery[key] = value;
    }

    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      path: uri.path,
      port: uri.port,
      queryParameters: oriQuery,
    );
  }
}