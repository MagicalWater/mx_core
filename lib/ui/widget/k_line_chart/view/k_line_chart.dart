import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core/route_page/page_route_mixin.dart';
import 'package:mx_core/ui/widget/k_line_chart/chart_gesture/chart_gesture.dart';
import 'package:mx_core/ui/widget/k_line_chart/chart_gesture/impl/chart_gesture_impl.dart';
import 'package:mx_core/ui/widget/k_line_chart/chart_inertial_scroller/chart_inertial_scroller.dart';
import 'package:mx_core/ui/widget/k_line_chart/model/model.dart';
import 'package:mx_core/ui/widget/k_line_chart/multi_touch_gesture_recognizer/multi_touch_gesture_recognizer.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_painter/chart_painter.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/impl/kdj_chart/ui_style/kdj_chart_ui_style.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/impl/macd_chart/macd_chart_render_impl.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/impl/main_chart/ui_style/main_chart_ui_style.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/impl/rsi_chart/ui_style/rsi_chart_ui_style.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/impl/wr_chart/ui_style/wr_chart_ui_style.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/volume_chart_render.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/k_line_data_tooltip/k_line_data_tooltip.dart';

/// 長按tooltip構建
typedef KLineChartTooltipBuilder = KLineDataInfoTooltip Function(
  BuildContext context,
  LongPressData data,
);

/// k線圖表
class KLineChart extends StatefulWidget {
  /// 圖表資料
  final List<KLineData> datas;

  /// 總ui
  final KLineChartUiStyle chartUiStyle;

  /// 主圖表的ui
  final MainChartUiStyle mainChartUiStyle;

  /// 成交量圖表的ui
  final VolumeChartUiStyle volumeChartUiStyle;

  /// macd技術線的ui
  final MACDChartUiStyle macdChartUiStyle;

  /// rsi技術線的ui
  final RSIChartUiStyle rsiChartUiStyle;

  /// wr技術線的ui
  final WRChartUiStyle wrChartUiStyle;

  /// kdj技術線的ui
  final KDJChartUiStyle kdjChartUiStyle;

  /// 主圖表顯示
  final List<MainChartState> mainChartState;

  /// 成交量圖表顯示
  final VolumeChartState volumeChartState;

  /// 技術分析圖表顯示
  final IndicatorChartState indicatorChartState;

  /// ma週期
  final List<int> maPeriods;

  /// x軸時間格式化
  final String xAxisDateFormat;

  /// tooltip彈窗構建
  final KLineChartTooltipBuilder? tooltipBuilder;

  /// 加載更多調用, false代表滑動到最左邊, true則為最右邊
  final Function(bool right)? onLoadMore;

  const KLineChart({
    Key? key,
    required this.datas,
    this.mainChartState = const [MainChartState.kLine, MainChartState.ma],
    this.volumeChartState = VolumeChartState.volume,
    this.indicatorChartState = IndicatorChartState.kdj,
    this.chartUiStyle = const KLineChartUiStyle(),
    this.mainChartUiStyle = const MainChartUiStyle(),
    this.volumeChartUiStyle = const VolumeChartUiStyle(),
    this.macdChartUiStyle = const MACDChartUiStyle(),
    this.rsiChartUiStyle = const RSIChartUiStyle(),
    this.wrChartUiStyle = const WRChartUiStyle(),
    this.kdjChartUiStyle = const KDJChartUiStyle(),
    this.maPeriods = const [5, 10, 20],
    this.xAxisDateFormat = 'MM-dd mm:ss',
    this.tooltipBuilder = _defaultTooltip,
    this.onLoadMore,
  }) : super(key: key);

  /// 預設tooltip彈窗
  static KLineDataInfoTooltip _defaultTooltip(
    BuildContext context,
    LongPressData data,
  ) {
    return KLineDataInfoTooltip(
      longPressData: data,
      dateTimeFormat: 'yyyy-MM-dd HH:mm',
    );
  }

  @override
  _KLineChartState createState() => _KLineChartState();
}

class _KLineChartState extends State<KLineChart>
    with SingleTickerProviderStateMixin {
  /// 圖表拖移處理
  late final ChartGesture chartGesture;

  /// 長按的資料串流控制
  final _longPressDataStreamController = StreamController<LongPressData?>();

  @override
  void initState() {
    // 慣性滑動控制器
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      lowerBound: double.negativeInfinity,
      upperBound: double.infinity,
    );

    chartGesture = ChartGestureImpl(
      onDrawUpdateNeed: () => setState(() {}),
      chartScroller: ChartInertialScroller(controller: controller),
      onLoadMore: widget.onLoadMore,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        MultiTouchGestureRecognizer: MultiTouchGestureRecognizer.factory(
          onTouchStart: chartGesture.onTouchDown,
          onTouchUpdate: chartGesture.onTouchUpdate,
          onTouchEnd: chartGesture.onTouchUp,
          onTouchCancel: chartGesture.onTouchCancel,
        ),
      },
      child: Stack(
        children: <Widget>[
          CustomPaint(
            size: Size.infinite,
            painter: ChartPainterImpl(
              datas: widget.datas,
              chartGesture: chartGesture,
              chartUiStyle: widget.chartUiStyle,
              mainState: widget.mainChartState,
              volumeState: widget.volumeChartState,
              indicatorState: widget.indicatorChartState,
              mainChartUiStyle: widget.mainChartUiStyle,
              volumeChartUiStyle: widget.volumeChartUiStyle,
              macdChartUiStyle: widget.macdChartUiStyle,
              rsiChartUiStyle: widget.rsiChartUiStyle,
              wrChartUiStyle: widget.wrChartUiStyle,
              kdjChartUiStyle: widget.kdjChartUiStyle,
              maPeriods: widget.maPeriods,
              onDrawInfo: (info) {
                chartGesture.setDrawInfo(info);
              },
              onLongPressData: (data) {
                _longPressDataStreamController.add(data);
              },
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
          _tooltip(),
        ],
      ),
    );
  }

  Widget _tooltip() {
    return StreamBuilder<LongPressData?>(
      stream: _longPressDataStreamController.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          return widget.tooltipBuilder?.call(context, data) ??
              const SizedBox.shrink();
        }
        return const SizedBox.shrink();
      },
    );
  }
}
