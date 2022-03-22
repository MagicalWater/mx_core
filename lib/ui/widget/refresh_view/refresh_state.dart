/// 元件狀態
class RefreshState {
  final bool isInit;

  final RefreshType type;

  /// 是否為空內容元件
  final bool empty;

  /// 是否刷新成功
  final bool success;

  /// 是否已是最新資料
  final bool noMore;

  /// 是否正在刷新/加載中
  final bool isLoading;

  /// 上方下拉loading顯示 / 下方上拉loading顯示
  final bool bounce;

  /// 中間的 loading 顯示
  final bool centerLoad;

  /// 重置刷新狀態
  final bool resetRefresh;

  /// 重置加載更多狀態
  final bool resetLoadMore;

  /// 用於刷新之後設置加載更多的 noMore
  final bool? noLoadMore;

  const RefreshState._()
      : isInit = true,
        empty = false,
        success = true,
        noMore = false,
        isLoading = false,
        bounce = true,
        centerLoad = false,
        type = RefreshType.refresh,
        resetRefresh = false,
        resetLoadMore = false,
        noLoadMore = null;

  static const RefreshState none = RefreshState._();

  /// 設置讀取狀態
  /// * [type] - 讀取的類型, 刷新或加載更多
  /// * [bounce] - 是否顯示對應的下拉刷新或者上拉加載, 若 false 則只有中間的 loading
  /// * [centerLoad] - 中央的 loading 顯示, 預設加載更多不會顯示
  const RefreshState.loading({
    this.type = RefreshType.refresh,
    this.bounce = true,
    this.centerLoad = false,
  })  : isInit = false,
        empty = false,
        success = true,
        noMore = false,
        isLoading = true,
        resetRefresh = false,
        resetLoadMore = false,
        noLoadMore = null;

  /// 設置刷新的結果
  const RefreshState.refreshEnd({
    required this.success,
    this.empty = false,
    this.noMore = false,
    this.resetLoadMore = true,
    this.noLoadMore,
  })  : isInit = false,
        isLoading = false,
        bounce = true,
        type = RefreshType.refresh,
        resetRefresh = false,
        centerLoad = false;

  /// 設置加載更多的結果
  const RefreshState.loadMoreEnd({
    required this.success,
    this.empty = false,
    this.noMore = false,
    this.resetRefresh = false,
  })  : isInit = false,
        isLoading = false,
        bounce = true,
        type = RefreshType.loadMore,
        resetLoadMore = false,
        noLoadMore = null,
        centerLoad = false;
}

/// 狀態類型
enum RefreshType {
  /// 刷新
  refresh,

  /// 加載更多
  loadMore,
}