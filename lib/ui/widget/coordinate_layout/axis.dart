part of 'layout.dart';

/// 座標元件
class AxisItem extends StatelessWidget {
  /// 第 x 的位置, null 代表自動
  final int x;

  /// 第 y 個位置, null 代表自動
  final int y;

  /// x 軸跨行數, null 自動帶入1
  final int xSpan;

  /// y 軸跨行數, null 自動帶入1
  final int ySpan;

  final Color color;

  /// 每列高度是否以此為準
  final bool heightBase;

  /// 是否指定位置
  bool get _specialPosition => x != null || y != null;

  final Widget child;

  AxisItem({
    this.child,
    this.color,
    this.x,
    this.y,
    this.xSpan = 1,
    this.ySpan = 1,
    this.heightBase = false,
  });

  /// 比較兩個 item 的位置資訊是否一樣
  bool _isSame(AxisItem other) {
    return this.x == other.x &&
        this.y == other.y &&
        this.xSpan == other.xSpan &&
        this.ySpan == other.ySpan &&
        this.color == other.color &&
        this.heightBase == other.heightBase;
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
    if (x != null && xSpan != null) {
      xInfo = "x - (p: $x, s: $xSpan)";
    } else if (x != null) {
      xInfo = "x - (p: $x)";
    } else if (xSpan != null) {
      xInfo = "x - (s: $xSpan)";
    }
    String yInfo = "";
    if (y != null && ySpan != null) {
      yInfo = "y - (p: $y, s: $ySpan)";
    } else if (y != null) {
      yInfo = "y - (p: $y)";
    } else if (ySpan != null) {
      yInfo = "y - (s: $ySpan)";
    }
    return "$xInfo\n$yInfo";
  }
}
