import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mx_core/ui/widget/k_line_chart/model/model.dart';

import '../../rsi_chart_render.dart';
import 'ui_style/rsi_chart_ui_style.dart';

mixin RSIChartValueMixin on RSIChartRender {
  /// 資料檢視區間擁有最小值/最大值的資料index
  late int minValueDataIndex, maxValueDataIndex;

  /// 資料檢視區間的最小值/最大值
  late double minValue, maxValue;

  /// 顯示的y軸位置區間
  /// [maxValue] 對應[minY]
  /// [minValue] 對應[maxY]
  late double minY, maxY;

  /// 快速將 value 轉換為 y軸位置的縮放參數
  late double valueToYScale;

  /// 實時線畫筆
  final Paint realTimeLinePaint = Paint();

  final Paint backgroundPaint = Paint();
  final Paint gripPaint = Paint();

  final Paint linePaint = Paint()..style = PaintingStyle.stroke;

  RSIChartUiStyle get uiStyle => dataViewer.rsiChartUiStyle;

  RSIChartColorSetting get colors => uiStyle.colorSetting;

  RSIChartSizeSetting get sizes => uiStyle.sizeSetting;

  List<MainChartState> get mainState => dataViewer.mainState;

  final chartPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..strokeWidth = 0.5;

  @override
  void initValue(Rect rect) {
    minY = rect.top + sizes.topPadding;
    maxY = rect.bottom - sizes.bottomPadding;

    // 取得顯示區間的資料的最大值
    maxValue = -double.infinity;
    minValue = double.infinity;

    // 遍歷取得最大最小值, 以及擁有最大最小值的資料index
    for (var i = dataViewer.startDataIndex; i <= dataViewer.endDataIndex; i++) {
      final data = dataViewer.datas[i];
      final rsiData = data.indciatorData.rsi;

      if (rsiData == null) {
        continue;
      }

      final value = rsiData.rsi;
      if (maxValue <= value) {
        maxValue = value;
        maxValueDataIndex = i;
      }

      if (minValue >= value) {
        minValue = value;
        minValueDataIndex = i;
      }
    }

    // 取得 value 快速轉換 y軸位置的縮放參數
    final valueInterval = maxValue - minValue;
    final yInterval = maxY - minY;
    valueToYScale = yInterval / valueInterval;
  }

  /// 帶入數值, 取得顯示的y軸位置
  double valueToRealY(double value) {
    return maxY - ((value - minValue) * valueToYScale);
  }

  /// 帶入y軸位置, 取得對應數值
  double realYToValue(double y) {
    return minValue - ((y - maxY) / valueToYScale);
  }
}
