part of '../animated_core.dart';

/// 單純進行delay
class _DelayValue extends AnimatedValue<void> {
  @override
  void begin;

  @override
  void end;

  @override
  int delayed;

  @override
  int duration;

  @override
  Curve curve;

  @override
  Alignment alignment;

  int totalDuration(int defaultDuration) => duration ?? defaultDuration;

  _DelayValue._({
    this.duration,
  });
}