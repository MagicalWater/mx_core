part of 'comb.dart';

/// 單純進行delay
class CombColor extends Comb<Color> {
  @override
  Color begin;

  @override
  Color end;

  @override
  int? delayed;

  @override
  int? duration;

  @override
  Curve? curve;

  CombColor._({
    required this.begin,
    required this.end,
    this.delayed,
    this.duration,
    this.curve,
  });
}
