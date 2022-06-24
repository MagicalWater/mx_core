import 'dart:ui';

import 'package:mx_core/ui/widget/k_line_chart/widget/chart_painter/data_viewer.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/chart_render.dart';

import '../../k_line_chart.dart';
import 'chart_component_render.dart';

export 'impl/main_chart/main_chart_render_impl.dart';

abstract class MainChartRender extends ChartRender
    implements ChartComponentRender {
  /// 價格標示y軸位置獲取
  final PricePositionGetter? pricePositionGetter;

  MainChartRender({
    required DataViewer dataViewer,
    this.pricePositionGetter,
  }) : super(dataViewer: dataViewer);

  @override
  void paint(Canvas canvas, Rect rect) {
    final sizes = dataViewer.mainChartUiStyle.sizeSetting;
    initValue(rect);
    paintBackground(canvas, rect);
    paintGrid(canvas, rect);
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(
      rect.left,
      rect.top + sizes.topPadding,
      rect.right - dataViewer.chartUiStyle.sizeSetting.rightSpace,
      rect.bottom - sizes.bottomPadding,
    ));
    paintChart(canvas, rect);
    canvas.restore();
    paintRightValueText(canvas, rect);
    if (dataViewer.datas.isEmpty) {
      return;
    }
    paintTopValueText(canvas, rect);
    paintMaxMinValue(canvas, rect);
    paintRealTimeLine(canvas, rect);
    paintLongPressHorizontalLineAndValue(canvas, rect);
    paintLongPressHorizontalLineAndValue(canvas, rect);
  }

  /// 繪製實時線
  void paintRealTimeLine(Canvas canvas, Rect rect);

  /// 繪製最大值與最小值
  void paintMaxMinValue(Canvas canvas, Rect rect);

  /// 繪製長按橫線與數值
  void paintLongPressHorizontalLineAndValue(Canvas canvas, Rect rect);
}
