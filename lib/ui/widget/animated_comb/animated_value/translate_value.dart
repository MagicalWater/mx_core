part of 'comb.dart';

/// 位移動畫
class CombTranslate extends Comb<Offset> {
  TransType type;

  @override
  Offset begin;

  @override
  Offset end;

  @override
  int? delayed;

  @override
  int? duration;

  @override
  Curve? curve;

  CombTranslate._(
    this.type, {
    required this.begin,
    required this.end,
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
