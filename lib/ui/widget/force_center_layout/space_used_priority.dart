/// 當空間不足以讓三個元件平放時, 需要有優先順序
/// 空間使用優先順序
enum SpaceUsedPriority {
  /// 置中元件優先
  centerFirst,

  /// 左右兩端優先
  bothEndsFirst,
}
