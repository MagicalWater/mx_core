import 'package:flutter/material.dart';
import 'package:mx_core/ui/widget/k_line_chart/chart_gesture/gesture_handle.dart';
import 'package:mx_core/ui/widget/k_line_chart/chart_inertial_scroller/chart_inertial_scroller.dart';

import '../chart_gesture.dart';
import 'gesture_handler_mixin.dart';

/// 圖表手勢處理
class ChartGestureImpl extends ChartGesture
    with GestureHandlerMixin {

  ChartGestureImpl({
    required VoidCallback onDrawUpdateNeed,
    required ChartInertialScroller chartScroller,
  }) : super(onDrawUpdateNeed: onDrawUpdateNeed, chartScroller: chartScroller);
}
