import 'package:flutter/cupertino.dart';

class TabIndicator {
  final Decoration decoration;
  final double height;
  final Alignment alignment;
  final double maxWidth;
  final Duration duration;
  final Curve curve;
  final Color color;

  /// 指示器的位置 [上或下]
  final VerticalDirection position;

  TabIndicator({
    this.decoration,
    this.color,
    this.maxWidth,
    this.height = 1,
    this.alignment = Alignment.center,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.fastOutSlowIn,
    this.position = VerticalDirection.down,
  });
}
