import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/repository/chart_repository.dart';

part 'k_chart_event.dart';

part 'k_chart_state.dart';

class KChartBloc extends Bloc<KChartEvent, KChartState> {
  KChartBloc(this.repository)
      : super(KChartState(
          isLoading: false,
        )) {
    on<KChartInitEvent>(_onInitData);
    on<KChartToggleLineEvent>(_onToggleLine);
    on<KChartUpdateLastEvent>(_onUpdateLast);
    on<KChartAddDataEvent>(_onAddData);
  }

  final ChartRepository repository;

  /// 初始化資料
  Future<void> _onInitData(
    KChartInitEvent event,
    Emitter<KChartState> emit,
  ) async {
    var datas = await repository.getData();
    emit(state.copyWith(datas: datas));
  }

  /// 切換線條跟k線
  void _onToggleLine(
    KChartToggleLineEvent event,
    Emitter<KChartState> emit,
  ) {
    emit(state.copyWith(isLine: !state.isLine));
  }

  void _onUpdateLast(
    KChartUpdateLastEvent event,
    Emitter<KChartState> emit,
  ) {
    var data = state.datas.last;
    data.close += (Random().nextInt(100) - 50).toDouble();
    data.high = max(data.high, data.close);
    data.low = min(data.low, data.close);
    ChartDataCalculator.updateLastData(state.datas);
    emit(state.copyWith(datas: state.datas));
  }

  void _onAddData(
    KChartAddDataEvent event,
    Emitter<KChartState> emit,
  ) {
    var lastData = state.datas.last;
    var kLineEntity = KLineEntity.fromJson(lastData.toJson());
    kLineEntity.dateTime = kLineEntity.dateTime.add(Duration(days: 1));
    kLineEntity.open = kLineEntity.close;
    kLineEntity.close += (Random().nextInt(100) - 50).toDouble();
    lastData.high = max(lastData.high, lastData.close);
    lastData.low = min(lastData.low, lastData.close);
    ChartDataCalculator.addLastData(state.datas, kLineEntity);
    emit(state.copyWith(datas: state.datas));
  }
}