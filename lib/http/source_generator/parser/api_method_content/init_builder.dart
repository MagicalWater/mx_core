import '../../element_parser.dart';
import 'builder.dart';

/// Http 初始化構建類
class InitBuilder implements Builder {
  String? path;
  ApiMethodType? method;
  String? contentType;
  String? scheme;
  String? host;
  int? port;

  void setting({
    String? path,
    ApiMethodType? method,
    String? contentType,
    String? scheme,
    String? host,
    int? port,
  }) {
    this.path = path ?? this.path;
    this.method = method ?? this.method;
    this.contentType = contentType ?? this.contentType;
    this.scheme = scheme ?? this.scheme;
    this.host = host ?? this.host;
    this.port = port ?? this.port;
  }

  @override
  String build() {
    if (method == null) {
      return '';
    }

    var text =
        "var content = generator.generate('$path', method: ${getMethodText()}";

    if (host != null) {
      text += ", host: \"$host\"";
    }

    if (scheme != null) {
      text += ", scheme: \"$scheme\"";
    }

    if (port != null) {
      text += ", port: $port";
    }

    if (contentType != null) {
      text += ", contentType: ContentType.parse(\"$contentType\")";
    }

    text += ");";

    return text;
  }

  String getMethodText() {
    var text = '';
    switch (method!) {
      case ApiMethodType.get:
        text = 'HttpMethod.get';
        break;
      case ApiMethodType.post:
        text = 'HttpMethod.post';
        break;
      case ApiMethodType.delete:
        text = 'HttpMethod.delete';
        break;
      case ApiMethodType.put:
        text = 'HttpMethod.put';
        break;
      case ApiMethodType.download:
        text = 'HttpMethod.download';
        break;
    }
    return text;
  }
}
