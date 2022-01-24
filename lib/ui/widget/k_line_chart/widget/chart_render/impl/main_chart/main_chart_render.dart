import 'package:flutter/material.dart';
import 'package:mx_core/ui/widget/k_line_chart/model/model.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_painter/chart_painter.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/impl/main_chart/main_chart_render_mixin.dart';

import '../../chart_render.dart';

class MainChartRender extends ChartRender with MainChartMixin {
  MainChartRender({
    required DataViewer dataViewer,
  }) : super(dataViewer: dataViewer);

  /// 繪製背景
  @override
  void paintBackground(Canvas canvas, Rect rect) {
    backgroundPaint.color = colors.background;
    canvas.drawRect(rect, backgroundPaint);
  }

  @override
  void paintGrid(Canvas canvas, Rect rect) {
    final chartUiStyle = dataViewer.chartUiStyle;
    gripPaint.color = chartUiStyle.colorSetting.grid;
    final gridRows = chartUiStyle.sizeSetting.gridRows;
    final gridColumns = chartUiStyle.sizeSetting.gridColumns;

    // 每一列的高度/寬度
    final rowHeight = rect.height / gridRows;
    final rowWidth = rect.width / gridColumns;

    final topSpace = chartUiStyle.heightRatioSetting.topSpaceFixed;

    // 畫橫線
    for (int i = 0; i <= gridRows; i++) {
      final y = rowHeight * i + topSpace;
      canvas.drawLine(
        Offset(0, y),
        Offset(rect.width, y),
        gripPaint,
      );
    }

    // 畫直線
    for (int i = 0; i <= gridColumns; i++) {
      final x = rowWidth * i;
      canvas.drawLine(
        Offset(x, topSpace / 3),
        Offset(x, rect.bottom),
        gripPaint,
      );
    }
  }

  /// 繪製最上方的說明文字
  @override
  void paintText(Canvas canvas, Rect rect) {
    final displayData = dataViewer.getLongPressData() ?? dataViewer.datas.last;
    TextSpan? span;
    if (mainState.contains(MainChartState.ma)) {
      final maTextStyle = TextStyle(fontSize: sizes.indexTip);

      span = TextSpan(
        children: dataViewer.maPeriods
            .map((e) {
              final value = displayData.ma[e];
              if (value == null || value == 0) {
                return null;
              }
              return TextSpan(
                text: 'MA$e:$value',
                style: maTextStyle.copyWith(
                  color: colors.maLine[e],
                ),
              );
            })
            .whereType<TextSpan>()
            .toList(),
      );
    }

    if (span == null) return;

    final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(5, rect.top));
  }

  /// 繪製圖表
  @override
  void paintChart(Canvas canvas, Rect rect) {
    for (int i = dataViewer.startDataIndex; i <= dataViewer.endDataIndex; i++) {
      final data = dataViewer.datas[i];
      final x = dataViewer.dataIndexToRealX(i);
      paintCandle(canvas, x, data);
    }
  }
}
