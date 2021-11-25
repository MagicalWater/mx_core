import 'dart:io';

import 'http_query_mixin.dart';
import 'http_util.dart';
import 'http_value.dart';
import 'server_response.dart';

///http的請求body, 對於 HttpUtils 的接口封裝
class HttpContent with HttpContentMixin {
  late String scheme;
  late String host;
  late String path;
  HttpMethod method;

  /// 此參數只在 Method 為 download 時有效, 下載目的
  String? saveInPath;

  Uri get uri => Uri(
      scheme: scheme,
      host: host,
      path: path,
      port: port,
      queryParameters: queryParams);

  String get url => uri.toString();

  HttpContent.parse(
    String url, {
    this.method = HttpMethod.get,
    this.saveInPath,
    ContentType? contentType,
  }) {
    var parsed = Uri.parse(url);
    scheme = parsed.scheme;
    host = parsed.host;
    path = parsed.path;
    port = parsed.port;
    parseQuery(parsed.queryParameters);
    setContentType(contentType);
  }

  HttpContent.comb(
    this.scheme,
    this.host,
    this.path,
    this.method, {
    this.saveInPath,
    int? port,
    ContentType? contentType,
  }) {
    setContentType(contentType);
    this.port = port;
  }

  factory HttpContent({
    required String scheme,
    required String host,
    required String path,
    HttpMethod method = HttpMethod.get,
    String? saveInPath,
    int? port,
    ContentType? contentType,
  }) {
    return HttpContent.comb(
      scheme,
      host,
      path,
      method,
      saveInPath: saveInPath,
      port: port,
      contentType: contentType,
    );
  }

  /// 使用此 http_content 發起 request
  /// [onReceiveProgress] 為下載進度監聽, 只在 [method] 為 [HttpMethod.download] 時有效
  Future<ServerResponse> connect({ProgressCallback? onReceiveProgress}) =>
      HttpUtil().connect(
        this,
        onReceiveProgress: onReceiveProgress,
      );
}
