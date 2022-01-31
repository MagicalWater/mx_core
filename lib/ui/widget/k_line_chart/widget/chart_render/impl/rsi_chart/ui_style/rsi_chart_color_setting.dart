import 'dart:ui';

/// 買賣圖表的顏色設定檔
class RSIChartColorSetting {
  /// 背景顏色
  final Color background;

  /// RSI顏色
  final Color rsiColor;

  /// 右側數值顏色
  final Color rightValueText;

  const RSIChartColorSetting({
    this.background = const Color(0xff1e2129),
    this.rsiColor = const Color(0xffb47731),
    this.rightValueText = const Color(0xff60738E),
  });
}
