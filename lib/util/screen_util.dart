import 'dart:math';
import 'dart:ui' as ui show window;

import 'package:flutter/material.dart';

/// 原作者: thl
/// 參考: https://github.com/Sky24n
///
/// 修改者: Water

/// 取得螢幕 size 相關類
class Screen {
  /// 給外部獲取的資料
  /// 螢幕寬
  static double get width => _screenW;

  /// 螢幕寬
  static double get height => _screenH;

  /// 螢幕手機內容高度 (減去狀態欄 / 底部導航欄)
  static double get contentHeight => height - statusBarHeight - bottomBarHeight;

  static double get appBarHeight => _appBarH;

  /// 螢幕像素密度
  static double get density => _screenD;

  /// 狀態欄高
  static double get statusBarHeight => _statusBarH;

  /// 底部 bar 高
  static double get bottomBarHeight => _bottomBarH;

  static ValueChanged<Orientation>? orientationListener;

  /// 裝置方向
  static Orientation get orientation => _mediaQueryData.orientation;

  /// media Query Data
  static MediaQueryData get mediaQueryData => _mediaQueryData;

  /// 此類進行 WidgetsBinding 的回調綁定
  static final _ScreenBinding _screenDataBinding = _ScreenBinding();

  /// [_screenDataBinding] 是否已經綁定了
  static bool _isScreenDataBind = false;

  /// 最新的螢幕相關尺寸
  static late MediaQueryData _mediaQueryData;
  static bool _isInit = false;

  static double _screenW = 360.0;

  /// 螢幕寬
  static double _screenH = 640.0;

  /// 螢幕高
  static double _screenD = 3.0;

  /// 密度
  static double _statusBarH = 0;

  /// 狀態欄高
  static double _bottomBarH = 0;

  /// 底部高
  static double _appBarH = 0;

  /// 面積縮放字典
  static final Map<String, double> _areaScalingCoefficientMap = {};

  /// 字體縮放字典
  static final Map<String, double> _spScalingCoefficientMap = {};

  /// 默認設計稿尺寸
  static double _designW = 360.0;
  static double _designH = 640.0;
  static double _designD = 3.0;

  /// 設定設計稿尺寸, 在 app初始化時即呼叫
  /// w 寬
  /// h 高
  /// density 像素密度
  static void setDesignWHD({
    required double w,
    required double h,
    double density = 3.0,
  }) {
    _designW = w;
    _designH = h;
    _designD = density;
    init();
  }

  /// 初始化螢幕相關數值
  static void init([bool printLog = true]) {
    // 一般在 runApp 時會呼叫 [WidgetsFlutterBinding.ensureInitialized()]
    // 此方法會進行 WidgetsBinding 的初始化, 並賦予 WidgetsBinding.instance 值
    // 但可以先在 runApp 之前即執行此方法, 讓我們可以先取得 WidgetsBinding
    // 優先進行 didChangeMetrics 的綁定
    //
    // 以下是題外話:
    // 對於 runApp 執行上方提到的 WidgetsBinding 綁定動作後
    // 接著會呼叫 [attachRootWidget] 進行根元件的綁定
    // 最後執行 [scheduleWarmUpFrame] 進行元件的第一次繪製
    // 並且在此事件完成前不會接收任何的點擊事件
    //
    _bindScreenData();

    MediaQueryData mediaQuery = MediaQueryData.fromWindow(ui.window);
    if (!_isInit ||
        (_mediaQueryData != mediaQuery && mediaQuery.size != Size.zero)) {
      _screenW = mediaQuery.size.width;
      _screenH = mediaQuery.size.height;
      _screenD = mediaQuery.devicePixelRatio;
      _statusBarH = mediaQuery.padding.top;
      _bottomBarH = mediaQuery.padding.bottom;
      _appBarH = kToolbarHeight;

      if (_isInit) {
        final beforeOrientation = _mediaQueryData.orientation;
        _mediaQueryData = mediaQuery;
        final afterOrientation = _mediaQueryData.orientation;

        if (beforeOrientation != afterOrientation) {
          orientationListener?.call(afterOrientation);
        }
      } else {
        _mediaQueryData = mediaQuery;
        final afterOrientation = _mediaQueryData.orientation;
        orientationListener?.call(afterOrientation);
      }

      if (printLog) {
        print('''
════════════ 螢幕資訊 ════════════
寬高密 $_screenW x $_screenH x $_screenD
狀態欄 $_statusBarH
導航欄 $_bottomBarH
AppBar $appBarHeight
═════════════════════════════════
      ''');
      }

      _isInit = true;
    }
  }

  /// 設置面積縮放係數
  static void setAreaScalingCoefficient(String tag, double scale) =>
      _areaScalingCoefficientMap[tag] = scale;

  /// 設置字體縮放係數
  static void setSpScalingCoefficient(String tag, double scale) =>
      _spScalingCoefficientMap[tag] = scale;

  /// 取得面積縮放係數
  static void getAreaScalingCoefficient(String tag) =>
      _areaScalingCoefficientMap[tag];

  /// 取得字體縮放係數
  static void getSpScalingCoefficient(String tag) =>
      _spScalingCoefficientMap[tag];

  /// 當前 MediaQueryData, 同時更新 _mediaQueryData
  static MediaQueryData getMediaQueryData(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    return _mediaQueryData;
  }

  /// 返回根據螢幕寬適配尺寸
  static double scaleW(double size, [BuildContext? context]) {
    return size * _screenW / _designW;
  }

  /// 返回根據螢幕面積適配尺寸再依據tag乘上縮放係數
  static double scaleA(double size, [String? tag]) {
    final scaling = _getAreaScalingCoefficient(tag);
    return _scaleA(size) * scaling;
  }

  /// 返回根據螢幕高適配尺寸
  static double scaleH(double size) {
    return size * _screenH / _designH;
  }

  /// 返回根據螢面積寬適配字體尺寸再依據tag乘上對應縮放係數
  static double scaleSp(double fontSize, [String? tag]) {
    final scaling = _getSpScalingCoefficient(tag);
    return _scaleA(fontSize) * scaling;
  }

  /// 返回根據螢幕寬度,密度適配尺寸
  static double scaleW2Px(double sizePx) {
    return _screenW == 0.0
        ? (sizePx / _designD)
        : (sizePx * _screenW / (_designW * _designD));
  }

  /// 返回根據螢幕高度,密度適配尺寸
  static double scaleH2Px(double sizePx) {
    return _screenH == 0.0
        ? (sizePx / _designD)
        : (sizePx * _screenH / (_designH * _designD));
  }

  /// 取得面積縮放係數
  static double _getAreaScalingCoefficient(String? tag) {
    if (tag == null) return 1;
    return _areaScalingCoefficientMap[tag] ?? 1;
  }

  /// 取得字體縮放係數
  static double _getSpScalingCoefficient(String? tag) {
    if (tag == null) return 1;
    return _spScalingCoefficientMap[tag] ?? 1;
  }

  /// 返回根據螢幕面積適配尺寸
  static double _scaleA(double size) {
    return size * sqrt((_screenW * _screenH) / (_designW * _designH));
  }

  /// 將 [_screenDataBinding] 綁定到 [WidgetsBinding]
  static void _bindScreenData() {
    if (!_isScreenDataBind) {
      WidgetsFlutterBinding.ensureInitialized();
      _isScreenDataBind = true;
      WidgetsBinding.instance.addObserver(_screenDataBinding);
    }
  }
}

/// 由此類進行 WidgetsBindingObserver 的綁定
/// 在 Metrics 有變更時更新 Screen 的相關變數
class _ScreenBinding with WidgetsBindingObserver {
  @override
  void didChangeMetrics() {
    Screen.init(false);
    super.didChangeMetrics();
  }
}

/// 快速擴展
extension ScreenScale on num {
  double get scaleA => Screen.scaleA(toDouble());

  double get scaleW => Screen.scaleW(toDouble());

  double get scaleSp => Screen.scaleSp(toDouble());
}
