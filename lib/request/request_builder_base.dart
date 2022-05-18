import 'dart:io';

import 'package:mx_core/http/http.dart';

///子httpContent的建構類
abstract class RequestBuilderBase {
  HttpContentGenerator generator = HttpContentGenerator();

  RequestBuilderBase() {
    init();
  }

  /// 預設 host
  String host();

  /// 預設 scheme
  String scheme();

  /// 預設 body
  /// 可帶入 純字串 或 key value pair
  dynamic body() => null;

  int? port() => null;

  /// 預設 contentType
  HttpContentType? contentType() => null;

  /// 預設 bodyType
  HttpBodyType? bodyType() => null;

  /// 預設 qp
  Map<String, String>? queryParams() => null;

  /// 預設 header
  Map<String, String>? headers() => null;

  ///設置http產生器的默認屬性
  void init() {
    generator.clear();
    generator.defaultScheme = scheme();
    generator.defaultHost = host();
    final param = queryParams();
    if (param != null) {
      generator.addQueryParams(param);
    }
    final header = headers();
    if (header != null) {
      generator.addHeaders(header);
    }
    final bodyData = body();
    if (bodyData != null) {
      if (bodyData is String) {
        generator.setBody(raw: bodyData);
      } else if (bodyData is Map<String, dynamic>) {
        generator.setBody(keyValue: bodyData);
      }
    }
    final contentTypeValue = contentType();
    if (contentTypeValue != null) {
      generator.setContentType(ContentType.parse(contentTypeValue.value));
    }
    final bodyTypeValue = bodyType();
    if (bodyTypeValue != null) {
      generator.bodyType = bodyTypeValue;
    }

    final portValue = port();
    if (portValue != null) {
      generator.port = portValue;
    }
  }
}
