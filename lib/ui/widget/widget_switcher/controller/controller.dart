part of '../widget_switcher.dart';

/// 元件切換控制器
class WidgetSwitchController<T> implements WidgetSwitchControllerAction<T> {
  WidgetSwitchControllerAction<T>? _bind;

  /// 取得歷史元件的標示
  @override
  List<T> get history => _bind?.history ?? [];

  /// 元件往前堆疊含有[tag]標示的元件
  @override
  void push(T tag) {
    _bind?.push(tag);
  }

  /// 回退至[tag]標示的元件
  /// 若[tag]為空, 則是往上一頁
  /// 若元件堆疊著裂中沒有含有flag標示的元件, 則將回退失敗
  @override
  void pop({T? tag, int? count}) {
    _bind?.pop(tag: tag, count: count);
  }
}
