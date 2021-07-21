part of 'comb.dart';

/// 旋轉動畫
class CombRotate extends Comb<double> {
  RotateType type;

  @override
  double begin;

  @override
  double end;

  @override
  int? delayed;

  @override
  int? duration;

  @override
  Curve? curve;

  CombRotate._(
    this.type, {
    this.begin = 0.0,
    this.end = 0.0,
    this.delayed,
    this.duration,
    this.curve,
  });
}

/// 旋轉類型
/// [RotateType.z] - 平面旋轉
/// [RotateType.x] - 垂直翻轉
/// [RotateType.y] - 水平翻轉
enum RotateType {
  x,
  y,
  z,
}
