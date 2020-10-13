import 'package:flutter/widgets.dart';
import 'package:mx_core/bloc/bloc.dart';
import 'package:mx_core/bloc/load_mixin.dart';
import 'package:mx_core/bloc/page_route_mixin.dart';
import 'package:mx_core/bloc/refresh_mixin.dart';
import 'package:mx_core/router/router.dart';
import 'package:rxdart/rxdart.dart';

/// 針對一個頁面的 bloc 進行封裝
/// 可藉由繼承此類 註冊/跳轉 route / 設置 loading 狀態 / 取得子頁面相關功能
abstract class PageBloc
    with LoadMixin, RefreshMixin, PageRouteMixin
    implements BlocBase, PageBlocInterface {
  RouteOption option;

  /// 快取頁面數量
  int get cachePageCount => subPages().length;

  BlocProviderState providerState;

  bool get mounted => providerState?.mounted ?? false;

  /// 由此宣告頁面的 route
  @override
  final String route;

  PageBloc(
    this.route,
    this.option,
  );

  @override
  List<RouteData> get subPageHistory => _historyPageSubject.value ?? [];

  /// 子頁面命令監聽串流
  Stream<List<RouteData>> get subPageHistoryStream =>
      _historyPageSubject?.stream;

  /// 當前子頁面的 index 串流
  Stream<int> get subPageIndexStream =>
      subPageHistoryStream?.map((data) => subPages().indexOf(data.last.route));

  /// 當前最後顯示的子頁面
  ///
  /// 可能會是 null
  @override
  RouteData get currentSubPage => _historyPageSubject?.value?.last;

  /// 當前最後顯示的子頁面的index
  ///
  /// 可能會是 null
  int get currentSubPageIndex {
    if (currentSubPage != null) {
      return subPages().indexOf(currentSubPage.route);
    }
    return null;
  }

  /// 歷史子頁面監聽串流
  BehaviorSubject<List<RouteData>> _historyPageSubject;

  /// 此頁面的預設子頁面
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
        routeMixinImpl.setSubPage(subPages()[nextIndex]);
      } else {
        nextIndex = currentSubPageIndex + 1 >= totalLength
            ? 0
            : currentSubPageIndex + 1;

        // 檢查下個頁面是否與當前頁面為同一個
        if (nextIndex != currentSubPageIndex) {
          routeMixinImpl.setSubPage(subPages()[nextIndex]);
        }
      }
    }
  }

  @mustCallSuper
  @override
  void initState() {}

  @mustCallSuper
  @override
  Future<void> dispose() async {
    // 取消子頁面監聽
    if (route != null) {
      routeMixinImpl?.unregisterSubPageListener(this);
    }

    // 先丟棄 subject 裡的所有數據在進行close
    _historyPageSubject?.drain();
    _historyPageSubject?.close();
    _historyPageSubject = null;

    loadDispose();
    refreshDispose();
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
  void registerSubPageStream({RouteData defaultRoute}) {
    if (_historyPageSubject != null) {
      print("已註冊, 禁止再次註冊監聽子頁面: $route, $hashCode");
      return;
    }
    if (route != null && route.isNotEmpty) {
      _historyPageSubject = BehaviorSubject();

      print('註冊頁面: $route, $hashCode');
      routeMixinImpl.registerSubPageListener(
        page: this,
        isHandleRoute: _isHandleRoute,
        dispatchSubPage: _dispatchSubPage,
        popSubPage: _popSubPage,
        forceModifyPageDetail: _forceModifyPageDetail,
      );

      print("檢查是否需要自動跳轉子頁面: ${option.route}, ${option.targetSubRoute}");
      if (option.nextRoute != null && option is RouteData) {
        // 需要再往下進行跳轉頁面
        var data = option as RouteData;

        routeMixinImpl.setSubPage(
          data.targetSubRoute,
          pageQuery: data.widgetQuery,
          blocQuery: data.blocQuery,
        );
      } else if (defaultRoute != null) {
        print('跳轉預設子頁面: ${defaultRoute.route}');
        // 需要跳轉預設子頁面
        routeMixinImpl.setSubPage(
          defaultRoute.route,
          pageQuery: defaultRoute.widgetQuery,
          blocQuery: defaultRoute.blocQuery,
        );
      }
    } else {
      print("註冊子頁面失敗 - pageRoute 不得為空");
    }
  }

  bool _isHandleRoute(RouteData data) {
    return subPages().contains(data.route) && isSubPageHandle(data);
  }

  /// 子頁面跳轉分發
  bool _dispatchSubPage(RouteData data,
      {bool Function(String route) popUntil}) {
    if (_isHandleRoute(data)) {
      // 在此確認是否處理此子頁面的跳轉
//      print('接收跳轉請求: ${data.route}');

      // 判斷頁面是否已經存在歷史裡面
      var findHistoryIndex =
          subPageHistory.indexWhere((element) => element.route == data.route);
      if (findHistoryIndex != -1) {
        // 曾經在歷史裡面, 調換位置
        _historyPageSubject.value.removeAt(findHistoryIndex);
      }

      if (_historyPageSubject.hasValue) {
        var currentHistory = _historyPageSubject.value..add(data);
        if (currentHistory.length > cachePageCount) {
          currentHistory =
              currentHistory.sublist(currentHistory.length - cachePageCount);
        }

        if (popUntil != null) {
          bool isKeep = false;
          while (!isKeep && currentHistory.length > 1) {
            isKeep = popUntil(currentHistory[currentHistory.length - 2].route);
            if (!isKeep) {
              currentHistory.removeAt(currentHistory.length - 2);
            }
          }
        }

        _historyPageSubject.add(currentHistory);
      } else {
        _historyPageSubject.add([data]);
      }
      return true;
    }
    return false;
  }

  /// 強制更改子頁面
  void _forceModifyPageDetail(String route) {
    // 判斷頁面是否已經存在歷史裡面
    var findHistoryIndex =
        subPageHistory.indexWhere((element) => element.route == route);

    if (findHistoryIndex != -1) {
      // 曾經在歷史裡面, 調換位置
      _historyPageSubject.value.removeAt(findHistoryIndex);
    }

    var routeData = RouteData(route);

    if (_historyPageSubject.hasValue) {
      var currentHistory = _historyPageSubject.value..add(routeData);
      if (currentHistory.length > cachePageCount) {
        currentHistory =
            currentHistory.sublist(currentHistory.length - cachePageCount);
      }
      _historyPageSubject.add(currentHistory);
    } else {
      _historyPageSubject.add([routeData]);
    }
  }

  String _popSubPage({bool Function(String route) popUntil}) {
    if (subPageHistory.length >= 2) {
      if (popUntil != null) {
        var currentHistory = _historyPageSubject.value;
        bool isKeep = false;
        while (!isKeep && currentHistory.length > 1) {
          isKeep = popUntil(currentHistory.last.route);
          if (!isKeep) {
            currentHistory.removeLast();
          }
        }
        currentHistory.last.isPop = true;
        _historyPageSubject.add(currentHistory);
        return currentHistory.last.route;
      } else {
        _historyPageSubject.value.removeLast();
//      print('剩餘子頁面: ${_historyPageSubject.value.map((e) => e.route)}');
        _historyPageSubject.value.last.isPop = true;
        _historyPageSubject.add(_historyPageSubject.value);
        return _historyPageSubject.value.last.route;
      }
    }
    return null;
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
}
