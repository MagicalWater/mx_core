import 'package:flutter/material.dart';

import 'multi_touch_gesture_recognizer/multi_touch_gesture_recognizer.dart';

class TouchGestureDector extends StatefulWidget {
  final void Function(int pointer, DragStartDetails details)? onTouchStart;
  final void Function(int pointer, DragUpdateDetails details)? onTouchUpdate;
  final void Function(int pointer, DragEndDetails details)? onTouchEnd;
  final void Function(int pointer)? onTouchCancel;
  final Widget? child;

  const TouchGestureDector({
    Key? key,
    this.child,
    this.onTouchStart,
    this.onTouchUpdate,
    this.onTouchEnd,
    this.onTouchCancel,
  }) : super(key: key);

  @override
  _TouchGestureDectorState createState() => _TouchGestureDectorState();
}

class _TouchGestureDectorState extends State<TouchGestureDector> {
  /// 手勢觸摸元件的GlobalKey
  /// 用於供給[MultiTouchGestureRecognizer]可進行localPostion的更新
  final GlobalKey<RawGestureDetectorState> gestureKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      key: gestureKey,
      gestures: <Type, GestureRecognizerFactory>{
        MultiTouchGestureRecognizer: MultiTouchGestureRecognizer.factory(
          transformPositionKey: gestureKey,
          onTouchStart: widget.onTouchStart,
          onTouchUpdate: widget.onTouchUpdate,
          onTouchEnd: widget.onTouchEnd,
          onTouchCancel: widget.onTouchCancel,
        ),
      },
      child: widget.child,
    );
  }
}
