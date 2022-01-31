import 'package:mx_core/ui/widget/k_line_chart/widget/chart_painter/chart_painter.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/chart_render.dart';

export 'impl/wr_chart/wr_chart_render_impl.dart';

abstract class WRChartRender extends ChartRender {
  WRChartRender({
    required DataViewer dataViewer,
  }) : super(dataViewer: dataViewer);
}
