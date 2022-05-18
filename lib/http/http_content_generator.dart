import 'dart:io';

import 'http_content.dart';
import 'http_query_mixin.dart';
import 'http_value.dart';

///HttpContent產生器, 主要在於可以設置預設header/param
class HttpContentGenerator with HttpContentMixin {
  String? defaultHost;
  String? defaultScheme;

  @override
  void clear() {
    super.clear();
    defaultHost = null;
    defaultScheme = null;
  }

  HttpContent generate(
    String path, {
    String? host,
    String? scheme,
    HttpMethod method = HttpMethod.get,
    int? port,
    ContentType? contentType,
  }) {
    var usedScheme = scheme ?? defaultScheme;
    var usedHost = host ?? defaultHost;
    if (usedScheme == null) {
      throw '錯誤: scheme 必須設定';
    }
    if (usedHost == null) {
      throw '錯誤: host 必須設定';
    }
    print('這是: $defaultScheme');
    var content = HttpContent.comb(
      usedScheme,
      usedHost,
      path,
      method,
      port: port ?? this.port,
      contentType: contentType,
    );
    content.setQueryParams(queryParams);
    content.headers = headers;
    content.bodyType = bodyType;
    content.setBody(keyValue: getKeyValueBody(), raw: getRawBody());
    return content;
  }
}
