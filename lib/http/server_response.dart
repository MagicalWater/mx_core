import 'dart:convert';
import 'dart:io' show File;

import 'package:dio/dio.dart';
import 'package:mx_core/util/file_util.dart';
import 'package:path/path.dart';

class ServerResponse {
  String url;
  String saveInPath;
  Map<String, dynamic> params = const {};
  Map<String, dynamic> headers = const {};
  dynamic body;
  final Response response;

  ServerResponse({
    this.response,
    this.url,
    this.params,
    this.headers,
    this.body,
    this.saveInPath,
  });

  /// 如果是下載時, 此方法可以得到下載後的路徑
  File getFile() {
    if (saveInPath == null) {
      throw "HttpResponse - 無法取得 File: 不是下載請求";
    }
    return File(saveInPath);
  }

  String getString() {
    return response?.data.toString();
  }

  dynamic getJson() {
    return json.decode(getString());
  }

  int getStatusCode() {
    return response?.statusCode;
  }

  Future<void> writeToFile() async {
    var uri = Uri.parse(url);
    var segments = ["ServerResponse", uri.host] + uri.pathSegments;
    var name = segments.removeLast();
    var nameNoExtension = basenameWithoutExtension(name);
    segments.add("$nameNoExtension.txt");
    var fullPath = joinAll(segments);
    return FileUtil.write(name: fullPath, content: getString());
  }
}
