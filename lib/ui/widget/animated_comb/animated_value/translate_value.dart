part of 'comb.dart';

/// 位移動畫
class CombTranslate extends Comb<Offset> {
  TransType type;

  @override
  Offset begin;

  @override
  int delayed;

  @override
  int duration;

  @override
  Offset end;

  @override
  Curve curve;

  CombTranslate._(
    this.type, {
    this.begin,
    this.end,
    this.delayed,
    this.duration,
    this.curve,
  });
}

/// 位移類型
enum TransType {
  all,
  x,
  y,
}
