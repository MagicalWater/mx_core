import 'package:flutter/material.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_painter/data_viewer.dart';
import '../../kdj_chart_render.dart';

import 'kdj_chart_render_paint_mixin.dart';
import 'kdj_chart_render_value_mixin.dart';

export 'ui_style/kdj_chart_ui_style.dart';

class KDJChartRenderImpl extends KDJChartRender
    with KDJChartValueMixin, KDJChartRenderPaintMixin {
  KDJChartRenderImpl({
    required DataViewer dataViewer,
  }) : super(dataViewer: dataViewer);

  @override
  void paintBackground(Canvas canvas, Rect rect) {
    backgroundPaint.color = colors.background;
    canvas.drawRect(rect, backgroundPaint);
  }

  @override
  void paintChart(Canvas canvas, Rect rect) {
    // 繪製k/d/j線圖
    paintKDJChart(canvas, rect);
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
    final kdjData = displayData.indciatorData.kdj;

    if (kdjData == null) {
      return;
    }

    final textStyle = TextStyle(fontSize: sizes.indexTip);

    final spans = <TextSpan>[
      TextSpan(
        text: "KDJ(14,1,3)    ",
        style: textStyle.copyWith(color: colors.kdjTip),
      ),
      if (kdjData.k != 0)
        TextSpan(
          text: "K:${dataViewer.priceFormatter(kdjData.k)}    ",
          style: textStyle.copyWith(color: colors.kColor),
        ),
      if (kdjData.d != 0)
        TextSpan(
          text: "D:${dataViewer.priceFormatter(kdjData.d)}    ",
          style: textStyle.copyWith(color: colors.dColor),
        ),
      if (kdjData.k != 0)
        TextSpan(
          text: "J:${dataViewer.priceFormatter(kdjData.j)}    ",
          style: textStyle.copyWith(color: colors.jColor),
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
