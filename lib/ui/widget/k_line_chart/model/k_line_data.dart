/// k線圖表資料
class KLineData with KLineMaMixin {
  /// 開盤價
  final double open;

  /// 至高點
  final double high;

  /// 至低點
  final double low;

  /// 收盤價
  final double close;

  /// 成交量(手數)
  final int volume;

  /// 成交金額
  final double amount;

  /// 時間日期
  final DateTime dateTime;

  KLineData({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.amount,
    required this.dateTime,
  });
}

mixin KLineMaMixin {
  /// 各個週期的ma價
  final Map<int, double> ma = {};
}
