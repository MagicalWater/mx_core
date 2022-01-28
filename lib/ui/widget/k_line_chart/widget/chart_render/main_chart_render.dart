import 'dart:ui';

import 'package:mx_core/ui/widget/k_line_chart/widget/chart_painter/chart_painter.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/chart_render.dart';

export 'impl/main_chart/main_chart_render_impl.dart';

abstract class MainChartRender extends ChartRender {
  MainChartRender({
    required DataViewer dataViewer,
  }) : super(dataViewer: dataViewer);

  /// 繪製實時線
  void paintRealTimeLine(Canvas canvas, Rect rect);

  /// 繪製最大值與最小值
  void paintMaxMinValue(Canvas canvas, Rect rect);

  /// 繪製長按橫線與數值
  void paintLongPressHorizontalLineAndValue(Canvas canvas, Rect rect);
}
