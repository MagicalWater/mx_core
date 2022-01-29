import 'package:flutter/material.dart';
import 'package:mx_core/ui/widget/k_line_chart/chart_inertial_scroller/chart_inertial_scroller.dart';

import '../chart_gesture.dart';
import 'gesture_handler_mixin_new.dart';

/// 圖表手勢處理
class ChartGestureImpl extends ChartGesture with GestureHandlerMixinNew {
  ChartGestureImpl({
    required VoidCallback onDrawUpdateNeed,
    required ChartInertialScroller chartScroller,
    Function(bool right)? onLoadMore,
  }) : super(
          onDrawUpdateNeed: onDrawUpdateNeed,
          chartScroller: chartScroller,
          onLoadMore: onLoadMore,
        );
}
