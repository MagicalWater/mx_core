import 'dart:ui';

/// 主圖表的尺寸相關設定
class MainChartSizeSetting {
  /// 左上角的各指標提示
  final double indexTip;

  /// 折線圖寬度
  final double lineWidth;

  /// 圖表右側的數值文字
  final double rightValueText;

  /// 實時數值
  final double realTimeLineValue;

  /// k線圖的蠟燭寬度
  final double candleWidth;

  /// 蠟燭中間的豎線寬度
  final double candleLineWidth;

  /// 實時線的虛線寬度
  final double realTimeDashWidth;

  /// 實時線的虛線空隙
  final double realTimeDashSpace;

  /// 全局實時線的標示padding
  final double realTimeTagVerticalPadding;
  final double realTimeTagHorizontalPadding;

  /// 全局實時線的三角形標示size
  final Size realTimeTagTriangle;

  /// 最小值/最大值
  final double minValueText;
  final double maxValueText;

  /// 圖表上方/下方padding
  final double topPadding;
  final double bottomPadding;

  const MainChartSizeSetting({
    this.indexTip = 12,
    this.lineWidth = 1.3,
    this.candleWidth = 7,
    this.candleLineWidth = 1.3,
    this.rightValueText = 10,
    this.realTimeLineValue = 10,
    this.realTimeDashWidth = 10,
    this.realTimeDashSpace = 5,
    this.realTimeTagVerticalPadding = 3,
    this.realTimeTagHorizontalPadding = 6,
    this.realTimeTagTriangle = const Size(5, 8),
    this.minValueText = 10,
    this.maxValueText = 10,
    this.topPadding = 30,
    this.bottomPadding = 10,
  });
}
