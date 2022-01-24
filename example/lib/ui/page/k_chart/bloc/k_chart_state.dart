part of 'k_chart_bloc.dart';

@immutable
class KChartState {
  final bool isLoading;
  final List<KLineEntity> datas;
  final List<KLineData> datas2;
  final MainState mainState;
  final SecondaryState secondaryState;

  final bool isLine;
  final List<DepthEntity> bids, asks;

  KChartState({
    required this.isLoading,
    this.datas = const [],
    this.datas2 = const [],
    this.mainState = MainState.ma,
    this.secondaryState = SecondaryState.macd,
    this.isLine = false,
    this.bids = const [],
    this.asks = const [],
  });

  KChartState copyWith({
    bool? isLoading,
    bool? isLine,
    List<KLineEntity>? datas,
    MainState? mainState,
    SecondaryState? secondaryState,
  }) {
    return KChartState(
      isLoading: isLoading ?? this.isLoading,
      datas: datas ?? this.datas,
      datas2: (datas ?? this.datas).map((e) {
        return KLineData(
          open: e.open,
          high: e.high,
          low: e.low,
          close: e.close,
          volume: e.vol.toInt(),
          amount: e.amount,
          dateTime: e.dateTime,
        );
      }).toList(),
      mainState: mainState ?? this.mainState,
      secondaryState: secondaryState ?? this.secondaryState,
      isLine: isLine ?? this.isLine,
      bids: bids,
      asks: asks,
    );
  }
}
