/// 主圖表的顯示狀態
enum MainChartState {
  /// 蠟燭圖
  kLine,

  /// 指標折線圖(與kLine不可同時存在)
  lineIndex,

  /// 均線
  ma,

  /// boll
  boll,
}