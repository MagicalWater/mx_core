import 'package:mx_core/mx_core.dart';

import 'ex_request_builder.dart';

export 'ex_request_builder.dart';

class ExRequestClient extends RequestClientBase with ExRequestClientMixin {
  static final _singleton = ExRequestClient._internal();

  static ExRequestClient getInstance() => _singleton;

  factory ExRequestClient() => _singleton;

  ExRequestClient._internal() : super();

  /// 初始化 request 構建
  @override
  List<RequestBuilderBase> builders() {
    return [
      exRequestApi = ExRequestBuilder(),
    ];
  }

  @override
  String scheme() {
    return "http";
  }

  @override
  String host() {
    return "www.exHost.com";
  }

  @override
  Map<String, String> headers() {
    return {
      "exDefaultHeaderKey": "exDefaultHeaderValue",
    };
  }

  @override
  Map<String, String> queryParams() {
    return {
      "exDefaultParamKey": "exDefaultParamValue",
    };
  }
}
