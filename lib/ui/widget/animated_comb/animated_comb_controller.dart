part of 'animated_comb.dart';

/// 動畫控制器
abstract class AnimatedCombController {
  /// 動畫狀態
  AnimationStatus? get status;

  /// 是否在動畫中
  bool get isAnimating =>
      status == AnimationStatus.forward || status == AnimationStatus.dismissed;

  /// 動畫開關(只在動畫行為是 [AnimatedBehavior.toggle] 時有效)
  /// 當 [value] 為 null 時直接切換開關
  /// 不為 null 則直接設置
  Future<void> toggle([bool? value]);

  /// 執行一次動畫
  /// 當動畫行為是為以下幾種時有效
  /// [AnimatedType.toggle]
  /// [AnimatedType.tap]
  /// [AnimatedType.once]
  /// [AnimatedType.onceReverse]
  Future<void> once();

  /// 設置動畫行為
  Future<void> setType(AnimatedType type, [bool? toggle]);
}
