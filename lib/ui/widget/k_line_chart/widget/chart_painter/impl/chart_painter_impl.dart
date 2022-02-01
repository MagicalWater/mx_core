import 'package:flutter/material.dart';
import 'package:mx_core/ui/widget/k_line_chart/chart_gesture/chart_gesture.dart';
import 'package:mx_core/ui/widget/k_line_chart/model/model.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_painter/impl/chart_painter_paint_mixin.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/impl/kdj_chart/ui_style/kdj_chart_ui_style.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/impl/macd_chart/macd_chart_render_impl.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/impl/rsi_chart/ui_style/rsi_chart_ui_style.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/impl/wr_chart/ui_style/wr_chart_ui_style.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/main_chart_render.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/volume_chart_render.dart';
import '../chart_painter.dart';
import 'chart_painter_value_mixin.dart';

export '../ui_style/k_line_chart_ui_style.dart';

class ChartPainterImpl extends ChartPainter
    with ChartPainterPaintMixin, ChartPainterValueMixin {
  @override
  final List<KLineData> datas;

  /// 圖表高度占用設定
  @override
  final KLineChartUiStyle chartUiStyle;

  /// 當前x軸縮放倍數
  @override
  double get scaleX => chartGesture.scaleX;

  /// 主圖表ui風格
  @override
  final MainChartUiStyle mainChartUiStyle;

  /// 成交量圖表ui風格
  @override
  final VolumeChartUiStyle volumeChartUiStyle;

  /// MACD圖表ui風格
  @override
  final MACDChartUiStyle macdChartUiStyle;

  /// RSI圖表ui風格
  @override
  final RSIChartUiStyle rsiChartUiStyle;

  /// WR圖表ui風格
  @override
  final WRChartUiStyle wrChartUiStyle;

  /// KDJ圖表ui風格
  @override
  final KDJChartUiStyle kdjChartUiStyle;

  /// 主圖表顯示的資料
  @override
  final List<MainChartState> mainState;

  /// 買賣量圖表
  @override
  final VolumeChartState volumeState;

  /// 技術指標圖表
  @override
  final IndicatorChartState indicatorState;

  /// 價格格式化
  @override
  final String Function(num price) priceFormatter;

  /// 成交量格式化
  @override
  final String Function(num volume) volumeFormatter;

  /// x軸日期時間格式化
  @override
  final String Function(DateTime dateTime) xAxisDateTimeFormatter;

  @override
  final List<int> maPeriods;

  @override
  double? get longPressY =>
      chartGesture.isLongPress ? chartGesture.longPressY : null;

  /// 主圖表最右側實時價格的位置
  /// 若處於不可見狀態, 則[localPosition]為null
  final void Function(Offset? localPosition)? rightRealPriceOffset;

  ChartPainterImpl({
    required this.datas,
    required ChartGesture chartGesture,
    required this.chartUiStyle,
    required this.mainState,
    required this.volumeState,
    required this.indicatorState,
    required this.mainChartUiStyle,
    required this.macdChartUiStyle,
    required this.volumeChartUiStyle,
    required this.rsiChartUiStyle,
    required this.wrChartUiStyle,
    required this.kdjChartUiStyle,
    required this.maPeriods,
    required this.priceFormatter,
    required this.volumeFormatter,
    required this.xAxisDateTimeFormatter,
    required ValueChanged<DrawContentInfo>? onDrawInfo,
    required ValueChanged<LongPressData?>? onLongPressData,
    this.rightRealPriceOffset,
  }) : super(
          chartGesture: chartGesture,
          onDrawInfo: onDrawInfo,
          onLongPressData: onLongPressData,
        );

  @override
  void paint(Canvas canvas, Size size) {
    if (datas.isEmpty) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
      return;
    }

    // 初始化數值
    initDataValue(size);

    // 將整塊畫布依照比例切割成Rect分配給各個圖表
    // 1. 主圖表
    // 2. 買賣量圖表
    // 3. 其餘技術線圖表
    final computeRect = chartUiStyle.heightRatioSetting
        .computeChartHeight(
          totalHeight: size.height,
          volumeChartState: volumeState,
          indicatorChartState: indicatorState,
        )
        .toRect(size);
    // print('繪製: $mainRect, $volumeHeight, $indicatorHeight, size = $size');

    // 繪製主圖
    paintMainChart(canvas, computeRect.main, rightRealPriceOffset);

    // 繪製成交量圖
    paintVolumeChart(canvas, computeRect.volume);

    // 繪製技術線圖
    paintIndicatorChart(canvas, computeRect.indicator);

    // 繪製時間軸
    paintTimeAxis(canvas, computeRect.bottomTime);

    // 繪製長按豎線
    paintLongPressVerticalLine(canvas, size);

    // 繪製長按時間
    paintLongPressTime(canvas, computeRect.bottomTime);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
