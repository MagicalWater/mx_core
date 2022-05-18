import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:mx_core/util/file_util.dart';
import 'package:path/path.dart';

import 'http_content.dart';
import 'http_value.dart';
import 'server_response.dart';
import 'source_generator/annotation.dart';

typedef ProgressCallback = void Function(int count, int total);

class HttpUtil {
  static final _singleton = HttpUtil._internal();

  factory HttpUtil() => _singleton;

  HttpUtil._internal() {
    setTimeout(1000 * 10);
    //默認返回純文字數據, 否則dio抓到json之後會把雙引號去掉變成假json
    _dio.options.responseType = ResponseType.plain;

    recordResponseCallback = (response) => _writeResponseToFile(response);

    CookieJar cookieJar = CookieJar();
    _cookieManager = CookieManager(cookieJar);
    _dio.interceptors.add(_cookieManager);
  }

  /// 設置代理
  String? _proxyIp;
  int? _proxyPort;

  /// 設置的證書信任
  bool Function(X509Certificate cert, String host, int port)?
      _badCertificateCallback;

  /// 第三方lib
  final Dio _dio = Dio();

  /// cookie 管理器
  late CookieManager _cookieManager;

  /// 取得 response 後, 將呼叫此方法將變數存入本地
  Future<void> Function(ServerResponse response)? recordResponseCallback;

  /// 連線 timeout 時間
  int get connectTimeout => _dio.options.connectTimeout;

  /// 設置 timeout
  void setTimeout(int value) => _dio.options.connectTimeout = value;

  /// 設定代理
  void setProxy(String ip, int port) {
    _proxyIp = ip;
    _proxyPort = port;
    _syncHttpClientAdapter();
  }

  /// 設置證書無效的處理
  void setBadCertificateCallback(
      bool Function(X509Certificate cert, String host, int port) callback) {
    _badCertificateCallback = callback;
    _syncHttpClientAdapter();
  }

  /// 將 response 存入本地
  Future<void> _writeResponseToFile(ServerResponse response) {
    var uri = Uri.parse(response.url);
    var segments = ["ServerResponse", uri.host] + uri.pathSegments;
    var name = segments.removeLast();
    var nameNoExtension = basenameWithoutExtension(name);
    segments.add("$nameNoExtension.txt");
    var fullPath = joinAll(segments);
    return FileUtil.write(name: fullPath, content: response.getString() ?? '');
  }

  /// 同步 httpClient 設定(代理/證書信任)
  void _syncHttpClientAdapter() {
    if ((_proxyIp == null || _proxyIp!.isNotEmpty) &&
        _proxyPort == null &&
        _badCertificateCallback == null) {
      // 不需要設置代理, 也不需要設置證書信任
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          null;
    } else {
      // 需要設置代理或者證書信任
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        if (_proxyIp != null && _proxyIp!.isNotEmpty && _proxyPort != null) {
          client.findProxy = (uri) {
            return "PROXY ${_proxyIp!.trim()}:$_proxyPort";
          };
        }
        if (_badCertificateCallback != null) {
          client.badCertificateCallback = _badCertificateCallback;
        }
      };
    }
  }

  /// 加入請求攔截器
  /// cookie 取出, 全都需要判空
  ///
  /// <p>在 [onRequest] 方法</p>
  /// 可使用 以下兩種方法取得 cookie
  ///
  /// * String cookie = option.headers[HttpHeaders.cookieHeader];
  /// * List<Cookie> cookies = HttpUtil.cookieManager.cookieJar.loadForRequest(option.uri);
  ///
  /// <p>在 [onResponse] 方法</p>
  /// 可使用 以下兩種方法取得 cookie
  ///
  /// * String cookie = response.headers[HttpHeaders.setCookieHeader];
  /// * List<Cookie> cookies = HttpUtil.cookieManager.cookieJar.loadForRequest(response.request.uri);
  ///
  /// <p>在 [onError] 方法</p>
  ///
  /// * 可使用 [error.response] 取得 [Response], 在按照上方的方式取得 cookie
  void addInterceptor(InterceptorsWrapper interceptor) {
    _dio.interceptors.add(interceptor);
  }

  Future<ServerResponse> get(
    String url, {
    Map<String, dynamic> queryParams = const {},
    Map<String, dynamic> headers = const {},
    ContentType? contentType,
  }) {
    print("[GET請求]: $url, query: $queryParams");
    Future<Response<dynamic>> request = _dio.get(
      url,
      queryParameters: queryParams,
      options: Options(headers: headers, contentType: contentType?.value),
    );
    return _packageRequest(
      request: request,
      url: url,
      queryParams: queryParams,
      headers: headers,
      method: HttpMethod.get,
    );
  }

  Future<ServerResponse> getUri(
    Uri uri, {
    Map<String, dynamic> headers = const {},
    ContentType? contentType,
  }) {
    print("[GET請求]: $uri");
    Future<Response<dynamic>> request = _dio.getUri(
      uri,
      options: Options(
        headers: headers,
        contentType: contentType?.value,
      ),
    );
    return _packageRequest(
      request: request,
      url: '${uri.scheme}://${uri.host}${uri.path}',
      queryParams: uri.queryParametersAll,
      headers: headers,
      method: HttpMethod.get,
    );
  }

  Future<ServerResponse> post(
    String url, {
    Map<String, dynamic> queryParams = const {},
    Map<String, dynamic> headers = const {},
    dynamic bodyData,
    ContentType? contentType,
  }) {
    print("[POST請求]: $url, body: $bodyData");
    Future<Response<dynamic>> request = _dio.post(
      url,
      data: bodyData,
      queryParameters: queryParams,
      options: Options(headers: headers, contentType: contentType?.value),
    );
    return _packageRequest(
      request: request,
      url: url,
      queryParams: queryParams,
      headers: headers,
      bodyData: bodyData,
      method: HttpMethod.post,
    );
  }

  Future<ServerResponse> put(
    String url, {
    Map<String, dynamic> queryParams = const {},
    Map<String, dynamic> headers = const {},
    dynamic bodyData,
    ContentType? contentType,
  }) {
    print("[PUT請求]: $url, body: $bodyData");

    Future<Response<dynamic>> request = _dio.put(
      url,
      data: bodyData,
      queryParameters: queryParams,
      options: Options(headers: headers, contentType: contentType?.value),
    );
    return _packageRequest(
      request: request,
      url: url,
      queryParams: queryParams,
      headers: headers,
      bodyData: bodyData,
      method: HttpMethod.put,
    );
  }

  Future<ServerResponse> delete(
    String url, {
    Map<String, dynamic> queryParams = const {},
    Map<String, dynamic> headers = const {},
    dynamic bodyData,
    ContentType? contentType,
  }) {
    print("[DELETE請求]: $url, body: $bodyData");
    Future<Response<dynamic>> request = _dio.delete(
      url,
      data: bodyData,
      queryParameters: queryParams,
      options: Options(headers: headers, contentType: contentType?.value),
    );
    return _packageRequest(
      request: request,
      url: url,
      queryParams: queryParams,
      headers: headers,
      bodyData: bodyData,
      method: HttpMethod.delete,
    );
  }

  Future<ServerResponse> download(
    String url, {
    required String savePath,
    Map<String, dynamic> queryParams = const {},
    Map<String, dynamic> headers = const {},
    dynamic bodyData,
    ContentType? contentType,
    ProgressCallback? onReceiveProgress,
  }) {
    Future<Response<dynamic>> request = _dio.download(
      url,
      savePath,
      data: bodyData,
      queryParameters: queryParams,
      options: Options(headers: headers, contentType: contentType?.value),
      onReceiveProgress: onReceiveProgress,
    );
    return _packageRequest(
      request: request,
      url: url,
      queryParams: queryParams,
      headers: headers,
      savePath: savePath,
      method: HttpMethod.download,
    );
  }

  /// 將 request 外層包裹 Observable, 並處理相關錯誤
  Future<ServerResponse> _packageRequest({
    required Future<Response<dynamic>> request,
    required String url,
    required HttpMethod method,
    String? savePath,
    Map<String, dynamic> queryParams = const {},
    Map<String, dynamic> headers = const {},
    dynamic bodyData,
  }) {
    var requestFuture = request.onError(
      (error, stackTrace) {
        var packageError = _handleError(
          error as DioError,
          url,
          queryParams,
          headers,
          bodyData,
          method,
        );

        recordResponseCallback?.call(packageError.response!);
        return Future.error(packageError);
      },
      test: (error) {
        // 只捕捉 DioError, 其餘不捕捉
        return error is DioError;
      },
    ).then((value) {
      return ServerResponse(
        response: value,
        url: url,
        params: queryParams,
        headers: headers,
        body: bodyData,
        saveInPath: savePath,
        method: method,
      );
    });

    // 檢查是否需要將 response 紀錄到本地
    if (recordResponseCallback != null) {
      requestFuture = requestFuture.then((response) {
        recordResponseCallback?.call(response);
        return response;
      });
    }
    return requestFuture;
  }

  /// 使用 HttpContent 進行 request 呼叫
  Future<ServerResponse> connect(
    HttpContent content, {
    ProgressCallback? onReceiveProgress,
  }) {
    switch (content.method) {
      case HttpMethod.get:
        return getUri(
          content.uri,
          headers: content.headers,
          contentType: content.contentType,
        );
      case HttpMethod.post:
        var bodyData = _convertBodyData(content.bodyData, content.bodyType);
        return post(
          content.url,
          queryParams: content.queryParams,
          headers: content.headers,
          bodyData: bodyData,
          contentType: content.contentType,
        );
      case HttpMethod.delete:
        var bodyData = _convertBodyData(content.bodyData, content.bodyType);
        return delete(
          content.url,
          queryParams: content.queryParams,
          headers: content.headers,
          bodyData: bodyData,
          contentType: content.contentType,
        );
      case HttpMethod.put:
        var bodyData = _convertBodyData(content.bodyData, content.bodyType);
        return put(
          content.url,
          queryParams: content.queryParams,
          headers: content.headers,
          bodyData: bodyData,
          contentType: content.contentType,
        );
      case HttpMethod.download:
        var bodyData = _convertBodyData(content.bodyData, content.bodyType);
        return download(
          content.url,
          savePath: content.saveInPath!,
          queryParams: content.queryParams,
          headers: content.headers,
          bodyData: bodyData,
          contentType: content.contentType,
          onReceiveProgress: onReceiveProgress,
        );
      default:
        print("未知 reuqest method: {${content.method}}, 自動採用 get");
        return get(
          content.url,
          queryParams: content.queryParams,
          headers: content.headers,
        );
    }
  }

  /// 將 HttpContent 的 body 做轉換
  dynamic _convertBodyData(dynamic bodyData, HttpBodyType? bodyType) {
    if (bodyType != null && bodyData != null) {
      switch (bodyType) {
        case HttpBodyType.formData:
          // formData 可以帶 File, 所以要做對 dio 的轉換
          // bodyData = (bodyData as Map<String, dynamic>).map((k, v) {
          //   if (v is FileInfo) {
          //     return MapEntry(k,
          //         MultipartFile.fromFileSync(v.filepath, filename: v.filename));
          //   } else if (v is List) {
          //     var mapValue = v.map((e) {
          //       if (e is FileInfo) {
          //         return MultipartFile.fromFileSync(e.filepath,
          //             filename: e.filename);
          //       } else {
          //         return e;
          //       }
          //     }).toList();
          //     return MapEntry(k, mapValue);
          //   } else {
          //     return MapEntry(k, v);
          //   }
          // });
          bodyData = FormData.fromMap(bodyData);
          break;
        case HttpBodyType.formUrlencoded:
          // 不用做任何轉換
          break;
        case HttpBodyType.raw:
          // 不用做任何轉換
          break;
      }
    }
    return bodyData;
  }

  /// 處理請求發出後得到的 error
  HttpError _handleError(
    DioError error,
    String url,
    Map<String, dynamic> queryParams,
    Map<String, dynamic> headers,
    dynamic body,
    HttpMethod method,
  ) {
    print('====== 請求錯誤 ======');
    print('url: $url');
    print('標頭: $headers');
    print('參數: $queryParams');
    print('Body: $body');
    print('錯誤: $error');
    print('=====================');
    return HttpError(
      request: error.requestOptions,
      error: error.error,
      type: _convertToHttpErrorType(error.type),
      response: ServerResponse(
        response: error.response,
        url: url,
        params: queryParams,
        headers: headers,
        body: body,
        method: method,
        error: error,
      ),
    );
  }

  /// 將 Dio 的 Error 轉換為自訂的 Error
  HttpErrorType _convertToHttpErrorType(DioErrorType type) {
    switch (type) {
      case DioErrorType.connectTimeout:
        return HttpErrorType.connectTimeout;
      case DioErrorType.sendTimeout:
        return HttpErrorType.sendTimeout;
      case DioErrorType.receiveTimeout:
        return HttpErrorType.receiveTimeout;
      case DioErrorType.response:
        return HttpErrorType.response;
      case DioErrorType.cancel:
        return HttpErrorType.cancel;
      default:
        return HttpErrorType.other;
    }
  }
}

class HttpError extends Error implements Exception {
  HttpError({
    required this.request,
    required this.response,
    // required this.message,
    this.type = HttpErrorType.other,
    required this.error,
    this.stackTrace,
  });

  /// 請求相關訊息
  RequestOptions request;

  /// 當無法到達 host 時, response.response 有可能為 null
  ServerResponse? response;

  /// Error 訊息
  // String message;

  HttpErrorType type;

  /// The original error/exception object; It's usually not null when `type`
  /// is DioErrorType.DEFAULT
  dynamic error;

  @override
  String toString() =>
      "錯誤: 請求異常 [${response?.response?.statusCode ?? type.toString()}]: ${request.queryParameters}";

  /// 將錯誤類型轉換為真正顯示的字串

  /// Error 堆疊
  @override
  StackTrace? stackTrace;
}

/// 直接從 dio 轉為自己的錯誤訊息
enum HttpErrorType {
  /// It occurs when url is opened timeout.
  connectTimeout,

  /// It occurs when url is sent timeout.
  sendTimeout,

  ///It occurs when receiving timeout.
  receiveTimeout,

  /// When the server response, but with a incorrect status, such as 404, 503...
  response,

  /// When the request is cancelled, dio will throw a error with this type.
  cancel,

  /// Default error type, Some other Error. In this case, you can
  /// use the DioError.error if it is not null.
  other,
}
