part of '../animated_core.dart';

/// 旋轉動畫
class _RotateValue extends AnimatedValue<double> {
  _RotateType type;

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

  _RotateValue._(
      this.type, {
        this.begin = 0.0,
        this.end = 0.0,
        this.delayed,
        this.duration,
        this.curve,
        this.alignment,
      });
}

/// 旋轉類型
/// [_RotateType.z] - 平面旋轉
/// [_RotateType.x] - 垂直翻轉
/// [_RotateType.y] - 水平翻轉
enum _RotateType {
  x,
  y,
  z,
}