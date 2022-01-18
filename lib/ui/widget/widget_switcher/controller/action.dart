typedef WidgetPopHandler<T> = bool Function(T tag, int index);

abstract class WidgetSwitchControllerAction<T> {
  /// 歷史元件堆疊
  List<T> get history;

  /// 跳轉至[tag]代號的元件
  /// [removeUtil] - 刪除先前的歷史元件, 回傳true代表不再繼續刪除
  Future<void> push(T tag, {WidgetPopHandler<T>? removeUntil});

  /// 往前回彈頁面, 當[popUntil]為空時代表只彈出一個
  /// [popUntil] - 刪除先前的歷史元件, 回傳true代表不再繼續刪除
  Future<void> pop({WidgetPopHandler<T>? popUntil});

  /// 清除除了正在顯示中的元件之外的歷史元件
  /// [remove] - 決定每個歷史元件是否清除, 若無帶入, 則默認全部清除
  void clearHistory({WidgetPopHandler<T>? removeHandler});
}
