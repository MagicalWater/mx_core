part of 'impl.dart';

/// 浮出視窗, 實現原理同樣是 Overlay, 在這邊藉由 route 達成效果
/// 參考: https://www.coderblog.in/2019/04/how-to-create-popup-window-in-flutter/
/// 修改者: Water
class _PopupLayout extends ModalRoute {
  final Widget child;

  _PopupLayout({
    required this.child,
  });

  /// 背景顏色
  @override
  Color get barrierColor => Color(0x00ffffff);

  /// 尚不明白這個是什麼
  @override
  bool get barrierDismissible => false;

  /// 尚不明白這個是什麼
  @override
  String? get barrierLabel => null;

  /// 當此 route(浮出視窗處於非活動狀態時, 是否需要保留在內存中)
  @override
  bool get maintainState => false;

  /// 此 route 是否遮蓋了先前的 route
  /// 若是, 則此之前的路由將不構建來節省資源
  @override
  bool get opaque => false;

  /// 過度動畫時間
  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return child;
  }
}
