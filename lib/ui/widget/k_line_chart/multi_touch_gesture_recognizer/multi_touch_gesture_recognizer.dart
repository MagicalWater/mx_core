import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:mx_core/ui/widget/k_line_chart/multi_touch_gesture_recognizer/multi_touch_drag.dart';

/// 多點觸控手勢
class MultiTouchGestureRecognizer extends MultiDragGestureRecognizer {
  final void Function(int pointer, DragStartDetails details)? onTouchDown;

  MultiTouchGestureRecognizer({
    Object? debugOwner,
    Set<PointerDeviceKind>? supportedDevices,
    this.onTouchDown,
    void Function(int pointer, DragUpdateDetails details)? onTouchUpdate,
    void Function(int pointer, DragEndDetails details)? onTouchUp,
    void Function(int pointer)? onTouchCancel,
  }) : super(
          debugOwner: debugOwner,
          supportedDevices: supportedDevices,
        ) {
    onStart = (offset) {
      print('kk = $offset');
      final eventEntry = _pointerEvent.entries
          .firstWhere((element) => element.value.position == offset);
      final pointer = eventEntry.key;

      // 自暫存移除事件
      _pointerEvent.remove(pointer);

      return MultiTouchDrag(
        pointer: pointer,
        onUpdate: (details) {
          onTouchUpdate?.call(pointer, details);
        },
        onEnd: (details) {
          onTouchUp?.call(pointer, details);
        },
        onCancel: () {
          onTouchCancel?.call(pointer);
        },
      );
    };
  }

  static GestureRecognizerFactory factory({
    void Function(int pointer, DragStartDetails details)? onTouchStart,
    void Function(int pointer, DragUpdateDetails details)? onTouchUpdate,
    void Function(int pointer, DragEndDetails details)? onTouchEnd,
    void Function(int pointer)? onTouchCancel,
  }) {
    return GestureRecognizerFactoryWithHandlers<MultiTouchGestureRecognizer>(
      () => MultiTouchGestureRecognizer(
        onTouchDown: onTouchStart,
        onTouchUpdate: onTouchUpdate,
        onTouchUp: onTouchEnd,
        onTouchCancel: onTouchCancel,
      ),
      (MultiTouchGestureRecognizer instance) {},
    );
  }

  final _pointerEvent = <int, PointerDownEvent>{};

  @override
  MultiDragPointerState createNewPointerState(PointerDownEvent event) {
    _pointerEvent[event.pointer] = event;

    onTouchDown?.call(
      event.pointer,
      DragStartDetails(
        sourceTimeStamp: event.timeStamp,
        globalPosition: event.position,
        localPosition: event.localPosition,
        kind: event.kind,
      ),
    );

    return _MultiTouchState(event.position, event.kind, gestureSettings);
  }

  @override
  String get debugDescription => 'multi touch';
}

class _MultiTouchState extends MultiDragPointerState {
  _MultiTouchState(Offset initialPosition, PointerDeviceKind kind,
      DeviceGestureSettings? deviceGestureSettings)
      : super(initialPosition, kind, deviceGestureSettings);

  @override
  void checkForResolutionAfterMove() {
    assert(pendingDelta != null);
    if (pendingDelta!.distance > computeHitSlop(kind, gestureSettings)) {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  void accepted(GestureMultiDragStartCallback starter) {
    starter(initialPosition);
  }
}
