part of 'layout.dart';

/// 座標元件
class AxisItem extends StatelessWidget {
  /// 第 x 的位置, null 代表自動
  final int? x;

  /// 第 y 個位置, null 代表自動
  final int? y;

  /// x 軸跨行數
  final int xSpan;

  /// y 軸跨行數
  final int ySpan;

  final Color? color;

  /// 每列高度是否以此為準
  final bool heightBase;

  /// 是否指定位置
  bool get _specialPosition => x != null || y != null;

  final Widget? child;

  const AxisItem({
    Key? key,
    this.child,
    this.color,
    this.x,
    this.y,
    this.xSpan = 1,
    this.ySpan = 1,
    this.heightBase = false,
  }) : super(key: key);

  const AxisItem._inAutoSpace({
    required this.xSpan,
    required this.ySpan,
  })  : child = null,
        color = null,
        heightBase = false,
        x = null,
        y = null;

  /// 比較兩個 item 的位置資訊是否一樣
  bool _isSame(AxisItem other) {
    return x == other.x &&
        y == other.y &&
        xSpan == other.xSpan &&
        ySpan == other.ySpan &&
        color == other.color &&
        heightBase == other.heightBase;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: child,
    );
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    String xInfo = "";
    if (x != null) {
      xInfo = "x - (p: $x, s: $xSpan)";
    } else {
      xInfo = "x - (s: $xSpan)";
    }
    String yInfo = "";
    if (y != null) {
      yInfo = "y - (p: $y, s: $ySpan)";
    } else {
      yInfo = "y - (s: $ySpan)";
    }
    return "$xInfo\n$yInfo";
  }
}
