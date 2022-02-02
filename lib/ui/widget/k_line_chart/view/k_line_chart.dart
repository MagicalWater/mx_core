import 'package:flutter/material.dart';
import 'package:mx_core/route_page/page_route_mixin.dart';
import 'package:mx_core/ui/widget/k_line_chart/chart_gesture/chart_gesture.dart';
import 'package:mx_core/ui/widget/k_line_chart/chart_gesture/impl/chart_gesture_impl.dart';
import 'package:mx_core/ui/widget/k_line_chart/chart_inertial_scroller/chart_inertial_scroller.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/flash_point/flast_point.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/global_real_tim_price_tag/global_real_time_price_tag.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/touch_gesture_dector/touch_gesture_dector.dart';
import 'package:mx_core/ui/widget/position_layout.dart';
import 'package:mx_core/util/date_util.dart';

import '../k_line_chart.dart';
export '../widget/chart_painter/chart_painter.dart';
export '../widget/chart_render/main_chart_render.dart';
export '../widget/chart_render/volume_chart_render.dart';
export '../widget/chart_render/macd_chart_render.dart';
export '../widget/chart_render/rsi_chart_render.dart';
export '../widget/chart_render/kdj_chart_render.dart';
export '../widget/chart_render/wr_chart_render.dart';
export '../widget/k_line_data_tooltip/k_line_data_tooltip.dart';

/// 長按tooltip構建
typedef KLineChartTooltipBuilder = Widget Function(
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
  final String Function(DateTime dateTime) xAxisDateTimeFormatter;

  /// tooltip彈窗構建
  final KLineChartTooltipBuilder? tooltipBuilder;

  /// 加載更多調用, false代表滑動到最左邊, true則為最右邊
  final Function(bool right)? onLoadMore;

  /// 價格格式化
  final String Function(num price) priceFormatter;

  /// 成交量格式化
  final String Function(num volume) volumeFormatter;

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
    this.tooltipBuilder = _defaultTooltip,
    this.xAxisDateTimeFormatter = _defaultXAxisDateFormatter,
    this.priceFormatter = _defaultPriceFormatter,
    this.volumeFormatter = _defaultVolumeFormatter,
    this.onLoadMore,
  }) : super(key: key);

  /// 預設tooltip元件
  static Widget _defaultTooltip(
    BuildContext context,
    LongPressData data,
  ) {
    return KLineDataInfoTooltip(
      longPressData: data,
    );
  }

  /// 預設x軸時間格式化
  static String _defaultXAxisDateFormatter(DateTime dateTime) {
    return DateUtil.getDateStr(dateTime, format: 'MM-dd mm:ss');
  }

  /// 預設價格格式化
  static String _defaultPriceFormatter(num price) {
    return price.toStringAsFixed(2);
  }

  /// 預設成交量格式化
  static String _defaultVolumeFormatter(num volume) {
    if (volume > 10000 && volume < 999999) {
      final d = volume / 1000;
      return '${d.toStringAsFixed(2)}K';
    } else if (volume > 1000000) {
      final d = volume / 1000000;
      return '${d.toStringAsFixed(2)}M';
    }
    return volume.toStringAsFixed(2);
  }

  @override
  _KLineChartState createState() => _KLineChartState();
}

class _KLineChartState extends State<KLineChart>
    with SingleTickerProviderStateMixin {
  /// 最右側最新價格的位置
  final _rightRealTimePricePositionStreamController =
      StreamController<Offset?>();

  /// 全局最新價格的y軸位置
  final _realTimePriceGlobalPositionStreamController =
      StreamController<double?>();

  /// 最右側最新價格, 禁止重複串流
  late final Stream<Offset?> _rightRealPricePositionStream;

  /// 全局最新價格的y軸位置, 禁止重複串流
  late final Stream<double?> _realTimePriceGlobalPositionStream;

  /// 圖表拖移處理
  late final ChartGesture chartGesture;

  /// 長按的資料串流控制
  final _longPressDataStreamController = StreamController<LongPressData?>();

  @override
  void initState() {
    _rightRealPricePositionStream =
        _rightRealTimePricePositionStreamController.stream.distinct();

    _realTimePriceGlobalPositionStream =
        _realTimePriceGlobalPositionStreamController.stream.distinct();

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
  void dispose() {
    chartGesture.dispose();
    _rightRealTimePricePositionStreamController.close();
    _realTimePriceGlobalPositionStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TouchGestureDector(
      onTouchStart: chartGesture.onTouchDown,
      onTouchUpdate: chartGesture.onTouchUpdate,
      onTouchEnd: chartGesture.onTouchUp,
      onTouchCancel: chartGesture.onTouchCancel,
      child: Stack(
        children: <Widget>[
          RepaintBoundary(
            child: CustomPaint(
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
                  priceFormatter: widget.priceFormatter,
                  volumeFormatter: widget.volumeFormatter,
                  xAxisDateTimeFormatter: widget.xAxisDateTimeFormatter,
                  onDrawInfo: (info) {
                    chartGesture.setDrawInfo(info);
                  },
                  onLongPressData: (data) {
                    _longPressDataStreamController.add(data);
                  },
                  rightRealTimePriceOffset: (offset) {
                    if (offset != null &&
                        widget.mainChartState
                            .contains(MainChartState.lineIndex)) {
                      _rightRealTimePricePositionStreamController.add(offset);
                    } else {
                      _rightRealTimePricePositionStreamController.add(null);
                    }
                  },
                  globalRealTimePriceY: (localY) {
                    _realTimePriceGlobalPositionStreamController.add(localY);
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
          ),

          // 長按時顯示的詳細資訊彈窗
          _tooltip(),

          // 右側最新價可見時的閃亮動畫
          _realTimePriceFlash(),

          // 全局實時價tag
          _globalRealTimePriceTag(),
        ],
      ),
    );
  }

  /// 長按顯示的tooltip
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

  /// 折線圖, 實時價格的閃亮圓點動畫
  Widget _realTimePriceFlash() {
    return StreamBuilder<Offset?>(
      stream: _rightRealPricePositionStream,
      builder: (context, snapshot) {
        final offset = snapshot.data;
        if (offset == null) {}
        final circleSize =
            widget.mainChartUiStyle.sizeSetting.realTimePriceFlash;
        return Positioned(
          left: offset == null ? null : offset.dx - circleSize / 2,
          top: offset == null ? null : offset.dy - circleSize / 2,
          child: RepaintBoundary(
            child: FlashPoint(
              active: offset != null,
              width: circleSize,
              height: circleSize,
              flastColors:
                  widget.mainChartUiStyle.colorSetting.realTimeRightPointFlash,
            ),
          ),
        );
      },
    );
  }

  /// 全局顯示的最新價格標示的tag
  Widget _globalRealTimePriceTag() {
    return StreamBuilder<double?>(
      stream: _realTimePriceGlobalPositionStream,
      builder: (context, snapshot) {
        final y = snapshot.data;
        if (y == null) {
          return const SizedBox.shrink();
        }
        final price = widget.datas.last.close;
        final gridColumns = widget.chartUiStyle.sizeSetting.gridColumns;
        return PositionLayout(
          xRatio: (gridColumns - 1) / gridColumns,
          yFixed: y,
          child: GlobalRealTimePriceTag(
            price: widget.priceFormatter(price),
            uiStyle: widget.mainChartUiStyle,
            onTap: () {
              chartGesture.scrollToRight();
            },
          ),
        );
      },
    );
  }
}
