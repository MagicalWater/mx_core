import 'dart:io';

import 'package:mx_core/http/http.dart';
import 'package:mx_core/http/http_content_generator.dart';

///子httpContent的建構類
abstract class RequestBuilderBase {
  HttpContentGenerator generator = HttpContentGenerator();

  /// 預設 host
  String host(String client) {
    return client;
  }

  /// 預設 scheme
  String scheme(String client) {
    return client;
  }

  /// 預設 body
  /// 可帶入 純字串 或 key value pair
  dynamic body(dynamic client) {
    return client;
  }

  int port(int client) {
    return client;
  }

  /// 預設 contentType
  HttpContentType contentType(HttpContentType client) {
    return client;
  }

  /// 預設 bodyType
  HttpBodyType bodyType(HttpBodyType client) {
    return client;
  }

  /// 預設 qp
  Map<String, String> queryParams(Map<String, String> client) {
    return client;
  }

  /// 預設 header
  Map<String, String> headers(Map<String, String> client) {
    return client;
  }

  ///設置http產生器的默認屬性
  void setDefault({
    String clientScheme,
    String clientHost,
    Map<String, String> clientQueryParams,
    Map<String, String> clientHeaders,
    dynamic clientBody,
    HttpBodyType clientBodyType,
    HttpContentType clientContentType,
    int clientPort,
  }) {
    generator.clear();
    generator.defaultScheme = scheme(clientScheme) ?? generator.defaultScheme;
    generator.defaultHost = host(clientHost) ?? generator.defaultHost;
    generator.addQueryParams(queryParams(clientQueryParams));
    generator.addHeaders(headers(clientHeaders));
    var bodyData = body(clientBody);
    if (bodyData != null) {
      if (bodyData is String) {
        generator.addBody();
      } else if (bodyData is Map<String, dynamic>) {
        bodyData.forEach((k, v) {
          if (v is FileInfo) {
            generator.addBody(
                key: k, filename: v.filename, filepath: v.filepath);
          } else {
            generator.addBody(key: k, value: v);
          }
        });
      }
    }
    var contentT = contentType(clientContentType);
    if (contentT != null) {
      generator.setContentType(ContentType.parse(contentT.value));
    }
    var bodyT = bodyType(clientBodyType);
    if (bodyT != null) {
      generator.bodyType = bodyT;
    }

    var portT = port(clientPort);
    if (portT != null) {
      generator.port = portT;
    }
  }
}
