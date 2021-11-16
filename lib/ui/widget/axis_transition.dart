import 'package:flutter/widgets.dart';

/// 位移動畫元件
/// <p> 在 [AnimatedSwitcher] 動畫執行反向動畫時 </p>
/// <p> 預設將會以和入場相反的方向退出 </p>
class AxisTransition extends AnimatedWidget {
  /// 有效點擊的區塊是否會隨著動畫的移動而改變
  final bool transformHitTests;

  final Widget child;

  /// 動畫進場方向
  final TransDirection slideIn;

  /// 動畫退場方向
  final TransDirection slideOut;

  /// 傳入 AnimatedSwitcher 的 animation
  final Animation<double> position;

  /// 動畫偏移計算
  final Tween<Offset> _tween;

  const AxisTransition._(
    this._tween, {
    Key? key,
    required this.position,
    required this.child,
    this.transformHitTests = true,
    this.slideIn = TransDirection.left,
    this.slideOut = TransDirection.left,
  }) : super(key: key, listenable: position);

  factory AxisTransition({
    Key? key,
    required Animation<double> position,
    required Widget child,
    bool transformHitTests = true,
    TransDirection slideIn = TransDirection.left,
    TransDirection? slideOut,
  }) {
    slideOut ??= _getReverseDirection(slideIn);
    var tween = _getInTween(slideIn);
    return AxisTransition._(
      tween,
      key: key,
      position: position,
      child: child,
      transformHitTests: transformHitTests,
      slideIn: slideIn,
      slideOut: slideOut,
    );
  }

  /// 從 入場 offset 取得位移進度
  double _getProgressFromReverseOffset(Offset offset) {
    switch (slideIn) {
      case TransDirection.up:
        return -offset.dy;
      case TransDirection.right:
        return offset.dx;
      case TransDirection.down:
        return offset.dy;
      case TransDirection.left:
        return -offset.dx;
      default:
        throw '未知的方向: $slideIn';
    }
  }

  @override
  Widget build(BuildContext context) {
    Offset offset = _tween.evaluate(position);
    if (position.status == AnimationStatus.reverse) {
      double progress = _getProgressFromReverseOffset(offset);
//      print("打印 反向 offset = $offset, pro = $progress");
      switch (slideOut) {
        case TransDirection.up:
          offset = Offset(0, -progress);
          break;
        case TransDirection.right:
          offset = Offset(progress, 0);
          break;
        case TransDirection.down:
          offset = Offset(0, progress);
          break;
        case TransDirection.left:
          offset = Offset(-progress, 0);
          break;
        case TransDirection.none:
          offset = Offset(0, 0);
          break;
      }
    } else {
//      print("打印 正向 offset = $offset");
    }
    return FractionalTranslation(
      translation: offset,
      transformHitTests: true,
      child: child,
    );
  }
}

TransDirection _getReverseDirection(TransDirection direction) {
  switch (direction) {
    case TransDirection.up:
      return TransDirection.down;
    case TransDirection.right:
      return TransDirection.left;
    case TransDirection.down:
      return TransDirection.up;
    case TransDirection.left:
      return TransDirection.right;
    case TransDirection.none:
      return TransDirection.none;
    default:
      throw '未知的方向: $direction';
  }
}

Tween<Offset> _getInTween(TransDirection direction) {
  switch (direction) {
    case TransDirection.up:
      return Tween(begin: const Offset(0, -1), end: const Offset(0, 0));
    case TransDirection.right:
      return Tween(begin: const Offset(1, 0), end: const Offset(0, 0));
    case TransDirection.down:
      return Tween(begin: const Offset(0, 1), end: const Offset(0, 0));
    case TransDirection.left:
      return Tween(begin: const Offset(-1, 0), end: const Offset(0, 0));
    case TransDirection.none:
      return Tween(begin: const Offset(0, 0), end: const Offset(0, 0));
    default:
      throw '未知的方向: $direction';
  }
}

enum TransDirection {
  up,
  right,
  down,
  left,
  none,
}
