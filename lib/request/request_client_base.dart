import 'package:mx_core/http/source_generator/annotation.dart';

import 'request_builder_base.dart';

/// request client 端的基底類
/// </p> 整個request的結構為一個 client 對應多的 builder
abstract class RequestClientBase {
  String host();

  String scheme();

  Map<String, String> queryParams() => {};

  Map<String, String> headers() => {};

  /// 預設 contentType
  HttpContentType? contentType() => null;

  /// 預設 bodyType
  HttpBodyType? bodyType() => null;

  dynamic body() => null;

  int? port() => null;

  /// api 的構建器
  /// 在此初始化並回傳
  List<RequestBuilderBase> builders();

  RequestClientBase() {
    reInitBuilder();
  }

  /// 重新初始化 builder
  void reInitBuilder() {
    _initBuilders(builders());
  }

  void _initBuilders(List<RequestBuilderBase> targets) {
    for (var target in targets) {
      _initBuilder(target);
    }
  }

  void _initBuilder(RequestBuilderBase target) {
    target.setDefault(
      clientScheme: scheme(),
      clientHost: host(),
      clientQueryParams: queryParams(),
      clientHeaders: headers(),
      clientBody: body(),
      clientPort: port(),
    );
  }
}
