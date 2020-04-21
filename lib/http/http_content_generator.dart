import 'dart:io';

import 'http_content.dart';
import 'http_query_mixin.dart';
import 'http_value.dart';

///HttpContent產生器, 主要在於可以設置預設header/param
class HttpContentGenerator with HttpContentMixin {
  String defaultHost;
  String defaultScheme;

  @override
  void clear() {
    super.clear();
    defaultHost = null;
    defaultScheme = null;
  }

  HttpContent generate(
    String path, {
    String host,
    String scheme,
    HttpMethod method = HttpMethod.get,
    int port,
    ContentType contentType,
  }) {
    var content = HttpContent.comb(
      scheme ?? defaultScheme,
      host ?? defaultHost,
      path,
      method,
      port: port,
      contentType: contentType,
    );
    content.setQueryParams(queryParams);
    content.headers = headers;
    content.bodyType = bodyType;
    content.setBody(keyValue: getKeyValueBody(), raw: getRawBody());
    return content;
  }
}
