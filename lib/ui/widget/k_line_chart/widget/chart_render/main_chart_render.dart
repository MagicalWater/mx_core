import 'dart:ui';

import 'package:mx_core/ui/widget/k_line_chart/widget/chart_painter/data_viewer.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/chart_render.dart';

import 'chart_component_render.dart';

export 'impl/main_chart/main_chart_render_impl.dart';

abstract class MainChartRender extends ChartRender
    implements ChartComponentRender {
  /// 最右側實時價格的位置
  /// 若處於不可見狀態, 則[localPosition]為null
  final void Function(Offset? localPosition)? rightRealPriceOffset;

  MainChartRender({
    required DataViewer dataViewer,
    this.rightRealPriceOffset,
  }) : super(dataViewer: dataViewer);

  @override
  void paint(Canvas canvas, Rect rect) {
    final sizes = dataViewer.mainChartUiStyle.sizeSetting;
    initValue(rect);
    paintBackground(canvas, rect);
    paintGrid(canvas, rect);
    paintTopValueText(canvas, rect);
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(
      rect.left,
      rect.top + sizes.topPadding,
      rect.right,
      rect.bottom - sizes.bottomPadding,
    ));
    paintChart(canvas, rect);
    canvas.restore();
    paintRightValueText(canvas, rect);
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
