part of 'animated_core.dart';

/// 動畫控制器
abstract class AnimatedCoreController {
  /// 動畫開關(只在動畫行為是 [AnimatedBehavior.toggle] 時有效)
  /// 當 [value] 為 null 時直接切換開關
  /// 不為 null 則直接設置
  Future<void> toggle([bool value]);

  /// 執行一次動畫
  /// 當動畫行為是為以下幾種時有效
  /// [AnimatedBehavior.toggle]
  /// [AnimatedBehavior.tap]
  /// [AnimatedBehavior.once]
  /// [AnimatedBehavior.onceReverse]
  Future<void> once();

  /// 設置動畫行為
  Future<void> setBehavior(AnimatedBehavior behavior, [bool toggleValue]);
}

/// 動畫行為
enum AnimatedBehavior {
  /// 重複執行(會動畫恢復)
  repeatReverse,

  /// 重複執行(不動畫恢復)
  repeat,

  /// 只執行一次(會動畫恢復)
  onceReverse,

  /// 只執行一次
  once,

  /// 動畫擁有開關設置[ToggleController], 由外部決定行為
  toggle,

  /// 按下執行動畫, 放開結束動畫
  tap,
}
