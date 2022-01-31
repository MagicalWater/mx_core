import 'chart_indicator_calculate.dart';
import 'indicator/indicator.dart';
import 'indicator/indicator_kdj.dart';
import 'indicator/indicator_rsi.dart';
import 'indicator/indicator_wr.dart';

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
  /// 收盤價均線
  IndicatorMa? ma;

  /// boll線
  IndicatorBOLL? boll;

  /// 指數平滑異同移動平均線
  IndicatorMACD? macd;

  /// 相對強弱指標
  IndicatorRSI? rsi;

  /// 隨機指標
  IndicatorKDJ? kdj;

  /// 威廉指標(兼具超買超賣和強弱分界的指標)
  IndicatorWR? wr;
}

extension IndicatorCalculateExtension on List<KLineData> {
  /// 計算所有技術指標
  /// [maPeriods] - 收盤均線週期
  /// [bollPeriod] - boll線週期
  void calculateAllIndicator({
    List<int> maPeriods = const [5, 10, 20],
    int bollPeriod = 20,
  }) {
    ChartIndicatorCalculator.calculateAllIndicator(
      this,
      maPeriods: maPeriods,
      bollPeriod: bollPeriod,
    );
  }

  /// 計算收盤價均線
  void calculateMA(List<int> periods) {
    ChartIndicatorCalculator.calculateMA(periods, this);
  }

  /// 計算boll線
  void calculateBOLL(int period) {
    ChartIndicatorCalculator.calculateBOLL(period, this);
  }

  /// 計算指數平滑異同移動平均線
  void calculateMACD() {
    ChartIndicatorCalculator.calculateMACD(this);
  }

  /// 計算相對強弱指標
  void calculateRSI() {
    ChartIndicatorCalculator.calculateRSI(this);
  }

  /// 計算隨機指標
  void calculateKDJ() {
    ChartIndicatorCalculator.calculateKDJ(this);
  }

  /// 計算威廉指標(兼具超買超賣和強弱分界的指標)
  void calculateWR() {
    ChartIndicatorCalculator.calculateWR(this);
  }
}
