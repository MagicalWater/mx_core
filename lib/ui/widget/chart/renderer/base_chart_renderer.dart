import 'package:flutter/material.dart';
import 'package:mx_core/ui/widget/chart/utils/number_util.dart';

import '../chart_style.dart';

export '../chart_style.dart';

abstract class BaseChartRenderer<T> {
  double maxValue, minValue;
  double scaleY, scaleX;
  double topPadding;
  Rect chartRect;

  MainChartStyle style;

  final Paint chartPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..strokeWidth = 1.0
    ..color = Colors.red;
  final Paint gridPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..strokeWidth = 0.5;

  BaseChartRenderer({
    @required this.chartRect,
    @required this.maxValue,
    @required this.minValue,
    @required this.topPadding,
    @required this.scaleX,
    @required this.style,
  }) {
    gridPaint.color = style.gridColor;
    if (maxValue == minValue) {
      maxValue += 0.5;
      minValue -= 0.5;
    }
    scaleY = chartRect.height / (maxValue - minValue);
  }

  double getY(double y) => (maxValue - y) * scaleY + chartRect.top;

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
