import 'package:flutter/gestures.dart';
import 'package:mx_core/route_page/page_route_mixin.dart';
import 'package:mx_core/ui/widget/k_line_chart/chart_gesture/gesture_handle.dart';

import '../chart_gesture.dart';

mixin GestureHandlerMixin on ChartGesture implements GestureHandle {
  double get maxScrollX => drawContentInfo?.maxScrollX ?? 0;

  /// 橫向拖動開始
  @override
  void onHorizontalDragDown(DragDownDetails details) {
    print('拖拉開始:');
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

    // print('scrollX = $scrollX, max = $maxScrollX');

    // 滾動的位置不得超過界線
    scrollX = scrollX.clamp(0.0, maxScrollX);
    onDrawUpdateNeed();
  }

  @override
  void onHorizontalDragEnd(DragEndDetails details) async {
    // print('結束橫向拖拉');
    chartScroller.setScrollUpdatedCallback((value) {
      scrollX = value;
      if (scrollX <= 0) {
        // 滑到最左邊
        scrollX = 0;
        onLoadMore?.call(false);
        chartScroller.stopScroll();
      } else if (scrollX >= maxScrollX) {
        // 滑到最右邊
        scrollX = maxScrollX;
        onLoadMore?.call(true);
        chartScroller.stopScroll();
      }
      onDrawUpdateNeed();
    });

    final completer = Completer<bool>();

    // 拖動結束後接著依照當前速度以及x軸位置進行模擬滑動
    chartScroller
        .startIntertialScroll(
      position: scrollX,
      velocity: details.primaryVelocity!,
    )
        .whenCompleteOrCancel(() {
      completer.complete(true);
    });

    await completer.future;

    isDrag = false;
    chartScroller.setScrollUpdatedCallback(null);
    onDrawUpdateNeed();
  }

  @override
  void onHorizontalDragCancel() {
    // print('取消橫向拖拉');
    isDrag = false;
  }

  @override
  void onScaleStart(ScaleStartDetails details) {
    print('縮放開始');
    isScale = true;
  }

  @override
  void onScaleUpdate(ScaleUpdateDetails details) {
    if (isDrag || isLongPress) return;

    final preScaleX = scaleX;
    scaleX = (lastScaleX * details.scale).clamp(0.5, 2.2);

    // 預計縮放之後圖表總寬度
    final nextChartTotalWidth =
        drawContentInfo!.chartTotalWidth / preScaleX * scaleX;

    final nextMaxScrollX = nextChartTotalWidth - drawContentInfo!.canvasWidth;

    // 取得前後總寬度差距
    final chartTotalWidthDifference =
        nextChartTotalWidth - drawContentInfo!.chartTotalWidth;

    // 取得縮放中心點於畫布上的x軸百分比位置
    final scaleCenter = details.focalPoint;
    final scaleCenterXFraction = scaleCenter.dx / drawContentInfo!.canvasWidth;
    // print('縮放點: $scaleCenter, $scaleCenterXFraction');

    scrollX += chartTotalWidthDifference * scaleCenterXFraction;

    scrollX = scrollX.clamp(0.0, nextMaxScrollX);

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
    onDrawUpdateNeed();
  }
}
