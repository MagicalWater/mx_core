import 'package:flutter/gestures.dart';
import 'package:mx_core/ui/widget/k_line_chart/chart_gesture/gesture_handle.dart';

import '../chart_gesture.dart';

mixin GestureHandlerMixin on ChartGesture implements GestureHandle {
  /// 橫向拖動開始
  @override
  void onHorizontalDragDown(DragDownDetails details) {
    isDrag = true;
    if (chartScroller.isScroll) {
      chartScroller.stopScroll();
      onDrawUpdateNeed();
    }
  }

  /// 橫向拖動中
  @override
  void onHorizontalDragUpdate(DragUpdateDetails details) {
    if (isScale || isLongPress) return;

    // 計算取得x滾動的位置
    scrollX = (details.primaryDelta! / scaleX + scrollX);

    print('scrollX = $scrollX, max = $maxScrollX');

    // 滾動的位置不得超過界線
    scrollX = scrollX.clamp(0.0, maxScrollX);
    onDrawUpdateNeed();
  }

  @override
  void onHorizontalDragEnd(DragEndDetails details) {
    // 拖動結束後接著依照當前速度以及x軸位置進行模擬滑動
    chartScroller.startIntertialScroll(
      position: scrollX,
      velocity: details.primaryVelocity!,
    );
  }

  @override
  void onHorizontalDragCancel() {
    isDrag = false;
  }

  @override
  void onScaleStart(ScaleStartDetails details) {
    isScale = true;
  }

  @override
  void onScaleUpdate(ScaleUpdateDetails details) {
    if (isDrag || isLongPress) return;
    scaleX = (lastScaleX * details.scale).clamp(0.5, 2.2);
    onDrawUpdateNeed();
  }

  @override
  void onScaleEnd(ScaleEndDetails details) {
    isScale = false;
    lastScaleX = scaleX;
  }

  @override
  void onLongPressStart(LongPressStartDetails details) {
    isLongPress = true;
    if (longPressX != details.localPosition.dx ||
        longPressY != details.localPosition.dy) {
      longPressX = details.localPosition.dx;
      longPressY = details.localPosition.dy;
      onDrawUpdateNeed();
    }
  }

  @override
  void onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (longPressX != details.localPosition.dx ||
        longPressY != details.localPosition.dy) {
      longPressX = details.localPosition.dx;
      longPressY = details.localPosition.dy;
      onDrawUpdateNeed();
    }
  }

  @override
  void onLongPressEnd(LongPressEndDetails details) {
    isLongPress = false;
    //TODO: 此功能未知, 註記
    // mInfoWindowStream.add(null);
    onDrawUpdateNeed();
  }
}
