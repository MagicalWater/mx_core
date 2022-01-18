part of '../widget_switcher.dart';

/// 元件切換控制器
class WidgetSwitchController<T> implements WidgetSwitchControllerAction<T> {
  WidgetSwitchControllerAction<T>? _bind;

  /// 取得歷史元件的標示
  @override
  List<T> get history => _bind?.history ?? [];

  /// 跳轉至[tag]代號的元件
  /// [removeUtil] - 刪除先前的歷史元件, 回傳true代表不再繼續刪除
  @override
  Future<void> push(T tag, {WidgetPopHandler<T>? removeUntil}) async {
    if (_bind == null) {
      print('WidgetSwitchController: 控制器尚未綁定至WidgetSwitcher, 無法進行push');
    }
    return _bind?.push(tag, removeUntil: removeUntil);
  }

  /// 往前回彈頁面, 當[popUntil]為空時代表只彈出一個
  /// [popUntil] - 刪除先前的歷史元件, 回傳true代表不再繼續刪除
  @override
  Future<void> pop({WidgetPopHandler<T>? popUntil}) async {
    if (_bind == null) {
      print('WidgetSwitchController: 控制器尚未綁定至WidgetSwitcher, 無法進行pop');
    }
    return _bind?.pop(popUntil: popUntil);
  }

  /// 清除除了正在顯示中的元件之外的歷史元件
  /// [remove] - 決定每個歷史元件是否清除, 若無帶入, 則默認全部清除
  @override
  void clearHistory({WidgetPopHandler<T>? removeHandler}) {
    if (_bind == null) {
      print('WidgetSwitchController: 控制器尚未綁定至WidgetSwitcher, 無法進行clearHistory');
    }
    _bind?.clearHistory(removeHandler: removeHandler);
  }
}
