part of '../animated_core.dart';

/// 透明值動畫
class _OpacityValue extends AnimatedValue<double> {
  @override
  double begin;

  @override
  double end;

  @override
  int delayed;

  @override
  int duration;

  @override
  Curve curve;

  @override
  Alignment alignment;

  _OpacityValue._({
    this.begin = 1.0,
    this.end = 1.0,
    this.delayed,
    this.duration,
    this.curve,
  });
}