import 'dart:async';
import 'dart:ui';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mx_core/keyboard/keyboard_client.dart';
import 'package:mx_core/keyboard/keyboard_controller.dart';
import 'package:mx_core/keyboard/keyboard_media_query.dart';
import 'package:mx_core/keyboard/keyboard_page.dart';

/// 自定義鍵盤目前有兩種做法
///
/// 方法1 -
///   直接在 TextField 以及 EditableText 處攔截系統鍵盤(顯示/隱藏)的呼叫, 改為自己的
///     a. 具體可參考 https://www.jianshu.com/p/a0e1601dbd15
///
/// 方法2 -
///   由於 系統呼叫鍵盤的方式是使用消息傳遞呼叫本地方法啟動鍵盤, 因此可攔截消息傳遞自行顯示
///     a. 攔截的關鍵是 setMockMessageHandler 以及 flutter/textinput
///     b. 網路上已有人處理此部分 https://github.com/Im-Kevin/cool_ui
///
///
/// 分析
/// 兩種方式都有可能因為sdk的版本更迭而失效
/// 方法1 -
///   a. 需要創建出自定 Widget([TextField] 以及 [EditableText])(完全複製, 修改裡面調用鍵盤的原碼)
///
/// 方法2 -
///   a. 使用 setMockMessageHandler 攔截消息傳遞, 並且需要實作做多項原本已有的 class 替代原本的
///
/// 採用 方法2
/// 參考: https://github.com/Im-Kevin/cool_ui
/// 原作者: Im-Kevin
///
/// 修改者: Water
///

/// 取得當下 context, keyboard 的高度
typedef KeyboardHeightGetter = double Function(BuildContext context);

/// 取得當下 context, keyboard 的元件
typedef KeyboardBuilder = Widget Function(
    BuildContext context, KeyboardController controller);

/// 鍵盤事件攔截
class KeyboardIntercept {
  static final _singleton = KeyboardIntercept._internal();

  static KeyboardIntercept getInstance() => _singleton;

  factory KeyboardIntercept() => _singleton;

  KeyboardIntercept._internal();

  /// 解碼攔截消息傳遞的 byteData
  JSONMethodCodec _codec = JSONMethodCodec();

  /// 以 inputType 為 key, 儲存對應的自訂鍵盤訊息
  Map<KeyboardInputType, KeyboardConfig> _keyboardConfigMap = {};

  /// 當前正在顯示的 keyboard config
  KeyboardConfig? _currentKeyboardConfig;

  /// 鍵盤是否即將顯示
  /// 原本是用 [_currentKeyboardConfig] 判斷
  /// 但因為鍵盤的彈出與收起會有動畫
  /// 而 [_currentKeyboardConfig] 會在動畫結束後才變為對應的值
  /// 但在動畫的同時, 我們就需要讓外層元件可以知道鍵盤是否張開或收起
  /// 因此此參數就是在第一時間可以對應到正確得值
  bool isKeyboardShow = false;

  /// 外部獲取當前正在顯示的 keyboard config
  double get currentKeyboardHeight =>
      isKeyboardShow ? _currentKeyboardConfig?.height ?? 0 : 0;

//  double get currentKeyboardHeight => 0;

  /// 當前正在顯示的 keyboard controller
  KeyboardController? _currentKeyboardController;

  /// 當前顯示的 overlay, 自定鍵盤都是以overlay的方式顯示
  OverlayEntry? _currentKeyboardOverlayEntry;

  /// 當前顯示鍵盤的外層佈局 PageWidget 的 global key, 方便獲取 state 進行事件處理
  /// 目前用在鍵盤隱藏的動畫事件
  static GlobalKey<KeyboardPageState>? _currentPageGlobalKey;

  /// 當前綁定自定義鍵盤的 context
  BuildContext? _currentContext;

  /// 當前針對需要顯示鍵盤的消息傳遞
  /// 是否需要攔截
  /// 此參數會在傳遞 KeyboardMessageMethod._setClient 此消息時決定
  bool isCustomKeyboardShow = false;

  /// 添加自訂 keyboard
  static void addKeyboard(KeyboardInputType inputType, KeyboardConfig config) {
    getInstance()._keyboardConfigMap[inputType] = config;
  }

  /// 綁定鍵盤
  void intercept(BuildContext context) {
    _currentContext = context;
    _intercept();
  }

  /// 先攔截本地傳遞鍵盤消息的事件
  void _intercept() {
    print("啟動鍵盤攔截");
    ServicesBinding.instance!.defaultBinaryMessenger
        .setMockMessageHandler('flutter/textinput', (ByteData? data) async {
      print("接收到事件");
      // 將 data 轉為 methodCall 獲得事件名稱
      var methodCall = _codec.decodeMethodCall(data);
      switch (methodCall.method) {
        case KeyboardMessageMethod._show:
          print("KeyboardIntercept 呼叫 show");
          // 若 [_currentKeyboardConfig] 不為 null, 代表有找到 config 並且要開啟自訂鍵盤
          if (_currentKeyboardConfig != null && isCustomKeyboardShow) {
            print("show 事件攔截");
            _showKeyboard();
            return _codec.encodeSuccessEnvelope(null);
          }
          break;
        case KeyboardMessageMethod._hide:
          print("KeyboardIntercept 呼叫 hide");
          // 若 [_currentKeyboardConfig] 不為 null, 代表有找到 config, 因此需要關閉自定義鍵盤
//          if (_currentKeyboardConfig != null) {
//            hideKeyboard();
//            return _codec.encodeSuccessEnvelope(null);
//          }
          break;
        case KeyboardMessageMethod._setEditingState:
          print("KeyboardIntercept 呼叫 setEditingState");
          var editingState = TextEditingValue.fromJSON(methodCall.arguments);
          // 若再經過參數解析後不為null, 並且 [_currentKeyboardController] 不為 null
          // 代表當前自定義鍵盤正在顯示, 因此直接設置值到 [_currentKeyboardController]
          if (_currentKeyboardController != null) {
            _currentKeyboardController!.value = editingState;
            return _codec.encodeSuccessEnvelope(null);
          }
          break;
        case KeyboardMessageMethod._setClient:
          print("KeyboardIntercept 呼叫 setClient");

          // 準備顯示鍵盤
          // 先從 methodCall 取出鍵盤類型
          // methodCall 的參數都是 Map, 具體參數可參考 assets/jsons/keyboard/set_client.json
          var inputTypeArg = methodCall.arguments[1]['inputType'];
          KeyboardConfig? config = _findKeyboardConfig(inputTypeArg);
          if (config != null) {
            print("找到設定檔, 清除當前鍵盤重新綁定");
            // 代表有找到鍵盤類型對應的設定檔
            // 先清除當前的 [_currentKeyboardConfig] 以及 [_currentKeyboardController]
            // 要重新綁定設定檔以及控制器
            _clearCurrentKeyboard();
            _bindNewKeyboard(
                config, KeyboardClient.fromArgs(methodCall.arguments));

            isCustomKeyboardShow = true;

            // 因為要開啟自訂的鍵盤, 因此要主動發訊息給 native 層, 讓 native 層關閉鍵盤
            await _sendPlatformMessage("flutter/textinput",
                _codec.encodeMethodCall(MethodCall('TextInput.hide')));

            // 最後直接返回攔截此次事件
            return _codec.encodeSuccessEnvelope(null);
          } else {
            print("沒找到, 清除當前鍵盤");

            isCustomKeyboardShow = false;

            // 沒有找到鍵盤類型對應的設定檔案
            // 因此隱藏當前的鍵盤, 並且清除
            // 不處理此次事件
            hideKeyboard();
          }
          break;
        case KeyboardMessageMethod._clearClient:
          print("KeyboardIntercept 呼叫 clearClient");

          isCustomKeyboardShow = false;

          // 依照流程來看, 此處會先呼叫, 接著在呼叫 hide
          // 但 hide 裡面為什麼只調用 [hideKeyboard()],
          // 而沒有 [_clearCurrentKeyboard()]
          // 並且照理來說這邊調用完了之後
          // hide 應該就不動作了
          // TODO: 不清楚上述原因
          hideKeyboard();
          break;
        default:
          // 當 method 並非是我們要攔截的時候, 則我們在往下送到native
          print("KeyboardIntercept 呼叫未知: ${methodCall.method}");
          break;
      }

      // 當執行到此, 代表我們不自行處理, 因此不攔截, 依照原本消息傳遞到native層
      // 當 method 並非是我們要攔截的時候, 則我們在往下送到native
      return await _sendPlatformMessage("flutter/textinput", data);
    });
  }

  /// 顯示自定義鍵盤
  void _showKeyboard() {
    // 鍵盤是以 overlay entry 方式顯示
    // 若當前 entry 不為 null, 代表鍵盤已經開啟
    // 因此不需要再顯示, 但需要通知當前的 [_currentKeyboardOverlayEntry] 重建
    // 才可以重新綁定 keyboardController
    if (_currentKeyboardOverlayEntry != null) {
      _currentKeyboardOverlayEntry!.markNeedsBuild();
      return;
    }

    // 要顯示鍵盤, 立刻將此值改為 true 供給 KeyboardMediaQueryState 使用
    isKeyboardShow = true;

    // 生成 global key, 並賦予給即將顯示的 entry
    _currentPageGlobalKey = GlobalKey<KeyboardPageState>();

    // 通知 包裹在元件外層的 PageMediaQuery 元件刷新
    // 如果有找到外層的話
    try {
      var queryState =
          _currentContext!.findAncestorStateOfType<KeyboardMediaQueryState>();
      if (queryState != null && queryState is KeyboardMediaQueryState) {
        queryState.update();
      }
    } catch (_) {
      print(
          "找不到 KeyboardMediaQuery, 自定義鍵盤外部需包含 KeyboardMediaQuery 元件, 因此無法自動調整鍵盤覆蓋到的元件高度");
    }

    // 生成 overlay entry
    _currentKeyboardOverlayEntry = OverlayEntry(builder: (context) {
      // 在隱藏鍵盤時, 會呼叫 [KeyboardPage] 的動畫縮起
      // 此處會重新被觸發
      // 因此須在此判斷 [_currentKeyboardConfig] 是否還存在
      print("觸發 entry 構建");
      if (_currentKeyboardConfig == null) return Container();

      var tempKey = _currentPageGlobalKey;

      return KeyboardPage(
        key: tempKey,
        child: _currentKeyboardConfig!.builder(
          context,
          _currentKeyboardController!,
        ),
        height: _currentKeyboardConfig!.height,
      );
    });

    print("使用 overlay 顯示 keyboard");

    // 顯示 overlay entry
    Overlay.of(_currentContext!)!.insert(_currentKeyboardOverlayEntry!);

    // 因為顯示自訂鍵盤, 因此需要處理 android 的返回按鈕事件
    // zIndex 則是消費的先後順序(具體規則看 lib 文件)
    BackButtonInterceptor.add(
      (bool stopDefaultButtonEvent, RouteInfo routeInfo) {
        // 監聽到事件時, 呼叫隱藏鍵盤的 action
        // 但這邊不是直接呼叫此處的隱藏鍵盤
        // 而是再以消息機制與本地溝通
        // TODO: 不清楚要以消息機制與本地溝通的原因
        sendPerformAction(TextInputAction.done);

        // 回傳是否消費返回事件
        return true;
      },
      zIndex: 1,
      name: 'CustomKeyboard',
    );
  }

  /// 隱藏當前的鍵盤
  void hideKeyboard({bool animation = true}) {
    print("呼叫: hideKeyboard");

    // 取消已註冊的返回按鈕監聽
    BackButtonInterceptor.removeByName('CustomKeyboard');

    /// 移除 keyboard 的 Entry
    void removeKeyboardEntry() {
      print("執行移除");
      if (_currentKeyboardOverlayEntry != null) {
        _currentKeyboardOverlayEntry!.remove();
        _currentKeyboardOverlayEntry = null;
      }
      // 移除 [_currentPageGlobalKey]
      _currentPageGlobalKey = null;

      _clearCurrentKeyboard();
    }

    // 要隱藏鍵盤, 立刻將此值改為 false 供給 KeyboardMediaQueryState 使用
    isKeyboardShow = false;

    // 如果虛擬鍵盤當前是顯示狀態, 則需要通知隱藏
    if (_currentKeyboardOverlayEntry != null && _currentPageGlobalKey != null) {
      // 從 [_currentPageGlobalKey] 找到對應的 KeyboardPageState
      // 往 animationController 註冊 鍵盤狀態監聽
      // 當狀態為 completed / dismissed 時, 移除keyboard的overlay相關的物件

      final pageState = _currentPageGlobalKey!.currentState!;
      pageState.animationController.addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.dismissed ||
            status == AnimationStatus.completed) {
          print("動畫最終移除 status = $status");
          removeKeyboardEntry();
        }
      });

      // 接著判斷是否需要動畫退出鍵盤
      if (animation) {
        // 動畫退出鍵盤, 呼叫 KeyboardPageWidget 執行動畫隱藏
        print("動畫移除 keyboard");
        pageState.hideKeyboard();
      } else {
        // 不需要動畫, 直接移除 Overlay Entry
        print("直接移除 keyboard");
        removeKeyboardEntry();
      }

      // 呼叫包裹在鍵盤元件外層的 Widget 通知刷新
      try {
        var queryState =
            _currentContext!.findAncestorStateOfType<KeyboardMediaQueryState>();
        if (queryState != null && queryState is KeyboardMediaQueryState) {
          queryState.update();
        }
      } catch (_) {
        print(
            "找不到 KeyboardMediaQuery, 自定義鍵盤外部需包含 KeyboardMediaQuery 元件, 因此無法自動調整鍵盤覆蓋到的元件高度");
      }
    }
  }

  /// 綁定新的鍵盤設定以及鍵盤控制器
  void _bindNewKeyboard(KeyboardConfig config, KeyboardClient client) {
    _currentKeyboardConfig = config;
    _currentKeyboardController = KeyboardController(client: client)
      ..addListener(_customKeyboardControllerListener);
  }

  void _customKeyboardControllerListener() {
    // 監聽 keyboard controller 文字的變更, 再發送文字變更通知使元件收到通知
    var callbackMethodCall = MethodCall("TextInputClient.updateEditingState", [
      _currentKeyboardController!.client.connectionId,
      _currentKeyboardController!.value.toJSON()
    ]);
    ServicesBinding.instance!.defaultBinaryMessenger.handlePlatformMessage(
      "flutter/textinput",
      _codec.encodeMethodCall(callbackMethodCall),
      (data) {},
    );
  }

  /// 清除當前綁定的鍵盤設定檔以及鍵盤控制器
  void _clearCurrentKeyboard() {
    _currentKeyboardConfig = null;
    if (_currentKeyboardController != null) {
      _currentKeyboardController!
          .removeListener(_customKeyboardControllerListener);
      _currentKeyboardController!.dispose();
      _currentKeyboardController = null;
    }
  }

  /// 從 [_keyboardConfigMap] 尋找對應keyboard的config
  /// 找不到則返回 null
  KeyboardConfig? _findKeyboardConfig(dynamic inputTypeArg) {
    KeyboardConfig? config;
    _keyboardConfigMap.forEach((inputType, keyboardConfig) {
      if (inputType.name == inputTypeArg['name']) {
        config = keyboardConfig;
      }
    });
    return config;
  }

  /// 傳送消息到本地
  /// 直接複製於 [_DefaultBinaryMessenger._sendPlatformMessage]
  Future<ByteData> _sendPlatformMessage(String channel, ByteData? message) {
    final Completer<ByteData> completer = Completer<ByteData>();
    window.sendPlatformMessage(channel, message, (ByteData? reply) {
      try {
        completer.complete(reply);
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'services library',
          context:
              ErrorDescription('during a platform message response callback'),
        ));
      }
    });
    return completer.future;
  }

  /// 為了讓元件能夠正常運行, 因此要仿造本地鍵盤發送事件
  /// 最後再由 [_intercept] 此處調用對應的動作
  void sendPerformAction(TextInputAction action) {
    var callbackMethodCall = MethodCall("TextInputClient.performAction",
        [_currentKeyboardController!.client.connectionId, action.toString()]);
    ServicesBinding.instance!.defaultBinaryMessenger.handlePlatformMessage(
      "flutter/textinput",
      _codec.encodeMethodCall(callbackMethodCall),
      (data) {},
    );
  }
}

/// 鍵盤的輸入類型
/// 底層是一個固定的列表可以選擇
/// 例如 - [TextInputType.text] , [TextInputType.multiline] 等等
/// 這邊需要讓我們自訂名稱進行鍵盤的綁定
/// 同時修改原本會使用到 [TextInputType._name] 的地方
class KeyboardInputType extends TextInputType {
  final String name;

  const KeyboardInputType({
    required this.name,
    bool signed = false,
    bool decimal = false,
  }) : super.numberWithOptions(signed: signed, decimal: decimal);

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'signed': signed,
      'decimal': decimal,
    };
  }

  @override
  String toString() {
    return '$runtimeType('
        'name: $name, '
        'signed: $signed, '
        'decimal: $decimal)';
  }
}

/// 鍵盤的對應設定
class KeyboardConfig {
  final double height;
  final KeyboardBuilder builder;

  KeyboardConfig({required this.builder, required this.height});
}

class KeyboardMessageMethod {
  final String _value;

  const KeyboardMessageMethod._internal(this._value);

  String get value => _value;

  /// 鍵盤顯示的消息通知, 在 [setClient] 之後被呼叫
  static const show =
      KeyboardMessageMethod._internal(KeyboardMessageMethod._show);

  /// 鍵盤隱藏消息通知, 在 [clearClient] 之前被呼叫
  static const hide =
      KeyboardMessageMethod._internal(KeyboardMessageMethod._hide);

  /// 輸入狀態改變的消息通知
  static const setEditingState =
      KeyboardMessageMethod._internal(KeyboardMessageMethod._setEditingState);

  /// 鍵盤開啟前通知 native 將鍵盤啟動連線
  static const setClient =
      KeyboardMessageMethod._internal(KeyboardMessageMethod._setClient);

  /// 鍵盤關閉前通知 native 將鍵盤取消連線
  static const clearClient =
      KeyboardMessageMethod._internal(KeyboardMessageMethod._clearClient);

  static const String _show = "TextInput.show";
  static const String _hide = "TextInput.hide";
  static const String _setEditingState = "TextInput.setEditingState";
  static const String _setClient = "TextInput.setClient";
  static const String _clearClient = "TextInput.clearClient";
}
