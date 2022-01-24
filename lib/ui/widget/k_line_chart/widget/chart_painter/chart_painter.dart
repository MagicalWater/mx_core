import 'package:flutter/material.dart';
import 'package:mx_core/ui/widget/k_line_chart/chart_gesture/chart_gesture.dart';
import 'package:mx_core/ui/widget/k_line_chart/model/model.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/impl/main_chart/main_chart_render.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/impl/main_chart/main_chart_ui_style.dart';

import 'ui_style/k_line_chart_ui_style.dart';

export 'ui_style/k_line_chart_ui_style.dart';

/// 顯示的資料
abstract class DataViewer {
  /// 視圖中, 顯示的第一個以及最後一個data的index
  abstract int startDataIndex, endDataIndex;

  /// 圖表資料
  abstract final List<KLineData> datas;

  /// 圖表通用ui風格
  abstract final KLineChartUiStyle chartUiStyle;

  /// 主圖表ui風格
  abstract final MainChartUiStyle mainChartUiStyle;

  /// 主圖表顯示的資料
  abstract final List<MainChartState> mainState;

  /// 買賣量圖表
  abstract final VolumeChartState volumeState;

  /// 技術指標圖表
  abstract final IndicatorChartState indicatorState;

  /// ma(均線)週期
  abstract final List<int> maPeriods;

  /// 取得長按中的data index
  KLineData? getLongPressData();

  /// 將data的索引值轉換為畫布繪製的x軸座標
  double dataIndexToRealX(int index);
}

class ChartPainter extends CustomPainter implements DataViewer {
  final ChartGesture chartGesture;

  @override
  final List<KLineData> datas;

  /// 圖表高度占用設定
  @override
  final KLineChartUiStyle chartUiStyle;

  /// 視圖中, 顯示的第一個以及最後一個data的index
  @override
  late int startDataIndex, endDataIndex;

  /// 視圖中, 顯示的x軸起始點以及結束點
  late double startDisplayX, endDisplayX;

  /// 主圖表ui風格
  @override
  final MainChartUiStyle mainChartUiStyle;

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

  /// 資料總寬度
  double? totalDataWidth;

  /// 最大滾動距離
  double? maxScrollX;

  /// 元件的寬度
  late double canvasWidth;

  /// 當取得最大滾動距離時回調
  final ValueChanged<double>? onMaxScrolled;

  ChartPainter({
    required this.datas,
    required this.chartGesture,
    required this.chartUiStyle,
    required this.mainState,
    required this.volumeState,
    required this.indicatorState,
    required this.mainChartUiStyle,
    required this.maPeriods,
    required this.onMaxScrolled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (datas.isEmpty) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
      return;
    }

    // 初始化數值
    _initDataValue(size);

    // 將整塊畫布依照比例切割成Rect分配給各個圖表
    // 1. 主圖表
    // 2. 買賣量圖表
    // 3. 其餘技術線圖表
    final heightCompute = chartUiStyle.heightRatioSetting.computeChartHeight(
      totalHeight: size.height,
      volumeChartState: volumeState,
      indicatorChartState: indicatorState,
    );

    final mainRect = Rect.fromLTWH(
      0,
      0,
      size.width,
      heightCompute.mainHeight + chartUiStyle.heightRatioSetting.topSpaceFixed,
    );
    final volumeHeight = Rect.fromLTWH(
      0,
      mainRect.bottom,
      size.width,
      heightCompute.volumeHeight,
    );
    final indicatorHeight = Rect.fromLTWH(
      0,
      volumeHeight.bottom,
      size.width,
      heightCompute.indicatorHeight,
    );
    // print('繪製: $mainRect, $volumeHeight, $indicatorHeight, size = $size');

    _paintMainChart(canvas, mainRect);
    _paintVolumeChart(canvas, volumeHeight);
    _paintIndicatorChart(canvas, indicatorHeight);
  }

  /// 繪製主圖表
  void _paintMainChart(Canvas canvas, Rect rect) {
    final render = MainChartRender(dataViewer: this);
    render.initValue(rect);
    render.paintBackground(canvas, rect);
    render.paintGrid(canvas, rect);
    render.paintText(canvas, rect);
    render.paintChart(canvas, rect);
  }

  /// 繪製volume圖表
  void _paintVolumeChart(Canvas canvas, Rect rect) {}

  /// 繪製技術指標圖表
  void _paintIndicatorChart(Canvas canvas, Rect rect) {}

  /// 初始化圖表資料
  /// 關於最大滾動距離
  ///   - 因圖表是由右往左滑, 因此滑動的x是從0開始往下算, 但距離為正
  void _initDataValue(Size size) {
    canvasWidth = size.width;

    // 資料占用總寬度
    totalDataWidth =
        datas.length * chartUiStyle.sizeSetting.dataWidth * chartGesture.scaleX;

    // 計算最大可滾動的距離
    // 還需要扣除右邊空出來顯示最新豎直的區塊
    final scrollX =
        canvasWidth - totalDataWidth! - chartUiStyle.sizeSetting.rightSpace;

    if (scrollX >= 0) {
      // 資料佔不滿元件, 因此無法滾動, 最大滾動距離為0
      maxScrollX = 0;
    } else {
      maxScrollX = scrollX.abs();
    }

    // 取得視圖中第一筆以及最後一筆顯示的資料
    startDisplayX = realXToDisplayX(0);
    endDisplayX = realXToDisplayX(size.width);
    startDataIndex = displayXToDataIndex(startDisplayX);
    endDataIndex = displayXToDataIndex(endDisplayX);

    print('開始: ${realXToDisplayX(0)}, 結束: ${realXToDisplayX(size.width)}');

    onMaxScrolled?.call(maxScrollX!);
  }

  /// 取得長按中的data
  @override
  KLineData? getLongPressData() {
    if (!chartGesture.isLongPress) {
      return null;
    }
    final displayX = realXToDisplayX(chartGesture.longPressX);
    final index = displayXToDataIndex(displayX);
    return index >= datas.length ? null : datas[index];
  }

  /// 將data的索引值轉換為畫布繪製的x軸座標(中間點)
  @override
  double dataIndexToRealX(int index) {
    final displayX = dataIndexToDisplayX(index);
    return displayXToRealX(displayX);
  }

  /// 將data的索引值轉換為顯示的x軸座標(正中間)
  double dataIndexToDisplayX(int index) {
    final sizeSetting = chartUiStyle.sizeSetting;
    final leftPoint = -(totalDataWidth! + sizeSetting.rightSpace);
    final dataWidth = sizeSetting.dataWidth * chartGesture.scaleX;
    final dataPoint = dataWidth * index + (dataWidth / 2);
    return leftPoint + dataPoint;
  }

  /// 將顯示中的x轉化為資料的index
  int displayXToDataIndex(double displayX) {
    final sizeSetting = chartUiStyle.sizeSetting;
    final dataWidth = sizeSetting.dataWidth * chartGesture.scaleX;
    final leftPoint = -(totalDataWidth! + sizeSetting.rightSpace);
    final dataIndex = (displayX - leftPoint) ~/ dataWidth;
    if (dataIndex >= datas.length) {
      return datas.length - 1;
    }
    return dataIndex;
  }

  /// 將顯示中的x轉換為實際畫布上的x
  double displayXToRealX(double displayX) {
    return displayX - startDisplayX;
  }

  /// 將實際畫布的index轉換成顯示中的x
  double realXToDisplayX(double realX) {
    return -chartGesture.scrollX - (canvasWidth - realX);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
