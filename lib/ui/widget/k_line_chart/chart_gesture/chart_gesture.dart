import 'package:flutter/material.dart';
import 'package:mx_core/ui/widget/k_line_chart/chart_inertial_scroller/chart_inertial_scroller.dart';

import 'gesture_handle.dart';

/// 圖表手勢處理
abstract class ChartGesture implements GestureHandle {
  /// 是否正在縮放 / 拖移 / 長按
  bool isScale = false, isDrag = false, isLongPress = false;

  /// x軸滾動的距離
  double scrollX = 0;

  /// x軸縮放倍數
  double scaleX = 1;

  /// 上次手勢縮放時, x軸縮放倍數最後的數值
  double lastScaleX = 1;

  /// x軸被長按的位置
  double longPressX = 0, longPressY = 0;

  /// x軸最大可滾動距離
  double maxScrollX = 0;

  /// 慣性滑動
  final ChartInertialScroller chartScroller;

  /// 需要繪製的屬性變更
  /// 代表需要通知外部進行畫面刷新
  final VoidCallback onDrawUpdateNeed;

  ChartGesture({
    required this.onDrawUpdateNeed,
    required this.chartScroller,
  });

  /// 設置最大可滾動距離
  void setMaxScrollX(double maxScrollX) {
    this.maxScrollX = maxScrollX;
  }
}
