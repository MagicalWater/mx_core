import 'package:flutter/widgets.dart';
import 'package:mx_core/router/router.dart';
import 'package:mx_core/ui/widget/refresh_view/refresh_view.dart';
import 'package:rxdart/rxdart.dart';

import 'bloc_provider.dart';

/// 針對一個頁面的 bloc 進行封裝
/// 可藉由繼承此類 註冊/跳轉 route / 設置 loading 狀態 / 取得子頁面相關功能
abstract class PageBloc implements RouteMixinBase, BlocBase {
  RouteOption option;

  /// 由此宣告頁面的 route
  final String route;

  PageBloc(
    this.route,
    this.option,
  ) {
    _registerSubPageStream(defaultRoute: defaultSubPage());
  }

  /// 子頁面命令監聽串流
  Stream<RouteData> get subPageStream => _subPageSubject?.stream;

  /// 當前子頁面的 index 串流
  Stream<int> get subPageIndexStream =>
      subPageStream?.map((data) => subPages().indexOf(data.route));

  /// 當前最後顯示的子頁面
  ///
  /// 可能會是 null
  RouteData get currentSubPage => _subPageSubject?.value;

  /// 當前最後顯示的子頁面的index
  ///
  /// 可能會是 null
  int get currentSubPageIndex {
    var current = currentSubPage;
    if (current != null) {
      return subPages().indexOf(current.route);
    }
    return null;
  }

  /// 當前一般元件的 loading 狀態
  bool get currentLoadState {
    return _lazyLoadSubject.value ?? false;
  }

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

  /// LoadProvider subject 以及 stream
  Stream<bool> get loadStream {
    return _lazyLoadSubject.stream;
  }

  /// 刷新元件 [RefreshView] 的狀態流
  Stream<RefreshState> get refreshStream {
    return _lazyRefreshStateSubject.stream;
  }

  /// 子頁面監聽串流
  BehaviorSubject<RouteData> _subPageSubject;

  /// 設置刷新元件 [RefreshView] 的狀態
  BehaviorSubject<RefreshState> _refreshStateSubject;

  BehaviorSubject<RefreshState> get _lazyRefreshStateSubject {
    return _refreshStateSubject ??= BehaviorSubject();
  }

  /// LoadProvider loading 狀態串流
  BehaviorSubject<bool> _loadSubject;

  BehaviorSubject<bool> get _lazyLoadSubject {
    return _loadSubject ??= BehaviorSubject();
  }

  /// 將刷新狀態設置為讀取中
  /// 此狀態的設置並不會觸發 [RefreshView] 的 onRefresh 方法
  /// * [bounce] 是否顯示頂部 loading, 若 false 則只顯示中間
  void refreshing([bool bounce = false]) {
    var state = RefreshState.loading(
      type: RefreshType.refresh,
      bounce: bounce,
    );
    _lazyRefreshStateSubject.add(state);
  }

  /// 設置為正在加載更多中
  /// 此狀態的設置並不會觸發 [RefreshView] 的 onLoadMore 方法
  /// * [bounce] 是否顯示底部 loading, 若 false 則只顯示中間
  void loadingMore([bool bounce = false]) {
    var state = RefreshState.loading(
      type: RefreshType.loadMore,
      bounce: bounce,
    );
    _lazyRefreshStateSubject.add(state);
  }

  /// 設置刷新的結果
  /// * [success] - 刷新是否成功
  /// * [empty] - 刷新是否為空
  /// * [noMore] - 是否沒有更多刷新
  /// * [resetLoadMore] - 是否重置上拉加載狀態
  /// * [noLoadMore] - 是否沒有上拉加載了, 此參數優先度在 [resetLoadMore] 之上
  void setRefresh({
    bool success,
    bool empty = false,
    bool noMore = false,
    bool resetLoadMore = true,
    bool noLoadMore,
  }) {
    var state = RefreshState.refresh(
      success: success,
      empty: empty,
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
  void setLoadMore({
    bool success,
    bool empty = false,
    bool noMore = false,
    bool resetRefresh = false,
  }) {
    var state = RefreshState.loadMore(
      success: success,
      empty: empty,
      noMore: noMore,
      resetRefresh: resetRefresh,
    );
    _lazyRefreshStateSubject.add(state);
  }

  /// 一般元件 loading 狀態
  void setLoadState(bool state) {
    _lazyLoadSubject.add(state);
  }

  /// 此頁面的預設子頁面
  @protected
  RouteData defaultSubPage() => null;

  /// 是否接受處理子頁面的跳轉
  @protected
  bool isSubPageHandle(RouteData routeData) => true;

  /// 切換子頁面到下一個子頁面
  void setSubPageToNext() {
    if (subPages().isNotEmpty) {
      var totalLength = subPages().length;
      int nextIndex;

      // 檢查當前是否有子頁面
      if (currentSubPageIndex == null) {
        // 當前沒有子頁面, 直接設置為第0個
        nextIndex = 0;
        setSubPage(subPages()[nextIndex]);
      } else {
        nextIndex = currentSubPageIndex + 1 >= totalLength
            ? 0
            : currentSubPageIndex + 1;

        // 檢查下個頁面是否與當前頁面為同一個
        if (nextIndex != currentSubPageIndex) {
          setSubPage(subPages()[nextIndex]);
        }
      }
    }
  }

  @mustCallSuper
  @override
  Future<void> dispose() async {
    // 取消子頁面監聽
    if (route != null && route.isNotEmpty) {
      routeMixinImpl?.unregisterSubPageListener(route);
    }

    await _refreshStateSubject?.drain();
    await _refreshStateSubject?.close();
    _refreshStateSubject = null;

    // 先丟棄 subject 裡的所有數據在進行close
    await _subPageSubject?.drain();
    await _subPageSubject?.close();
    _subPageSubject = null;

    await _loadSubject?.drain();
    await _loadSubject?.close();
    _loadSubject = null;
  }

  /// 此 bloc 底下有哪些子頁面
  List<String> subPages() {
    if (route != null && route.isNotEmpty) {
      return _getSubPages(route);
    } else {
      return [];
    }
  }

  /// 註冊 [page] 的子頁面監聽
  /// [defaultSubPage] - 預設子頁面
  void _registerSubPageStream({RouteData defaultRoute}) {
    if (_subPageSubject != null) {
      print("已註冊, 禁止再次註冊監聽子頁面");
      return;
    }
    if (route != null && route.isNotEmpty) {
      // 檢查此page底下是否有 sub page, 沒有的話就不開 subject
//      if (subPages().isNotEmpty) {
      _subPageSubject = BehaviorSubject();

      routeMixinImpl.registerSubPageListener(route, (RouteData data) {
        return _dispatchSubPage(data);
      });

//        print("檢查是否需要自動跳轉子頁面: ${option.route}, ${option.targetSubRoute}");
      if (option.nextRoute != null && option is RouteData) {
        // 需要再往下進行跳轉頁面
        var data = option as RouteData;
        routeMixinImpl.setSubPage(
          data.targetSubRoute,
          pageQuery: data.widgetQuery,
          blocQuery: data.blocQuery,
          checkToHistory: !data.isPop,
        );
      } else if (defaultRoute != null) {
        // 需要跳轉預設子頁面
        routeMixinImpl.setSubPage(
          defaultRoute.route,
          pageQuery: defaultRoute.widgetQuery,
          blocQuery: defaultRoute.blocQuery,
        );
      }
//      }
    } else {
      print("註冊子頁面失敗 - pageRoute 不得為空");
    }
  }

  /// 子頁面跳轉分發
  bool _dispatchSubPage(RouteData data) {
    // 檢查是否為自己
    if (data.route == route) {
      var old = option;
      this.option = data;
      didUpdateOption(old);
      return true;
    } else if (subPages().contains(data.route) && isSubPageHandle(data)) {
      // 在此確認是否處理此子頁面的跳轉
      _subPageSubject.add(data);
      return true;
    }
    return false;
  }

  /// 取得 [page] 的所有子頁面
  List<String> _getSubPages(String page) {
    return routeWidgetImpl.pageList
        .where((e) => RouteCompute.isSubPage(page, e))
        .toList();
  }

  /// 當監聽到頁面跳轉為自己時, 呼叫 didUpdateBloc
  @mustCallSuper
  @protected
  void didUpdateOption(RouteOption oldOption) {}

  /// **************** 以下為間接調用 RouteMixin 相關方法 ****************

  /// 取得子頁面
  @override
  Widget getSubPage(RouteData data) => routeMixinImpl?.getSubPage(data);

  /// 取得路由為 [page] 的頁面是否顯示中
  @override
  bool isPageShowing(String page) => routeMixinImpl?.isPageShowing(page);

  /// 返回的同時再 push
  /// [route] - 將要 push 的頁面
  /// [subRoute] - 跳轉到此大頁面底下的這個子頁面
  /// [popUtil] - pop 直到返回true
  /// [result] - 要返回給前頁面的結果, 當 [popUtil] 為空時有效
  @override
  Future<T> popAndPushPage<T>(String route, BuildContext context,
          {String subRoute,
          Map<String, dynamic> pageQuery,
          Map<String, dynamic> blocQuery,
          popUntil,
          Object result}) =>
      routeMixinImpl?.popAndPushPage(route, context,
          pageQuery: pageQuery,
          blocQuery: blocQuery,
          popUntil: popUntil,
          result: result);

  @override
  bool popPage(BuildContext context,
          {bool Function(String route) popUntil, Object result}) =>
      routeMixinImpl?.popPage(context, popUntil: popUntil, result: result);

  /// 發起大頁面跳轉
  /// [subRoute] - 跳轉到此大頁面底下的這個子頁面
  /// [replaceCurrent] - 替換掉當前頁面, 即無法再返回當前頁面
  /// [removeUtil] - 刪除舊頁面直到返回true
  /// [builder] - 自定義構建 PageRoute
  @override
  Future<T> pushPage<T>(String route, BuildContext context,
          {String subRoute,
          Map<String, dynamic> pageQuery,
          Map<String, dynamic> blocQuery,
          bool replaceCurrent = false,
          bool Function(String route) removeUntil,
          MixinRouteBuilder builder}) =>
      routeMixinImpl?.pushPage(route, context,
          subRoute: subRoute,
          pageQuery: pageQuery,
          blocQuery: blocQuery,
          replaceCurrent: replaceCurrent,
          removeUntil: removeUntil,
          builder: builder);

  /// 跳轉子頁面
  @override
  bool setSubPage(String route,
          {BuildContext context,
          Map<String, dynamic> pageQuery,
          Map<String, dynamic> blocQuery,
          bool replaceCurrent = false}) =>
      routeMixinImpl?.setSubPage(route,
          context: context,
          pageQuery: pageQuery,
          blocQuery: blocQuery,
          replaceCurrent: replaceCurrent);
}
