/// 剩餘空間的分配方式
enum RemainingSpaceAllocation {
  /// 不進行空間分配, 按照原來大小
  none,

  /// 中間擴展
  centerExpanded,

  /// 兩端擴展
  bothEndsExpanded,
}
