import 'package:flutter/material.dart';
import 'package:mx_core/ui/widget/k_line_chart/chart_gesture/chart_gesture.dart';
import 'package:mx_core/ui/widget/k_line_chart/chart_gesture/impl/chart_gesture_impl.dart';
import 'package:mx_core/ui/widget/k_line_chart/chart_inertial_scroller/chart_inertial_scroller.dart';
import 'package:mx_core/ui/widget/k_line_chart/model/model.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_painter/chart_painter.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/impl/main_chart/main_chart_color_setting.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/impl/main_chart/main_chart_size_setting.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/impl/main_chart/main_chart_ui_style.dart';

/// k線圖表
class KLineChart extends StatefulWidget {
  /// 圖表資料
  final List<KLineData> datas;

  const KLineChart({
    Key? key,
    required this.datas,
  }) : super(key: key);

  @override
  _KLineChartState createState() => _KLineChartState();
}

class _KLineChartState extends State<KLineChart>
    with SingleTickerProviderStateMixin {
  /// 圖表拖移處理
  late final ChartGesture chartGesture;

  @override
  void initState() {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      lowerBound: double.negativeInfinity,
      upperBound: double.infinity,
    );

    chartGesture = ChartGestureImpl(
      onDrawUpdateNeed: () => setState(() {}),
      chartScroller: ChartInertialScroller(controller: controller),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragDown: chartGesture.onHorizontalDragDown,
      onHorizontalDragUpdate: chartGesture.onHorizontalDragUpdate,
      onHorizontalDragEnd: chartGesture.onHorizontalDragEnd,
      onHorizontalDragCancel: chartGesture.onHorizontalDragCancel,
      onScaleStart: chartGesture.onScaleStart,
      onScaleUpdate: chartGesture.onScaleUpdate,
      onScaleEnd: chartGesture.onScaleEnd,
      onLongPressStart: chartGesture.onLongPressStart,
      onLongPressMoveUpdate: chartGesture.onLongPressMoveUpdate,
      onLongPressEnd: chartGesture.onLongPressEnd,
      child: Stack(
        children: <Widget>[
          CustomPaint(
            size: Size.infinite,
            painter: ChartPainter(
                datas: widget.datas,
                chartGesture: chartGesture,
                chartUiStyle: KLineChartUiStyle(
                  sizeSetting: ChartSizeSetting(),
                  heightRatioSetting: ChartHeightRatioSetting(
                    mainRatio: 0.7,
                    volumeRatio: 0.15,
                    indicatorRatio: 0.15,
                  ),
                  colorSetting: ChartColorSetting(
                    grid: Colors.white10,
                  ),
                ),
                mainState: [
                  MainChartState.kLine,
                  MainChartState.ma,
                ],
                volumeState: VolumeChartState.volume,
                indicatorState: IndicatorChartState.macd,
                mainChartUiStyle: MainChartUiStyle(
                  colorSetting: MainChartColorSetting(
                    background: Colors.black87,
                    maLine: {10: Colors.redAccent},
                    upColor: Colors.green,
                    downColor: Colors.red,
                  ),
                  sizeSetting: MainChartSizeSetting(
                    indexTip: 12,
                  ),
                ),
                maPeriods: [10],
                onMaxScrolled: (value) {
                  chartGesture.setMaxScrollX(value);
                }
                // onCalculateMaxScrolled: (maxScroll) {
                //   maxScrollX = maxScroll;
                //
                //   // 假設 maxScrollX 為 0, 且資料量或者scale與舊有不同時觸發加載更多
                //   if (widget.onDataLessOnePage != null &&
                //       maxScrollX == 0 &&
                //       isDataLenChanged) {
                //     isDataLenChanged = false;
                //     widget.onDataLessOnePage?.call();
                //   }
                // },
                ),
          ),
          // _buildInfoDialog(),
        ],
      ),
    );
  }
}
