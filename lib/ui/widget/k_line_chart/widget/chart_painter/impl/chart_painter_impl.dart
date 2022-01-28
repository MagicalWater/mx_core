import 'package:flutter/material.dart';
import 'package:mx_core/ui/widget/k_line_chart/chart_gesture/chart_gesture.dart';
import 'package:mx_core/ui/widget/k_line_chart/model/model.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_painter/impl/chart_painter_paint_mixin.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/impl/macd_chart/macd_chart_render_impl.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/main_chart_render.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/volume_chart_render.dart';
import '../chart_painter.dart';
import 'chart_painter_value_mixin.dart';
import 'package:mx_core/util/date_util.dart';

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

  /// 主圖表顯示的資料
  @override
  final List<MainChartState> mainState;

  /// 買賣量圖表
  @override
  final VolumeChartState volumeState;

  /// 技術指標圖表
  @override
  final IndicatorChartState indicatorState;

  @override
  final List<int> maPeriods;

  @override
  double? get longPressY =>
      chartGesture.isLongPress ? chartGesture.longPressY : null;

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
    required this.maPeriods,
    required ValueChanged<DrawContentInfo>? onDrawInfo,
    required ValueChanged<LongPressData?>? onLongPressData,
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
    paintMainChart(canvas, computeRect.main);

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

  /// 將價格格式化成字串
  @override
  String formatPrice(num value) {
    return value.toStringAsFixed(2);
  }

  /// 將買賣量格式化成字串
  @override
  String formateVolume(num volume) {
    if (volume > 10000 && volume < 999999) {
      final d = volume / 1000;
      return '${d.toStringAsFixed(2)}K';
    } else if (volume > 1000000) {
      final d = volume / 1000000;
      return '${d.toStringAsFixed(2)}M';
    }
    return volume.toStringAsFixed(2);
  }

  /// 將日期時間格式化
  @override
  String formateTime(DateTime dateTime) {
    return dateTime.getDateStr(format: 'MM-dd HH:mm');
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
