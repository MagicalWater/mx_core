part of 'comb.dart';

/// 單純進行delay
class CombDelay extends Comb<void> {
  @override
  void begin;

  @override
  void end;

  @override
  int? delayed;

  @override
  int? duration;

  @override
  Curve? curve;

  @override
  int totalDuration(int defaultDuration) => duration ?? defaultDuration;

  CombDelay._({
    this.duration,
  });
}
