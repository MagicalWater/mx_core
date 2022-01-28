/// 圖表尺寸設定
class ChartSizeSetting {
  /// 每筆資料占用的寬度
  final double dataWidth;

  /// 背景格線數量
  final int gridRows, gridColumns;

  /// 長按時顯示的十字交叉線豎線寬度
  final double longPressVerticalLineWidth;

  /// 長按時顯示的交叉線橫線高度
  final double longPressHorizontalLineHeight;

  /// k線圖右邊的空格, 用於容納當圖表處於最新狀態時的數值指示
  final double rightSpace;

  /// 長按時, 對應y軸的數值
  final double longPressValue;

  /// 長按時, 數值邊框垂直/橫向padding
  final double longPressValueBorderVerticalPadding;
  final double longPressValueBorderHorizontalPadding;

  /// 長按時, 對應x軸的時間
  final double longPressTime;

  /// 長按時, 時間邊框垂直/橫向padding
  final double longPressTimeBorderVerticalPadding;
  final double longPressTimeBorderHorizontalPadding;

  /// 下方時間軸的文字大小
  final double bottomTimeText;

  const ChartSizeSetting({
    this.dataWidth = 8,
    this.gridRows = 3,
    this.gridColumns = 4,
    this.rightSpace = 70,
    this.longPressVerticalLineWidth = 8,
    this.longPressHorizontalLineHeight = 0.5,
    this.longPressValue = 12,
    this.longPressValueBorderVerticalPadding = 4,
    this.longPressValueBorderHorizontalPadding = 12,
    this.longPressTime = 10,
    this.longPressTimeBorderVerticalPadding = 2,
    this.longPressTimeBorderHorizontalPadding = 12,
    this.bottomTimeText = 10,
  });
}
