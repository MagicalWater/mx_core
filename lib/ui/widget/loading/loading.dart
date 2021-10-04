import 'package:flutter/material.dart';

import 'widget/widget.dart';

/// 動畫集合
class Loading {
  /// 拉伸位移
  static Spring spring({
    int springMultiple = 1,
    double size = 50,
    int duration = 500,
    BoxDecoration? decoration,
    Color? color,
    Axis direction = Axis.horizontal,
  }) =>
      Spring(
        springMultiple: springMultiple,
        size: size,
        duration: duration,
        color: color,
        direction: direction,
        decoration: decoration,
      );

  /// 方形拉伸位移
  static RoundSpring roundSpring({
    int ballCount = 1,
    int springMultiple = 1,
    double size = 50,
    int duration = 500,
    BoxDecoration? decoration,
    Color? color,
  }) =>
      RoundSpring(
        ballCount: ballCount,
        springMultiple: springMultiple,
        size: size,
        duration: duration,
        decoration: decoration,
        color: color,
      );

  /// 透明漸變圓環
  static FadeCircle circle({
    double size = 50,
    int duration = 1000,
    BoxDecoration? decoration,
    Color? color,
    int count = 12,
    int headCount = 1,
  }) =>
      FadeCircle(
        size: size,
        duration: duration,
        decoration: decoration,
        color: color,
        count: count,
        headCount: headCount,
      );
}
