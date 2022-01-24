import 'dart:ui';

/// 主圖表的顏色設定檔
class MainChartColorSetting {
  /// 背景顏色
  final Color background;

  /// ma各週期顏色
  /// key代表週期
  final Map<int, Color> maLine;


  /// 漲價/跌價顏色
  final Color upColor;
  final Color downColor;

  MainChartColorSetting({
    required this.background,
    required this.maLine,
    required this.upColor,
    required this.downColor,
  });
}