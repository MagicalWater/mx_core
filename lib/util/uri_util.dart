extension QueryUri on Uri {
  /// 添加query
  Uri addQuery(String key, dynamic value) {
    Map<String, dynamic> oriQuery;
    if (value is List) {
      oriQuery = Map.from(this.queryParametersAll);
      oriQuery[key] = value;
    } else {
      oriQuery = Map.from(this.queryParameters);
      oriQuery[key] = value;
    }

    return Uri(
      scheme: this.scheme,
      host: this.host,
      path: this.path,
      port: this.port,
      queryParameters: oriQuery,
    );
  }
}
