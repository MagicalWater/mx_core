part of '../animated_core.dart';

/// 縮放動畫
class _ScaleValue extends AnimatedValue<double> {
  _ScaleType type;

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

  _ScaleValue._(
      this.type, {
        this.begin = 1.0,
        this.end = 1.0,
        this.delayed,
        this.duration,
        this.curve,
        this.alignment,
      });
}

/// 縮放類型
enum _ScaleType {
  all,
  width,
  height,
}