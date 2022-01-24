import 'dart:ui';

import 'package:mx_core/ui/widget/k_line_chart/widget/chart_painter/chart_painter.dart';

abstract class ChartRender {
  final DataViewer dataViewer;

  ChartRender({
    required this.dataViewer,
  });

  /// 在此初始化並暫存所有數值
  void initValue(Rect rect);

  /// 繪製背景
  void paintBackground(Canvas canvas, Rect rect);

  /// 繪製格線
  void paintGrid(Canvas canvas, Rect rect);

  /// 繪製最上方的說明文字
  void paintText(Canvas canvas, Rect rect);

  /// 繪製圖表
  void paintChart(Canvas canvas, Rect rect);
}
