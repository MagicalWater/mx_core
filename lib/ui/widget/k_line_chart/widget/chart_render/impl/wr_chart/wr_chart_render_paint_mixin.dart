import 'dart:math';

import 'package:flutter/material.dart';

import 'wr_chart_render_value_mixin.dart';

mixin WRChartRenderPaintMixin on WRChartValueMixin {
  /// 繪製dif/dea線
  void paintWRChart(Canvas canvas, Rect rect) {
    linePaint.strokeWidth = sizes.lineWidth;

    final wrData = dataViewer.datas.map((e) => e.indicatorData.wr);

    // 繪rsi線
    final rList = wrData.map((e) => e?.r).toList();
    final rPath = _getDisplayLinePath(rList, curve: false);
    linePaint.color = colors.rColor;
    canvas.drawPath(rPath, linePaint);
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
