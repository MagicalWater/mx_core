import 'dart:ui';

import 'package:mx_core/ui/widget/k_line_chart/widget/chart_painter/data_viewer.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/chart_component_render.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/chart_render.dart';

export 'impl/kdj_chart/kdj_chart_render_impl.dart';

abstract class KDJChartRender extends ChartRender implements ChartComponentRender {
  KDJChartRender({
    required DataViewer dataViewer,
  }) : super(dataViewer: dataViewer);

  @override
  void paint(Canvas canvas, Rect rect) {
    initValue(rect);
    paintBackground(canvas, rect);
    paintGrid(canvas, rect);
    paintChart(canvas, rect);
    paintRightValueText(canvas, rect);
    if (dataViewer.datas.isEmpty) {
      return;
    }
    paintTopValueText(canvas, rect);
  }
}
