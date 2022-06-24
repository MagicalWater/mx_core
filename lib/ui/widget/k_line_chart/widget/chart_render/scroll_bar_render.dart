import 'dart:ui';

import 'package:mx_core/ui/widget/k_line_chart/widget/chart_painter/data_viewer.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/chart_component_render.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/chart_render.dart';

export 'impl/scroll_bar_background/scroll_bar_background_render_impl.dart';

/// 拖拉bar的背景渲染
abstract class ScrollBarBackgroundRender extends ChartRender
    implements ChartComponentRender {
  ScrollBarBackgroundRender({
    required DataViewer dataViewer,
  }) : super(dataViewer: dataViewer);

  @override
  void paint(Canvas canvas, Rect rect) {
    paintBackground(canvas, rect);
    paintGrid(canvas, rect);
  }
}
