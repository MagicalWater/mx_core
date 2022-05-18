/// 宣告一個 abstract class 是個 api 請求的 interface
class Api {
  const Api();
}

/// 各個 method 的 path 皆可帶入變數
/// 示例
/// @Get('path1/path2/{變數名稱}')
/// HttpContent(@Path('變數名稱') String pathVar)

/// 宣告 method 為 get 方法
/// path 可帶入變數, 宣告方式為
class Get {
  final String path;
  final Map<String, String>? headers;
  final Map<String, String>? queryParams;
  final HttpContentType? contentType;
  final String? host;
  final String? scheme;
  final int? port;

  const Get(
    this.path, {
    this.headers,
    this.queryParams,
    this.host,
    this.scheme,
    this.contentType,
    this.port,
  });
}

/// 宣告 method 為 post 方法
class Post {
  final String path;
  final Map<String, String>? headers;
  final Map<String, String>? queryParams;
  final dynamic body;
  final HttpBodyType? bodyType;
  final HttpContentType? contentType;
  final String? host;
  final String? scheme;
  final int? port;

  const Post(
    this.path, {
    this.headers,
    this.queryParams,
    this.body,
    this.bodyType,
    this.host,
    this.scheme,
    this.contentType,
    this.port,
  });
}

/// 宣告 method 為 delete 方法
class Delete {
  final String path;
  final Map<String, String>? headers;
  final Map<String, String>? queryParams;
  final dynamic body;
  final HttpBodyType? bodyType;
  final HttpContentType? contentType;
  final String? host;
  final String? scheme;
  final int? port;

  const Delete(
    this.path, {
    this.headers,
    this.queryParams,
    this.body,
    this.bodyType,
    this.host,
    this.scheme,
    this.contentType,
    this.port,
  });
}

/// 宣告 method 為 put 方法
class Put {
  final String path;
  final Map<String, String>? headers;
  final Map<String, String>? queryParams;
  final dynamic body;
  final HttpBodyType? bodyType;
  final HttpContentType? contentType;
  final String? host;
  final String? scheme;
  final int? port;

  const Put(
    this.path, {
    this.headers,
    this.queryParams,
    this.body,
    this.bodyType,
    this.host,
    this.scheme,
    this.contentType,
    this.port,
  });
}

/// 宣告 method 為 download 方法
class Download {
  final String path;
  final Map<String, String>? headers;
  final Map<String, String>? queryParams;
  final dynamic body;
  final HttpBodyType? bodyType;
  final HttpContentType? contentType;
  final String? host;
  final String? scheme;
  final int? port;

  const Download(
    this.path, {
    this.headers,
    this.queryParams,
    this.body,
    this.bodyType,
    this.host,
    this.scheme,
    this.contentType,
    this.port,
  });
}

/// 宣告 method 裡面的參數為 path 裡面的變數
class Path {
  final String name;

  const Path(this.name);
}

/// 宣告 method 裡面的參數為 header
class Header {
  final String name;

  const Header(this.name);
}

/// 宣告 method 裡面的參數為 queryParam
class Param {
  final String name;

  const Param(this.name);
}

/// 宣告 method 裡面的參數為 body
class Body {
  final String? name;

  const Body([this.name]);
}

class HttpContentType {
  final String _value;

  const HttpContentType(this._value);

  String get value => _value;

  static const json = HttpContentType(HttpContentType._json);
  static const text = HttpContentType(HttpContentType._text);
  static const binary = HttpContentType(HttpContentType._binary);
  static const html = HttpContentType(HttpContentType._html);
  static const formUrlencoded =
      HttpContentType(HttpContentType._formUrlencoded);

  static const String _json = "application/json";
  static const String _text = "text/plain";
  static const String _binary = "application/octet-stream";
  static const String _html = "text/html";
  static const String _formUrlencoded = "application/x-www-form-urlencoded";
}

enum HttpBodyType {
  formData,
  formUrlencoded,
  raw,
}
