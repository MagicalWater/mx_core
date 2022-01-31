import 'package:mx_core/ui/widget/k_line_chart/widget/chart_painter/chart_painter.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/chart_render.dart';

export 'impl/kdj_chart/kdj_chart_render_impl.dart';

abstract class KDJChartRender extends ChartRender {
  KDJChartRender({
    required DataViewer dataViewer,
  }) : super(dataViewer: dataViewer);
}
