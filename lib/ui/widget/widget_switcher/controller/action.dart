abstract class WidgetSwitchControllerAction<T> {
  /// 歷史元件堆疊
  List<T> get history;

  /// 跳轉至[tag]代號的元件
  void push(T tag);

  /// 往前回彈頁面
  /// 若[tag]以及[count]都沒帶入值時, 默認回彈1個元件
  /// [tag] - 回彈至[tag]代號的元件
  /// [count] - 回彈[count]數量的元件
  void pop({T? tag, int? count});
}