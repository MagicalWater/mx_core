part of 'comb.dart';

/// size 動畫
class CombSize extends Comb<Size> {
  SizeType type;

  @override
  Size begin;

  @override
  int delayed;

  @override
  int duration;

  @override
  Size end;

  @override
  Curve curve;

  CombSize._(
    this.type, {
    this.begin,
    this.end,
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
