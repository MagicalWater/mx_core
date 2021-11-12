part of 'k_chart_bloc.dart';

@immutable
abstract class KChartEvent {}

/// 初始化加載資料事件
class KChartInitEvent extends KChartEvent {}

/// 切換線條與折線
class KChartToggleLineEvent extends KChartEvent {
  final bool isLine;

  KChartToggleLineEvent({required this.isLine});
}

/// 切換主視圖類型
class KChartMainStateEvent extends KChartEvent {
  final MainState state;

  KChartMainStateEvent({required this.state});
}

/// 切換副視圖類型
class KChartSecondaryStateEvent extends KChartEvent {
  final SecondaryState state;

  KChartSecondaryStateEvent({required this.state});
}

/// 更新最後一筆數據
class KChartUpdateLastEvent extends KChartEvent {
  KChartUpdateLastEvent();
}

/// 添加一筆數據
class KChartAddDataEvent extends KChartEvent {
  KChartAddDataEvent();
}
