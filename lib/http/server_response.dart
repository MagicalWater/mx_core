import 'dart:convert';
import 'dart:io' show File;

import 'package:dio/dio.dart';

import 'http_value.dart';

class ServerResponse {
  String url;
  String? saveInPath;
  Map<String, dynamic> params = const {};
  Map<String, dynamic> headers = const {};
  dynamic body;
  final Response? response;
  HttpMethod method;

  DioError? error;

  /// 是否發生錯誤
  bool get haveError => error != null;

  ServerResponse({
    required this.response,
    required this.url,
    required this.params,
    required this.headers,
    required this.body,
    required this.method,
    this.error,
    this.saveInPath,
  });

  /// 如果是下載時, 此方法可以得到下載後的路徑
  File getFile() {
    if (saveInPath == null) {
      throw "HttpResponse - 無法取得 File: 不是下載請求";
    }
    return File(saveInPath!);
  }

  String? getString() {
    return response?.data.toString();
  }

  dynamic getJson() {
    var string = getString();
    if (string != null) {
      return json.decode(string);
    }
    return null;
  }

  int? getStatusCode() {
    return response?.statusCode;
  }
}
