import 'dart:ui';

/// 買賣圖表的顏色設定檔
class WRChartColorSetting {
  /// 背景顏色
  final Color background;

  /// R顏色
  final Color rColor;

  /// 右側數值顏色
  final Color rightValueText;

  const WRChartColorSetting({
    this.background = const Color(0xff1e2129),
    this.rColor = const Color(0xffb47731),
    this.rightValueText = const Color(0xff60738E),
  });
}
