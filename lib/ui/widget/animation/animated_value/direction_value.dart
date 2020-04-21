part of '../animated_core.dart';

/// 方向位移動畫
class _DirectionValue extends AnimatedValue<AxisDirection> {
  @override
  AxisDirection begin;

  @override
  int delayed;

  @override
  int duration;

  @override
  AxisDirection end;

  bool outScreen;

  @override
  Curve curve;

  @override
  Alignment alignment;

  _DirectionValue._({
    this.begin,
    this.end,
    this.delayed,
    this.duration,
    this.outScreen = false,
    this.curve,
  });
}