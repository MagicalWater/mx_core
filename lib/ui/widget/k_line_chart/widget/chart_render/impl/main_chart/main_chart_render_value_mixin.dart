import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mx_core/ui/widget/k_line_chart/model/model.dart';

import '../../chart_render.dart';
import 'ui_style/main_chart_ui_style.dart';

mixin MainChartValueMixin on ChartRender {
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

  /// 蠟燭圖的蠟燭寬度(已乘上縮放)
  late double candleWidthScaled;

  /// 實時線畫筆
  final Paint realTimeLinePaint = Paint();

  /// 背景色畫筆
  final Paint backgroundPaint = Paint();

  /// 分隔線畫筆
  final Paint gripPaint = Paint();

  /// 折線/ma線/boll線畫筆
  final Paint linePaint = Paint()..style = PaintingStyle.stroke;

  /// 折線圖的陰影渲染畫筆
  final Paint lineShadowPaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  /// 交叉橫線畫筆
  final Paint crossHorizontalPaint = Paint()..isAntiAlias = true;

  MainChartUiStyle get uiStyle => dataViewer.mainChartUiStyle;

  MainChartColorSetting get colors => uiStyle.colorSetting;

  MainChartSizeSetting get sizes => uiStyle.sizeSetting;

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
    maxValue = 0;
    minValue = double.infinity;

    final maDisplay = dataViewer.mainState.contains(MainChartState.ma);
    final bollDisplay = dataViewer.mainState.contains(MainChartState.boll);

    // 遍歷取得最大最小值, 以及擁有最大最小值的資料index
    for (var i = dataViewer.startDataIndex; i <= dataViewer.endDataIndex; i++) {
      final data = dataViewer.datas[i];

      if (maxValue <= data.high) {
        maxValue = data.high;
        maxValueDataIndex = i;
      }
      if (minValue >= data.low) {
        minValue = data.low;
        minValueDataIndex = i;
      }

      if (maDisplay) {
        final maData = data.indciatorData.ma?.ma;
        if (maData != null && maData.isNotEmpty) {
          final values = maData.values;
          final maxReduce = values.reduce(max);
          final minReduce = values.reduce(min);

          if (maxValue <= maxReduce) {
            maxValue = maxReduce;
            maxValueDataIndex = i;
          }

          if (minValue >= minReduce) {
            minValue = minReduce;
            minValueDataIndex = i;
          }
        }
      }

      if (bollDisplay) {
        final bollData = data.indciatorData.boll;
        if (bollData != null) {
          final values = [bollData.up, bollData.dn, bollData.mb];

          final maxReduce = values.reduce(max);
          final minReduce = values.reduce(min);

          if (maxValue <= maxReduce) {
            maxValue = maxReduce;
            maxValueDataIndex = i;
          }

          if (minValue >= minReduce) {
            minValue = minReduce;
            minValueDataIndex = i;
          }
        }
      }
    }

    candleWidthScaled = sizes.candleWidth * dataViewer.scaleX;

    // 取得 value 快速轉換 y軸位置的縮放參數
    final valueInterval = maxValue - minValue;
    final yInterval = maxY - minY;
    // print('最大: $maxValue => $minY, 最小: $minValue => $maxY');
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
