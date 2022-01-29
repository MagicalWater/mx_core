import 'package:flutter/gestures.dart';

/// 需要處理的手勢
abstract class GestureHandleNew {
  void onTouchDown(int pointer, DragStartDetails details);

  void onTouchUpdate(int pointer, DragUpdateDetails details);

  void onTouchUp(int pointer, DragEndDetails details);

  void onTouchCancel(int pointer);
}
