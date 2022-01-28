import 'package:flutter/material.dart';
import 'package:mx_core/ui/widget/k_line_chart/chart_inertial_scroller/chart_inertial_scroller.dart';
import 'package:mx_core/ui/widget/k_line_chart/model/draw_content_info.dart';

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

  /// 元件繪製完成後才可獲取到的資料
  /// 1. x軸可滑動距離, 2. 資料表總寬度, 3. 畫布寬度
  DrawContentInfo? drawContentInfo;

  /// 慣性滑動
  final ChartInertialScroller chartScroller;

  /// 需要繪製的屬性變更
  /// 代表需要通知外部進行畫面刷新
  final VoidCallback onDrawUpdateNeed;

  /// 滑動到最左/最右回調
  final Function(bool right)? onLoadMore;

  ChartGesture({
    required this.onDrawUpdateNeed,
    required this.chartScroller,
    this.onLoadMore,
  });

  /// 設置最大可滾動距離
  void setDrawInfo(DrawContentInfo info) {
    drawContentInfo = info;
  }

  void dispose() {
    chartScroller.dispose();
  }
}