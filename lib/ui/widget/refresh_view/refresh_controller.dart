import 'package:mx_core/ui/widget/refresh_view/refresh_view.dart';
import 'package:rxdart/rxdart.dart';

class RefreshController {
  /// 當前 [RefreshView] 是否正在刷新中
  bool get currentRefresh {
    var state = _lazyRefreshStateSubject.value;
    return state.isLoading && state.type == RefreshType.refresh;
  }

  /// 當前 [RefreshView] 是否正在加載更多中
  bool get currentLoadMore {
    var state = _lazyRefreshStateSubject.value;
    return state.isLoading && state.type == RefreshType.loadMore;
  }

  /// 刷新元件 [RefreshView] 的狀態流
  Stream<RefreshState> get stream {
    return _lazyRefreshStateSubject.stream;
  }

  /// 設置刷新元件 [RefreshView] 的狀態
  BehaviorSubject<RefreshState>? _refreshStateSubject;

  BehaviorSubject<RefreshState> get _lazyRefreshStateSubject {
    return _refreshStateSubject ??= BehaviorSubject()
      ..add(const RefreshState.refreshEnd(success: true));
  }

  /// 將刷新狀態設置為讀取中
  /// 此狀態的設置並不會觸發 [RefreshView] 的 onRefresh 方法
  /// * [bounce] 是否顯示頂部 loading, 若 false 則只顯示中間
  void refreshStart({bool bounce = false, bool center = true}) {
    var state = RefreshState.loading(
      type: RefreshType.refresh,
      bounce: bounce,
      centerLoad: center,
    );
    _lazyRefreshStateSubject.add(state);
  }

  /// 設置為正在加載更多中
  /// 此狀態的設置並不會觸發 [RefreshView] 的 onLoadMore 方法
  /// * [bounce] 是否顯示底部 loading
  /// * [center] 是否顯示中間 loading
  void loadMoreStart({bool bounce = true, bool center = false}) {
    var state = RefreshState.loading(
      type: RefreshType.loadMore,
      bounce: bounce,
      centerLoad: center,
    );
    _lazyRefreshStateSubject.add(state);
  }

  /// 設置刷新的結果
  /// * [success] - 刷新是否成功
  /// * [empty] - 刷新是否為空
  /// * [noMore] - 是否沒有更多刷新
  /// * [resetLoadMore] - 是否重置上拉加載狀態
  /// * [noLoadMore] - 是否沒有上拉加載了, 此參數優先度在 [resetLoadMore] 之上
  void refreshEnd({
    required bool success,
    bool empty = false,
    bool noMore = false,
    bool resetLoadMore = true,
    bool? noLoadMore,
  }) {
    var state = RefreshState.refreshEnd(
      success: success,
      noMore: noMore,
      resetLoadMore: resetLoadMore,
      noLoadMore: noLoadMore,
    );
    _lazyRefreshStateSubject.add(state);
  }

  /// 設置加載更多的結果
  /// * [success] - 加載更多是否成功
  /// * [empty] - 加載更多是否為空
  /// * [noMore] - 是否沒有加載更多
  /// * [resetRefresh] - 是否重置下拉刷新狀態
  void loadMoreEnd({
    required bool success,
    bool noMore = false,
    bool resetRefresh = false,
  }) {
    var state = RefreshState.loadMoreEnd(
      success: success,
      noMore: noMore,
      resetRefresh: resetRefresh,
    );
    _lazyRefreshStateSubject.add(state);
  }

  void dispose() {
    _refreshStateSubject?.close();
    _refreshStateSubject = null;
  }
}
