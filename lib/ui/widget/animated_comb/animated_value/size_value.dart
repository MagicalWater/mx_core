part of 'comb.dart';

/// size 動畫
class CombSize extends Comb<Size> {
  SizeType type;

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

  CombSize._(
    this.type, {
    required this.begin,
    required this.end,
    this.delayed,
    this.duration,
    this.curve,
  });
}

/// size類型
enum SizeType {
  all,
  width,
  height,
}
