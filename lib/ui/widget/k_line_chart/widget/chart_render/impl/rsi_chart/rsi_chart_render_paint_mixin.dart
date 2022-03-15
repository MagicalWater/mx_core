import 'dart:math';

import 'package:flutter/material.dart';

import 'rsi_chart_render_value_mixin.dart';

mixin RSIChartRenderPaintMixin on RSIChartValueMixin {
  /// 繪製dif/dea線
  void paintRSIChart(Canvas canvas, Rect rect) {
    linePaint.strokeWidth = sizes.lineWidth;

    final rsiData = dataViewer.datas.map((e) => e.indicatorData.rsi);

    // 繪rsi線
    final rsiList = rsiData.map((e) => e?.rsi).toList();
    final rsiPath = _getDisplayLinePath(rsiList, curve: false);
    linePaint.color = colors.rsiColor;
    canvas.drawPath(rsiPath, linePaint);
  }

  /// 取得顯示在螢幕上的路線Path
  /// [curve] - 是否使用曲線
  Path _getDisplayLinePath(List<double?> values, {bool curve = true}) {
    final linePath = Path();

    double? preValue;
    double? preX, preY;

    final startIndex = max(0, dataViewer.startDataIndex - 1);
    final endIndex = min(
      values.length - 1,
      dataViewer.endDataIndex + 1,
    );

    // 畫折線
    for (int i = startIndex; i <= endIndex; i++) {
      final value = values[i];
      if (value == null) {
        continue;
      }
      final x = dataViewer.dataIndexToRealX(i);
      final y = valueToRealY(value);

      if (preValue == null) {
        linePath.moveTo(x, y);
      } else {
        final centerX = (preX! + x) / 2;
        if (curve) {
          linePath.cubicTo(centerX, preY!, centerX, y, x, y);
        } else {
          linePath.lineTo(x, y);
        }
      }

      preX = x;
      preY = y;
      preValue = value;
    }

    return linePath;
  }
}
