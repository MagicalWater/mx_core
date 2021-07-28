import 'package:flutter/material.dart';

import '../chart_style.dart';
import '../utils/number_util.dart';

export '../chart_style.dart';

abstract class BaseChartRenderer<T> {
  double maxValue;

  // double get maxValue => _maxValue;
  double minValue;
  double scaleX;
  late double scaleY;
  double topPadding;
  Rect chartRect;

  MainChartStyle style;

  final Paint chartPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..strokeWidth = 0.5
    ..color = Colors.red;

  final Paint gridPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..strokeWidth = 0.5;

  final bool showLog;

  BaseChartRenderer({
    required this.chartRect,
    required this.maxValue,
    required this.minValue,
    required this.topPadding,
    required this.scaleX,
    required this.style,
    this.showLog = false,
  }) {
    gridPaint.color = style.gridColor;
    translateMinMax();
    scaleY = chartRect.height / (maxValue - minValue);
  }

  /// 計算最大最小值是否需要調整偏移
  void translateMinMax() {
    if (maxValue == minValue) {
      // 當最大最小相同時, 代表為唯一價
      // 但圖表為一整面, 需要給予上下界
      maxValue += 0.5;
      minValue -= 0.5;
    }
  }

  /// 帶入數值, 取得對應的y軸
  double getY(double y) => (maxValue - y) * scaleY + chartRect.top;

  /// 帶入y軸, 取得對應的數值
  double getValue(double y) {
    // return y / scaleY + minValue;
    return maxValue - ((y - chartRect.top) / scaleY);
  }

  String format(double n) {
    return NumberUtil.format(n);
  }

  void drawGrid(Canvas canvas, int gridRows, int gridColumns);

  void drawText(Canvas canvas, T data, double x);

  void drawRightText(canvas, textStyle, int gridRows);

  void drawChart(T lastPoint, T curPoint, double lastX, double curX, Size size,
      Canvas canvas);

  void drawLine(double lastPrice, double curPrice, Canvas canvas, double lastX,
      double curX, Color color) {
    double lastY = getY(lastPrice);
    double curY = getY(curPrice);
    canvas.drawLine(
        Offset(lastX, lastY), Offset(curX, curY), chartPaint..color = color);
  }

  TextStyle getTextStyle(Color color) {
    return TextStyle(fontSize: ChartStyle.defaultTextSize, color: color);
  }
}
