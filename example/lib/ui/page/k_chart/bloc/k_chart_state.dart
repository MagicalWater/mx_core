part of 'k_chart_bloc.dart';

@immutable
class KChartState {
  final bool isLoading;
  final List<KLineData> datas;
  final List<MainChartState> mainChartState;
  final VolumeChartState volumeChartState;
  final IndicatorChartState indicatorChartState;

  KChartState({
    required this.isLoading,
    this.datas = const [],
    this.mainChartState = const [MainChartState.kLine, MainChartState.ma],
    this.volumeChartState = VolumeChartState.volume,
    this.indicatorChartState = IndicatorChartState.macd,
  });

  KChartState copyWith({
    bool? isLoading,
    List<KLineData>? datas,
    List<MainChartState>? mainChartState,
    VolumeChartState? volumeChartState,
    IndicatorChartState? indicatorChartState,
  }) {
    return KChartState(
      isLoading: isLoading ?? this.isLoading,
      datas: datas ?? this.datas,
      mainChartState: mainChartState ?? this.mainChartState,
      volumeChartState: volumeChartState ?? this.volumeChartState,
      indicatorChartState: indicatorChartState ?? this.indicatorChartState,
    );
  }
}
