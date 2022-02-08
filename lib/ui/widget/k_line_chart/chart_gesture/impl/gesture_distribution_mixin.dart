import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:mx_core/ui/widget/k_line_chart/chart_gesture/gestures/drag_gesture.dart';
import 'package:mx_core/ui/widget/k_line_chart/chart_gesture/gestures/long_press_gesture.dart';
import 'package:mx_core/ui/widget/k_line_chart/chart_gesture/gestures/scale_gesture.dart';
import 'package:mx_core/ui/widget/k_line_chart/chart_gesture/gestures/tap_gesture.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/touch_gesture_dector/touch_gesture_dector.dart';

import '../chart_gesture.dart';

/// 手勢歸類分發
mixin GestureDistributionMixin on ChartGesture
    implements TapGesture, DragGesture, LongPressGesture, ScaleGesture {
  /// 目前正在起作用的觸摸
  final activePointer = <int, _PointerPosition>{};

  /// 觸摸到變成長按的檢測時間
  final _longPressDetect = const Duration(milliseconds: 500);

  /// 當拖拉超過此距離, 則結束長按倒數
  final _cancelLongPressTimerDistance = 5;

  /// 長按倒數
  Timer? _longPressTimer;

  /// 初始拖拉offset
  late Offset _initDragPoint;

  /// 初始scale distance
  late double _initSclaeDistance;

  /// 取得當前縮放的全局焦點
  _PointerPosition get _currentScaleFocalPoint {
    final pointers = activePointer.values.toList();
    final point1 = pointers[0];
    final point2 = pointers[1];
    return _PointerPosition(
      global: (point1.global + point2.global) / 2,
      local: (point1.local + point2.local) / 2,
    );
  }

  /// 取得當前兩指距離
  double get _currentTouchDistance {
    final pointers = activePointer.values.toList();
    final point1 = pointers[0];
    final point2 = pointers[1];
    return (point2.global - point1.global).distance;
  }

  /// 取得當前縮放的倍數
  double get _currentScale {
    final pointers = activePointer.values.toList();
    final point1 = pointers[0];
    final point2 = pointers[1];
    return (point2.global - point1.global).distance / _initSclaeDistance;
  }

  @override
  TouchStatus getTouchPointerStatus(int pointer) {
    if (activePointer.keys.contains(pointer)) {
      if (isDrag) {
        return TouchStatus.drag;
      } else if (isScale) {
        return TouchStatus.scale;
      } else if (isLongPress) {
        return TouchStatus.longPress;
      } else {
        // 正常狀態不會在此
        print('GestureDistributionMixin: 觸摸狀態異常');
        throw 'GestureDistributionMixin: 觸摸狀態異常';
      }
    } else {
      return TouchStatus.none;
    }
  }

  @override
  void onTouchDown(int pointer, DragStartDetails details) {
    if (isDrag) {
      // 正在拖拉中, 變更為開始縮放
      activePointer[pointer] = _PointerPosition.fromDragStart(details);

      isDrag = false;
      isScale = true;

      _initSclaeDistance = _currentTouchDistance;

      _cancelLongPressTimer();

      final scalePosition = _currentScaleFocalPoint;
      onScaleStart(ScaleStartDetails(
        focalPoint: scalePosition.global,
        localFocalPoint: scalePosition.local,
        pointerCount: 2,
      ));
    } else if (isScale || isLongPress) {
      // 正在縮放/長按中, 禁止其餘觸摸
      return;
    } else {
      // 目前無任何手勢, 啟動拖拉
      activePointer[pointer] = _PointerPosition.fromDragStart(details);
      isDrag = true;

      _initDragPoint = details.globalPosition;

      // 啟動長按倒數
      _startLongPressTimer();

      onDragStart(details);
    }
  }

  @override
  void onTouchUpdate(int pointer, DragUpdateDetails details) {
    if (!activePointer.containsKey(pointer)) {
      return;
    }
    if (isDrag) {
      // 當前為拖拉狀態, 則發出拖拉更新
      activePointer[pointer] = _PointerPosition.fromDragUpdate(details);

      // 檢測是否需要取消長按倒數
      if (_longPressTimer != null) {
        final needCancel = (details.globalPosition - _initDragPoint).distance >
            _cancelLongPressTimerDistance;
        if (needCancel) {
          _cancelLongPressTimer();
        }
      }

      onDragUpdate(details);
    } else if (isLongPress) {
      // 當前為長按狀態, 發出長按拖拉更新
      final prePointer = activePointer[pointer]!;
      activePointer[pointer] = _PointerPosition.fromDragUpdate(details);
      onLongPressMoveUpdate(LongPressMoveUpdateDetails(
        globalPosition: details.globalPosition,
        localPosition: details.localPosition,
        offsetFromOrigin: details.globalPosition - prePointer.global,
        localOffsetFromOrigin: details.localPosition - prePointer.local,
      ));
    } else if (isScale) {
      // 當前為縮放狀態, 發出縮放更新
      final preScalePosition = _currentScaleFocalPoint;
      activePointer[pointer] = _PointerPosition.fromDragUpdate(details);
      final scalePosition = _currentScaleFocalPoint;
      final scale = _currentScale;
      onScaleUpdate(ScaleUpdateDetails(
        focalPoint: scalePosition.global,
        localFocalPoint: scalePosition.local,
        scale: scale,
        verticalScale: scale,
        horizontalScale: scale,
        pointerCount: 2,
        focalPointDelta: scalePosition.global - preScalePosition.global,
      ));
    }
  }

  @override
  void onTouchUp(int pointer, DragEndDetails details) {
    if (!activePointer.containsKey(pointer)) {
      return;
    }
    if (isDrag) {
      isDrag = false;
      _cancelLongPressTimer();
      onDragEnd(details);
    } else if (isLongPress) {
      final position = activePointer[pointer]!;
      isLongPress = false;
      onLongPressEnd(LongPressEndDetails(
        globalPosition: position.global,
        localPosition: position.local,
        velocity: details.velocity,
      ));
    } else if (isScale) {
      isScale = false;
      isDrag = true;
      onScaleEnd(ScaleEndDetails(
        velocity: details.velocity,
        pointerCount: 2,
      ));
    }
    activePointer.remove(pointer);
  }

  @override
  void onTouchCancel(int pointer) {
    if (!activePointer.containsKey(pointer)) {
      return;
    }
    if (isDrag) {
      isDrag = false;
      _cancelLongPressTimer();
      onDragCancel();
    } else if (isLongPress) {
      isLongPress = false;
      onLongPressCancel();
    } else if (isScale) {
      isScale = false;
      onScaleCancel();
    }
    activePointer.remove(pointer);
  }

  void _startLongPressTimer() {
    _cancelLongPressTimer();

    _longPressTimer = Timer(_longPressDetect, () {
      // print('長按激活');
      _cancelLongPressTimer();
      final entrys = activePointer.entries;
      if (entrys.isEmpty) {
        // print('長按為空, 取消');
        return;
      }
      final position = entrys.first;
      isDrag = false;
      isLongPress = true;
      onLongPressStart(LongPressStartDetails(
        globalPosition: position.value.global,
        localPosition: position.value.local,
      ));
    });
  }

  void _cancelLongPressTimer() {
    if (_longPressTimer != null && _longPressTimer!.isActive) {
      _longPressTimer!.cancel();
    }
    _longPressTimer = null;
  }
}

class _PointerPosition {
  final Offset global;
  final Offset local;

  _PointerPosition({required this.global, required this.local});

  _PointerPosition.fromDragStart(DragStartDetails details)
      : global = details.globalPosition,
        local = details.localPosition;

  _PointerPosition.fromDragUpdate(DragUpdateDetails details)
      : global = details.globalPosition,
        local = details.localPosition;
}
