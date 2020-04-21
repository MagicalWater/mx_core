import 'dart:async';
import 'package:flutter/services.dart';

class _NativeMethod {
  static const getFlavor = 'getFlavor';
  static const getAppName = 'getAppName';
}

/// 回調本地
class NativeChannel {
  static MethodChannel _channel = MethodChannel("project_channel");

  /// 取得渠道名
  static Future<String> get flavor async {
    final String flavor = await _channel.invokeMethod(_NativeMethod.getFlavor);
    return flavor;
  }

  /// 取得app名稱
  static Future<String> get appName async {
    final String flavor = await _channel.invokeMethod(_NativeMethod.getAppName);
    return flavor;
  }
}
