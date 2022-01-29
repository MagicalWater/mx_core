import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:mx_core/ui/widget/k_line_chart/chart_gesture/gestures/drag_gesture.dart';
import 'package:mx_core/ui/widget/k_line_chart/chart_gesture/gestures/long_press_gesture.dart';
import 'package:mx_core/ui/widget/k_line_chart/chart_gesture/gestures/scale_gesture.dart';

import '../chart_gesture.dart';
import '../gesture_handle_new.dart';

mixin GestureHandlerMixinNew on ChartGesture
    implements GestureHandleNew, DragGesture, LongPressGesture, ScaleGesture {
  double get maxScrollX => drawContentInfo?.maxScrollX ?? 0;

  final activePointer = <int, Offset>{};

  final _longPressDetect = const Duration(seconds: 1);

  Timer? _longPressTimer;

  /// 取得當前縮放的全局焦點
  Offset get _scaleFocalOffset {
    final pointers = activePointer.values.toList();
    final point1 = pointers[0];
    final point2 = pointers[1];
    return (point1 + point2) / 2;
  }

  @override
  void onTouchDown(int pointer, DragStartDetails details) {
    if (activePointer.length >= 2) {
      // 只接收兩指
      return;
    }
    activePointer[pointer] = details.globalPosition;

    if (activePointer.length == 1) {
      isDrag = true;
      isScale = false;
      isLongPress = false;

      // 啟動長按倒數
      _startLongPressTimer();

      onDragStart(details);
    } else if (activePointer.length == 2) {
      isDrag = false;
      isScale = true;
      isLongPress = false;

      _cancelLongPressTimer();

      onScaleStart(ScaleStartDetails(
        focalPoint: _scaleFocalOffset,
      ));
    }
  }

  @override
  void onTouchUpdate(int pointer, DragUpdateDetails details) {
    if (isDrag) {
      onDragUpdate(details);
    } else if (isLongPress) {
      onLongPressMoveUpdate(
        LongPressMoveUpdateDetails()
      );
    } else if (isScale) {}
  }

  @override
  void onTouchUp(int pointer, DragEndDetails details) {
    print('onTouchEnd: ${pointer}');
  }

  @override
  void onTouchCancel(int pointer) {
    print('onTouchCancel: ${pointer}');
  }

  void _startLongPressTimer() {
    _cancelLongPressTimer();

    _longPressTimer = Timer(_longPressDetect, () {
      isDrag = false;
      isLongPress = true;
    });
  }

  void _cancelLongPressTimer() {
    if (_longPressTimer != null && _longPressTimer!.isActive) {
      _longPressTimer!.cancel();
    }
    _longPressTimer = null;
  }
}
