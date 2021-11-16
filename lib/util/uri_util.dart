extension QueryUri on Uri {
  /// 添加query
  Uri addQuery(String key, dynamic value) {
    Map<String, dynamic> oriQuery;
    if (value is List) {
      oriQuery = Map.from(queryParametersAll);
      oriQuery[key] = value;
    } else {
      oriQuery = Map.from(queryParameters);
      oriQuery[key] = value;
    }

    return Uri(
      scheme: scheme,
      host: host,
      path: path,
      port: port,
      queryParameters: oriQuery,
    );
  }
}
