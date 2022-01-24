/// 圖表尺寸設定
class ChartSizeSetting {
  /// 每筆資料占用的寬度
  final double dataWidth;

  /// k線圖的蠟燭寬度
  final double candleWidth;

  /// 蠟燭中間的豎線寬度
  final double candleLineWidth;

  /// volume的柱子寬度
  final double volWidth;

  /// macd的柱子寬度
  final double macdWidth;

  /// 背景格線數量
  final int gridRows, gridColumns;

  /// k線圖右邊的空格, 用於容納當圖表處於最新狀態時的數值指示
  final double rightSpace;

  ChartSizeSetting({
    this.dataWidth = 8,
    this.candleWidth = 7,
    this.candleLineWidth = 1.3,
    this.volWidth = 7,
    this.macdWidth = 7,
    this.gridRows = 3,
    this.gridColumns = 4,
    this.rightSpace = 70,
  });
}
