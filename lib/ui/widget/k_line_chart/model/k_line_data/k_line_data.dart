import 'chart_indicator_calculate.dart';
import 'indicator/indicator.dart';

export 'indicator/indicator.dart';

/// k線圖表資料
class KLineData {
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

  /// 技術指標資料
  final indciatorData = IndciatorData();

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

class IndciatorData {
  IndicatorMa? ma;
  IndicatorBOLL? boll;
  IndicatorMACD? macd;
}

extension IndicatorCalculateExtension on List<KLineData> {
  void calculateMA(List<int> periods) {
    ChartIndicatorCalculator.calculateMA(periods, this);
  }

  void calculateBOLL(int period) {
    ChartIndicatorCalculator.calculateBOLL(period, this);
  }

  void calculateMACD() {
    ChartIndicatorCalculator.calculateMACD(this);
  }
}
