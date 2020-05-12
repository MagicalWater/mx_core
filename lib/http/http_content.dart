import 'dart:io';

import 'package:rxdart/rxdart.dart';

import 'http_query_mixin.dart';
import 'http_util.dart';
import 'http_value.dart';
import 'server_response.dart';

///http的請求body, 對於 HttpUtils 的接口封裝
class HttpContent with HttpContentMixin {
  String scheme;
  String host;
  String path;
  HttpMethod method = HttpMethod.get;

  /// 此參數只在 Method 為 download 時有效, 下載木調
  String saveInPath;

  Uri get uri => Uri(scheme: scheme, host: host, path: path, port: port);

  String get url => uri.toString();

  HttpContent.parse(
    String url, {
    this.method,
    this.saveInPath,
    ContentType contentType,
  }) {
    var parsed = Uri.parse(url);
    this.scheme = parsed.scheme;
    this.host = parsed.host;
    this.path = parsed.path;
    this.port = parsed.port;
    parseQuery(parsed.queryParameters);
    setContentType(contentType);
  }

  HttpContent.comb(
    this.scheme,
    this.host,
    this.path,
    this.method, {
    this.saveInPath,
    int port,
    ContentType contentType,
  })  : assert(scheme != null),
        assert(host != null),
        assert(path != null),
        assert(method != null) {
    this.setContentType(contentType);
    this.port = port;
  }

  HttpContent({
    String scheme,
    String host,
    String path,
    HttpMethod method = HttpMethod.get,
    String saveInPath,
    int port,
    ContentType contentType,
  })  : assert(scheme != null),
        assert(host != null),
        assert(path != null),
        assert(method != null) {
    HttpContent.comb(
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
  Stream<ServerResponse> connect({ProgressCallback onReceiveProgress}) =>
      HttpUtil.getInstance().connect(
        this,
        onReceiveProgress: onReceiveProgress,
      );
}
