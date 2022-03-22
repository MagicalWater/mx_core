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

part '../model/k_line_chart_controller.dart';

/// 長按tooltip構建
typedef KLineChartTooltipBuilder = Widget Function(
  BuildContext context,
  LongPressData data,
);

/// k線圖表
/// ===
///
/// 起源自: https://github.com/gwhcn/flutter_k_chart
/// 非常感謝原作者在圖表上的製作思路
///
/// 了解完圖表的核心設計方式後, 進行了整體元件的重寫
/// 除了程式碼的結構差異之外, 在BUG/新增功能上
/// 1. 修正折線圖的光亮點造成整個圖表元件不斷的重構的問題
/// 2. 自定義手勢處理, 解決使用[GestureDetector]手勢縮放/拖拉沒有確實觸發的問題
/// 3. 圖表樣式/尺寸可由外部自由訂製
/// 4. 新增圖表滑動到最右側/最左側時會觸發加載更多的方法
/// 5. tooltip可由外部自由訂製顯示
/// 6. 點擊實時線的價格箭頭可彈跳至圖表最右側
/// 7. 初始資料未滿一頁時, 會自動觸發一次加載更多
/// 8. 圖表高度若皆為固定值, 則外部不需將高度設死
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
  final MainChartState mainChartState;

  /// 主圖表技術線
  final MainChartIndicatorState mainChartIndicatorState;

  /// 成交量圖表顯示
  final VolumeChartState volumeChartState;

  /// 技術分析圖表顯示
  final IndicatorChartState indicatorChartState;

  /// ma週期
  final List<int> maPeriods;

  /// x軸時間格式化
  final String Function(DateTime dateTime) xAxisDateTimeFormatter;

  /// tooltip 樣式
  final KLineDataTooltipUiStyle tooltipUiStyle;

  /// tooltip前綴字
  final TooltipPrefix tooltipPrefix;

  /// tooltip彈窗構建(若不帶入則使用預設彈窗)
  final KLineChartTooltipBuilder? tooltipBuilder;

  /// 加載更多調用, false代表滑動到最左邊, true則為最右邊
  final void Function(bool right)? onLoadMore;

  /// 價格格式化
  final String Function(num price) priceFormatter;

  /// 成交量格式化
  final String Function(num volume)? volumeFormatter;

  /// 圖表控制
  final KLineChartController? controller;

  const KLineChart({
    Key? key,
    required this.datas,
    this.mainChartState = MainChartState.kLine,
    this.mainChartIndicatorState = MainChartIndicatorState.ma,
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
    this.tooltipPrefix = const TooltipPrefix(),
    this.tooltipUiStyle = const KLineDataTooltipUiStyle(),
    this.tooltipBuilder,
    this.xAxisDateTimeFormatter = _defaultXAxisDateFormatter,
    this.priceFormatter = _defaultPriceFormatter,
    this.volumeFormatter,
    this.onLoadMore,
    this.controller,
  }) : super(key: key);

  /// 預設x軸時間格式化
  static String _defaultXAxisDateFormatter(DateTime dateTime) {
    return DateUtil.getDateStr(dateTime, format: 'MM-dd mm:ss');
  }

  /// 預設價格格式化
  static String _defaultPriceFormatter(num price) {
    return price.toStringAsFixed(2);
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

  /// 當資料未滿一頁時所記錄下的資料筆數
  /// 用途是當再次傳出資料筆數未滿一頁時
  /// 不再持續重複調用加載更多資料
  int oldDataCount = 0;

  /// 與[oldDataCount]搭配使用, 代表當頁數未滿一頁時, 是否已經調用過未滿一頁所觸發的回調了
  bool isDataLessOnePageCallBack = false;

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

    oldDataCount = widget.datas.length;
    isDataLessOnePageCallBack = false;

    widget.controller?._bind = this;

    super.initState();
  }

  @override
  void didUpdateWidget(covariant KLineChart oldWidget) {
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._bind = null;
      widget.controller?._bind = this;
    }

    if (oldDataCount != widget.datas.length) {
      oldDataCount = widget.datas.length;
      isDataLessOnePageCallBack = false;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    chartGesture.dispose();
    _rightRealTimePricePositionStreamController.close();
    _realTimePriceGlobalPositionStreamController.close();
    widget.controller?._bind = null;
    super.dispose();
  }

  /// 預設成交量格式化
  String _defaultVolumeFormatter(num volume) {
    if (volume > 10000 && volume < 999999) {
      final d = volume / 1000;
      return '${widget.priceFormatter(d)}K';
    } else if (volume > 1000000) {
      final d = volume / 1000000;
      return '${widget.priceFormatter(d)}M';
    }
    return widget.priceFormatter(volume);
  }

  @override
  Widget build(BuildContext context) {
    final heightSetting = widget.chartUiStyle.heightRatioSetting;
    final chartHeight = heightSetting.getFixedHeight(
          volumeChartState: widget.volumeChartState,
          indicatorChartState: widget.indicatorChartState,
        ) ??
        double.infinity;
    return TouchGestureDector(
      onTouchStart: chartGesture.onTouchDown,
      onTouchUpdate: chartGesture.onTouchUpdate,
      onTouchEnd: chartGesture.onTouchUp,
      onTouchCancel: chartGesture.onTouchCancel,
      isAllowPointerMove: (move) {
        final touchStatus = chartGesture.getTouchPointerStatus(move.pointer);

        switch (touchStatus) {
          case TouchStatus.none:
            return GestureDisposition.rejected;
          case TouchStatus.drag:
            final hitSlop = computeHitSlop(move.kind, move.gestureSettings);
            if (move.pendingDelta.dx.abs() > hitSlop) {
              return GestureDisposition.accepted;
            }
            break;
          case TouchStatus.scale:
            return GestureDisposition.accepted;
          case TouchStatus.longPress:
            return GestureDisposition.accepted;
        }
      },
      child: Stack(
        children: <Widget>[
          RepaintBoundary(
            child: CustomPaint(
              size: Size(double.infinity, chartHeight),
              painter: ChartPainterImpl(
                datas: widget.datas,
                chartGesture: chartGesture,
                chartUiStyle: widget.chartUiStyle,
                mainChartState: widget.mainChartState,
                mainChartIndicatorState: widget.mainChartIndicatorState,
                volumeChartState: widget.volumeChartState,
                indicatorChartState: widget.indicatorChartState,
                mainChartUiStyle: widget.mainChartUiStyle,
                volumeChartUiStyle: widget.volumeChartUiStyle,
                macdChartUiStyle: widget.macdChartUiStyle,
                rsiChartUiStyle: widget.rsiChartUiStyle,
                wrChartUiStyle: widget.wrChartUiStyle,
                kdjChartUiStyle: widget.kdjChartUiStyle,
                maPeriods: widget.maPeriods,
                priceFormatter: widget.priceFormatter,
                volumeFormatter:
                    widget.volumeFormatter ?? _defaultVolumeFormatter,
                xAxisDateTimeFormatter: widget.xAxisDateTimeFormatter,
                onDrawInfo: (info) {
                  chartGesture.setDrawInfo(info);

                  if (info.maxScrollX == 0) {
                    // 資料未滿一頁
                    if (!isDataLessOnePageCallBack) {
                      isDataLessOnePageCallBack = true;
                      widget.onLoadMore?.call(false);
                    }
                  }
                },
                onLongPressData: (data) {
                  _longPressDataStreamController.add(data);
                },
                rightRealTimePriceOffset: (offset) {
                  if (offset != null &&
                      widget.mainChartState == MainChartState.lineIndex) {
                    _rightRealTimePricePositionStreamController.add(offset);
                  } else {
                    _rightRealTimePricePositionStreamController.add(null);
                  }
                },
                globalRealTimePriceY: (localY) {
                  _realTimePriceGlobalPositionStreamController.add(localY);
                },
              ),
            ),
          ),

          // 長按時顯示的詳細資訊彈窗
          _tooltip(),

          // 右側最新價可見時的閃亮動畫
          _realTimePriceFlash(),

          // 全局實時價tag
          _globalRealTimePriceTag(chartHeight),
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
              KLineDataInfoTooltip(
                longPressData: data,
                priceFormatter: widget.priceFormatter,
                volumeFormatter:
                    widget.volumeFormatter ?? _defaultVolumeFormatter,
                uiStyle: widget.tooltipUiStyle,
                tooltipPrefix: widget.tooltipPrefix,
              );
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
  Widget _globalRealTimePriceTag(double chartHeight) {
    return StreamBuilder<double?>(
      stream: _realTimePriceGlobalPositionStream,
      builder: (context, snapshot) {
        final y = snapshot.data;
        if (y == null) {
          return const SizedBox.shrink();
        }
        final price = widget.datas.last.close;
        final gridColumns = widget.chartUiStyle.sizeSetting.gridColumns;
        return SizedBox(
          height: chartHeight,
          child: PositionLayout(
            xRatio: (gridColumns - 1) / gridColumns,
            yFixed: y,
            child: GlobalRealTimePriceTag(
              price: widget.priceFormatter(price),
              uiStyle: widget.mainChartUiStyle,
              onTap: () {
                scrollToRight(animated: true);
              },
            ),
          ),
        );
      },
    );
  }

  /// 將圖表滾動回原點
  Future<void> scrollToRight({bool animated = true}) {
    return chartGesture.scrollToRight(animated: animated);
  }
}
