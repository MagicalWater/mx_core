part of 'comb.dart';

/// 縮放動畫
class CombScale extends Comb<Size> {
  ScaleType type;

  @override
  Size begin;

  @override
  Size end;

  @override
  int? delayed;

  @override
  int? duration;

  @override
  Curve? curve;

  CombScale._(
    this.type, {
    this.begin = const Size(1, 1),
    this.end = const Size(1, 1),
    this.delayed,
    this.duration,
    this.curve,
  });
}

/// 縮放類型
enum ScaleType {
  all,
  width,
  height,
}
