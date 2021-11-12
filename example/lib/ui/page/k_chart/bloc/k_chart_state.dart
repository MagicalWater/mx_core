part of 'k_chart_bloc.dart';

@immutable
class KChartState {
  final bool isLoading;
  final List<KLineEntity> datas;
  final MainState mainState;
  final SecondaryState secondaryState;

  final bool isLine;
  final List<DepthEntity> bids, asks;

  KChartState({
    required this.isLoading,
    this.datas = const [],
    this.mainState = MainState.MA,
    this.secondaryState = SecondaryState.MACD,
    this.isLine = false,
    this.bids = const [],
    this.asks = const [],
  });

  KChartState copyWith({
    bool? isLoading,
    bool? isLine,
    List<KLineEntity>? datas,
  }) {
    return KChartState(
      isLoading: isLoading ?? this.isLoading,
      datas: datas ?? this.datas,
      mainState: mainState,
      secondaryState: secondaryState,
      isLine: isLine ?? this.isLine,
      bids: bids,
      asks: asks,
    );
  }
}
