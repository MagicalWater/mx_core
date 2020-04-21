part of '../animated_core.dart';

/// size 動畫
class _WidthValue extends AnimatedValue<double> {
  @override
  double begin;

  @override
  int delayed;

  @override
  int duration;

  @override
  double end;

  @override
  Curve curve;

  @override
  Alignment alignment;

  _WidthValue._({
    this.begin,
    this.end,
    this.delayed,
    this.duration,
    this.curve,
  });
}

/// size 動畫
class _HeightValue extends AnimatedValue<double> {
  @override
  double begin;

  @override
  int delayed;

  @override
  int duration;

  @override
  double end;

  @override
  Curve curve;

  @override
  Alignment alignment;

  _HeightValue._({
    this.begin,
    this.end,
    this.delayed,
    this.duration,
    this.curve,
  });
}