import 'package:flutter/material.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_painter/chart_painter.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/chart_render.dart';

import 'macd_chart_render_paint_mixin.dart';
import 'macd_chart_render_value_mixin.dart';

export 'ui_style/macd_chart_ui_style.dart';

class MACDChartRenderImpl extends ChartRender
    with MACDChartValueMixin, MACDChartRenderPaintMixin {
  MACDChartRenderImpl({
    required DataViewer dataViewer,
  }) : super(dataViewer: dataViewer);

  @override
  void paintBackground(Canvas canvas, Rect rect) {
    backgroundPaint.color = colors.background;
    canvas.drawRect(rect, backgroundPaint);
  }

  @override
  void paintChart(Canvas canvas, Rect rect) {
    // 繪製長柱圖
    paintBarChart(canvas, rect);

    // 繪製dif/dea線圖
    paintDifDeaChart(canvas, rect);
  }

  @override
  void paintGrid(Canvas canvas, Rect rect) {
    final chartUiStyle = dataViewer.chartUiStyle;
    gripPaint.color = chartUiStyle.colorSetting.grid;
    final gridColumns = chartUiStyle.sizeSetting.gridColumns;
    final columnSpace = rect.width / gridColumns;
    for (int i = 0; i <= gridColumns; i++) {
      final x = columnSpace * i;
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
      text: dataViewer.formateVolume(maxValue),
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
      text: dataViewer.formateVolume(minValue),
      style: textStyle,
    );
    textPainter.text = minValueSpan;
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(rect.width - textPainter.width, rect.bottom - textPainter.height - sizes.bottomPadding),
    );
  }

  @override
  void paintTopValueText(Canvas canvas, Rect rect) {
    final displayData = dataViewer.getLongPressData() ?? dataViewer.datas.last;
    final macdData = displayData.indciatorData.macd;

    if (macdData == null) {
      return;
    }

    final textStyle = TextStyle(fontSize: sizes.indexTip);

    final spans = <TextSpan>[
      TextSpan(
        text: 'MACD(12,26,9)    ',
        style: textStyle.copyWith(color: colors.statisticsTip),
      ),
      TextSpan(
        text: 'MACD:${dataViewer.formatPrice(macdData.macd)}    ',
        style: textStyle.copyWith(color: colors.macdTip),
      ),
      TextSpan(
        text: 'DIF:${dataViewer.formatPrice(macdData.dif)}    ',
        style: textStyle.copyWith(color: colors.difColor),
      ),
      TextSpan(
        text: 'DEA:${dataViewer.formatPrice(macdData.dea)}    ',
        style: textStyle.copyWith(color: colors.deaColor),
      ),
    ];

    final textPainter = TextPainter(
      text: TextSpan(children: spans),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(5, rect.top));
  }
}