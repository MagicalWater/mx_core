part of 'impl.dart';

/// 彈窗的控制器
/// 此類無法直接使用, 請使用實作類別
/// [RouteController] - 路由彈窗控制器
/// [OverlayController] - Overlay彈窗控制器
abstract class PopupController<T> {
  /// 彈窗是否需要移除
  bool _isRemoved = false;

  /// 彈窗動畫控制器
  final List<AnimatedCombController> _controllerList = [];

  /// 刪除事件的回調
  final List<VoidCallback> _removeEventOnStartCallbackList = [];

  /// 刪除事件的回調
  final List<VoidCallback> _removeEventOnEndCallbackList = [];

  /// 刪除彈窗的處理方法
  void Function(T ins)? _removeHandler;

  bool get isRemoved => _isRemoved;

  /// 註冊動畫控制器
  void registerController(AnimatedCombController controller) {
    if (_isRemoved) {
      for (var e in _controllerList) {
        e.toggle();
      }
      _controllerList.clear();
    } else {
      _controllerList.add(controller);
    }
  }

  /// 註冊彈窗移除事件回調
  void registerRemoveEventCallback({
    VoidCallback? onStart,
    VoidCallback? onEnd,
  }) {
    if (onStart != null && !_removeEventOnStartCallbackList.contains(onStart)) {
      _removeEventOnStartCallbackList.add(onStart);
    }

    if (onEnd != null && !_removeEventOnEndCallbackList.contains(onEnd)) {
      _removeEventOnEndCallbackList.add(onEnd);
    }
  }

  /// 設置彈窗移除的方法
  void setRemoveHandler(void Function(T ins) handler) {
    _removeHandler = handler;
  }

  /// 取消註冊彈窗移除事件
  /// [onStart] - 彈窗開始動畫離屏的事件回傳
  /// [onEnd] - 彈窗移除後的事件回傳
  void unregisterRemoveEventCallback({
    VoidCallback? onStart,
    VoidCallback? onEnd,
  }) {
    if (onStart != null && _removeEventOnStartCallbackList.contains(onStart)) {
      _removeEventOnStartCallbackList.remove(onStart);
    }

    if (onEnd != null && _removeEventOnEndCallbackList.contains(onEnd)) {
      _removeEventOnEndCallbackList.remove(onEnd);
    }
  }

  /// 彈窗開始動畫離屏
  void _sendRemoveEventOnStart() {
    for (var e in _removeEventOnStartCallbackList) {
      e();
    }
    _removeEventOnStartCallbackList.clear();
  }

  /// 彈窗移除完畢
  void _sendRemoveEventOnEnd() {
    for (var e in _removeEventOnEndCallbackList) {
      e();
    }
    _removeEventOnEndCallbackList.clear();
  }

  /// 移除彈窗
  @mustCallSuper
  Future<void> remove() async {
    if (_isRemoved) {
      print("此元件已經 remove, 不需要再次 remove");
      return;
    }
    _isRemoved = true;

    _sendRemoveEventOnStart();

    await Future.wait(_controllerList.map((e) {
      var toggle = e.toggle(false);
      return toggle;
    }));
    _controllerList.clear();
    _allShowPopup.remove(this);
  }
}

/// 路由彈窗控制器
class RouteController extends PopupController<NavigatorState> {
  RouteController();

  /// 移除彈窗
  @override
  Future<void> remove() async {
    var needRemove = !_isRemoved;
    await super.remove();
    if (!needRemove) {
      return;
    }
    _handleRemove();
    _sendRemoveEventOnEnd();
  }

  /// 處理頁面實體移除
  void _handleRemove() {
    if (_removeHandler != null) {
      _removeHandler?.call(navigatorIns);
    } else {
      navigatorIns.pop();
    }
  }
}

/// Overlay彈窗控制器
class OverlayController extends PopupController<OverlayEntry?> {
  OverlayEntry? _entry;

  /// 註冊返回按鈕事件監聽的tag
  final String tag;

  /// 是否已經註冊了返回按鈕事件監聽
  bool _isRegisterBackButtonListener = false;

  OverlayController() : tag = _getUniqueTag();

  void setEntry(OverlayEntry entry) {
    _entry = entry;
  }

  /// 註冊返回按鍵監聽
  void registerBackButtonListener(VoidCallback callback) {
    if (_isRegisterBackButtonListener || _isRemoved) return;
    _isRegisterBackButtonListener = true;
    BackButtonInterceptor.add(
      (bool stopDefaultButtonEvent, RouteInfo routeInfo) {
        callback();
        return true;
      },
      zIndex: 1,
      name: tag,
    );
  }

  void unregisterBackButtonListener() {
    _isRegisterBackButtonListener = false;
    BackButtonInterceptor.removeByName(tag);
  }

  /// 移除loading
  @override
  Future<void> remove() async {
    var needRemove = !_isRemoved;
    unregisterBackButtonListener();
    await super.remove();
    if (!needRemove) {
      return;
    }
    _handleRemove();
    _sendRemoveEventOnEnd();
  }

  /// 處理頁面實體移除
  void _handleRemove() {
    if (_removeHandler != null) {
      _removeHandler?.call(_entry);
    } else {
      _entry?.remove();
    }
  }
}

/// 取得一個不重複的tag
String _getUniqueTag() {
  return 'Popup-${_uniqueNumber++}';
}

int _uniqueNumber = 0;
