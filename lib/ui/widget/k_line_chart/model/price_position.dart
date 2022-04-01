/// 價格標示y軸位置獲取
/// [rightSpace] - 最新價格距離最右側的距離, 0代表最新價格不可見
/// [valueToY] - 傳入price, 轉化成對應的y軸
typedef PricePositionGetter = void Function(
  double rightSpace,
  double Function(double price) valueToY,
);

/// 價格的位置
class PricePosition {
  /// 畫布最大的寬度
  final double canvasWidth;

  /// 最新一筆的價格
  final double? lastPrice;

  /// 對應[PricePositionGetter]的[rightSpace]
  final double rightSpace;

  /// 對應[PricePositionGetter]的[valueToY]
  final double Function(double price) valueToY;

  PricePosition({
    required this.canvasWidth,
    required this.rightSpace,
    required this.valueToY,
    required this.lastPrice,
  });
}
