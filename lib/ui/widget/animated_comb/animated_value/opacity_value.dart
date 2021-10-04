part of 'comb.dart';

/// 透明值動畫
class CombOpacity extends Comb<double> {
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

  CombOpacity._({
    this.begin = 1.0,
    this.end = 1.0,
    this.delayed,
    this.duration,
    this.curve,
  });
}
