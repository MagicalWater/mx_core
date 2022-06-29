import 'package:flutter/material.dart';
import 'package:mx_core/extension/list.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_painter/data_viewer.dart';

import '../../wr_chart_render.dart';

import 'wr_chart_render_paint_mixin.dart';
import 'wr_chart_render_value_mixin.dart';

export 'ui_style/wr_chart_ui_style.dart';

class WRChartRenderImpl extends WRChartRender
    with WRChartValueMixin, WRChartRenderPaintMixin {
  WRChartRenderImpl({
    required DataViewer dataViewer,
  }) : super(dataViewer: dataViewer);

  @override
  void paintBackground(Canvas canvas, Rect rect) {
    backgroundPaint.color = colors.background;
    canvas.drawRect(rect, backgroundPaint);
  }

  @override
  void paintChart(Canvas canvas, Rect rect) {
    // 繪製rsi線圖
    paintWRChart(canvas, rect);
  }

  @override
  void paintGrid(Canvas canvas, Rect rect) {
    final chartUiStyle = dataViewer.chartUiStyle;
    gripPaint.color = chartUiStyle.colorSetting.grid;
    final gridColumns = chartUiStyle.sizeSetting.gridColumns;
    final contentWidth = rect.width - chartUiStyle.sizeSetting.rightSpace;
    final columnWidth = contentWidth / gridColumns;
    for (int i = 0; i <= gridColumns; i++) {
      final x = columnWidth * i;
      canvas.drawLine(
        Offset(x, rect.top),
        Offset(x, rect.bottom),
        gripPaint,
      );
    }
  }

  @override
  void paintRightValueText(Canvas canvas, Rect rect) {
    final textStyle = TextStyle(
      color: colors.rightValueText,
      fontSize: sizes.rightValueText,
    );
    final maxValueSpan = TextSpan(
      text: dataViewer.priceFormatter(maxValue),
      style: textStyle,
    );

    // 畫最大值
    final textPainter = TextPainter(
      text: maxValueSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(rect.width - textPainter.width, rect.top),
    );

    // 畫最小值
    final minValueSpan = TextSpan(
      text: dataViewer.priceFormatter(minValue),
      style: textStyle,
    );
    textPainter.text = minValueSpan;
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(rect.width - textPainter.width,
          rect.bottom - textPainter.height - sizes.bottomPadding),
    );
  }

  @override
  void paintTopValueText(Canvas canvas, Rect rect) {
    final displayData = dataViewer.getLongPressData() ?? dataViewer.datas.last;
    final wrData = displayData.indicatorData.wr?.wr;

    if (wrData == null || wrData.isEmpty) {
      return;
    }

    final textStyle = TextStyle(fontSize: sizes.indexTip);

    final spanTexts = <TextSpan>[];

    final wrSpan = dataViewer.indicatorSetting.wrSetting.periods
        .indexMap((e, i) {
          final value = wrData[e];
          if (value == null || value == 0) {
            return null;
          }
          return TextSpan(
            text: 'WR($e):${dataViewer.priceFormatter(value)}  ',
            style: textStyle.copyWith(color: colors.wrLine[i]),
          );
        })
        .whereType<TextSpan>()
        .toList();

    spanTexts.addAll(wrSpan);

    final textPainter = TextPainter(
      text: TextSpan(children: spanTexts),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(5, rect.top));
  }
}
