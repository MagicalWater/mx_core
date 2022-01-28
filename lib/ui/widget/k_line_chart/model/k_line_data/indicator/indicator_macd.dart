/// 指數平滑異同移動平均線
class IndicatorMACD {
  final double dea;
  final double dif;
  final double macd;
  final double ema12;
  final double ema26;

  IndicatorMACD({
    required this.dea,
    required this.dif,
    required this.macd,
    required this.ema12,
    required this.ema26,
  });
}
