part of 'impl.dart';

/// 彈窗的控制器
/// 此類無法直接使用, 請使用實作類別
/// [RouteController] - 路由彈窗控制器
/// [OverlayController] - Overlay彈窗控制器
abstract class PopupController {
  /// 彈窗是否需要移除
  bool _isRemoved = false;

  /// 彈窗動畫控制器
  List<AnimatedCombController> _controllerList = [];

  /// 刪除事件的回調
  List<VoidCallback> _removeEventCallbackList = [];

  bool get isRemoved => _isRemoved;

  /// 註冊動畫控制器
  void registerController(AnimatedCombController controller) {
    if (_isRemoved) {
      _controllerList.forEach((e) => e.toggle());
      _controllerList.clear();
    } else {
      _controllerList.add(controller);
    }
  }

  /// 註冊彈窗移除事件回調
  void registerRemoveEventCallback(VoidCallback callback) {
    if (!_removeEventCallbackList.contains(callback)) {
      _removeEventCallbackList.add(callback);
    }
  }

  /// 移除彈窗
  @mustCallSuper
  Future<void> remove() async {
    if (_isRemoved) {
      print("此元件已經 remove, 不需要再次 remove");
      return;
    }
    _isRemoved = true;

    _removeEventCallbackList.forEach((e) {
      e();
    });
    _removeEventCallbackList.clear();

    await Future.wait(_controllerList.map((e) {
      var toggle = e.toggle(false);
      return toggle;
    }));
    _controllerList.clear();
    _allShowPopup.remove(this);
  }
}

/// 路由彈窗控制器
class RouteController extends PopupController {
  RouteController();

  /// 移除彈窗
  @override
  Future<void> remove() async {
    var needRemove = !_isRemoved;
    await super.remove();
    if (needRemove) {
      navigatorIns.pop();
    }
  }
}

/// Overlay彈窗控制器
class OverlayController extends PopupController {
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
    _entry?.remove();
    _entry = null;
  }
}

/// 取得一個不重複的tag
String _getUniqueTag() {
  return 'Popup-${_uniqueNumber++}';
}

int _uniqueNumber = 0;
