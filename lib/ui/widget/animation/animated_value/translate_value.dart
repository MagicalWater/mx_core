part of '../animated_core.dart';

/// 位移動畫
class _TranslateValue extends AnimatedValue<Offset> {
  @override
  Offset begin;

  @override
  int delayed;

  @override
  int duration;

  @override
  Offset end;

  @override
  Curve curve;

  @override
  Alignment alignment;

  _TranslateValue._({
    this.begin,
    this.end,
    this.delayed,
    this.duration,
    this.curve,
  });
}
