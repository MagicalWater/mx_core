import 'package:flutter/widgets.dart';
import 'package:mx_core/bloc/bloc.dart';
import 'package:mx_core/bloc/load_mixin.dart';
import 'package:mx_core/bloc/page_route_mixin.dart';
import 'package:mx_core/bloc/refresh_mixin.dart';
import 'package:mx_core/extension/extension.dart';
import 'package:mx_core/router/router.dart';
import 'package:rxdart/rxdart.dart';

/// 針對一個頁面的 bloc 進行封裝
/// 可藉由繼承此類 註冊/跳轉 route / 設置 loading 狀態 / 取得子頁面相關功能
abstract class PageBloc
    with LoadMixin, RefreshMixin, PageRouteMixin
    implements BlocBase, PageBlocInterface {
  RouteOption option;

  /// 快取頁面數量
  /// 當 [historyShow] 是 [HistoryShow.stack] 時無效
  int get cachePageCount => subPages().length;

  BlocProviderState? providerState;

  bool get mounted => providerState?.mounted ?? false;

  /// 子頁面的加入方式
  /// 默認使用 [HistoryShow.tab]
  final HistoryShow historyShow;

  /// 由此宣告頁面的 route
  @override
  final String route;

  PageBloc(
    this.route,
    this.option, {
    this.historyShow = HistoryShow.tab,
  });

  @override
  List<RouteData> get subPageHistory => _historyPageSubject.valueOrNull ?? [];

  /// 子頁面命令監聽串流
  Stream<List<RouteData>> get subPageHistoryStream =>
      _historyPageSubject.stream;

  /// 當前子頁面的 index 串流
  Stream<int?> get subPageIndexStream => subPageHistoryStream.map((data) {
        var currentRoute = data.lastOrNull?.route;
        if (currentRoute != null) {
          var index = subPages().indexOf(currentRoute);
          if (index == -1) {
            return null;
          } else {
            return index;
          }
        } else {
          return null;
        }
      });

  /// 當前最後顯示的子頁面
  ///
  /// 可能會是 null
  @override
  RouteData? get currentSubPage => _historyPageSubject.valueOrNull?.lastOrNull;

  /// 當前最後顯示的子頁面的index
  ///
  /// 可能會是 null
  int? get currentSubPageIndex {
    if (currentSubPage != null) {
      return subPages().indexOf(currentSubPage!.route);
    }
    return null;
  }

  /// 歷史子頁面監聽串流
  late BehaviorSubject<List<RouteData>> _historyPageSubject;

  bool _isInit = false;

  /// 此頁面的預設子頁面
  RouteData? defaultSubPage() => null;

  /// 是否接受處理子頁面的跳轉
  @protected
  bool isSubPageHandle(RouteData routeData) => true;

  /// 切換子頁面到下一個子頁面
  void toNextSubPage() {
    if (historyShow == HistoryShow.stack) {
      print('疊層式子頁面不支持 setSubPageToNext 方法');
      return;
    }

    if (subPages().isNotEmpty) {
      var totalLength = subPages().length;
      int nextIndex;

      // 檢查當前是否有子頁面
      if (currentSubPageIndex == null) {
        // 當前沒有子頁面, 直接設置為第0個
        nextIndex = 0;
        routeMixinImpl.pushPage(subPages()[nextIndex]);
      } else {
        nextIndex = currentSubPageIndex! + 1 >= totalLength
            ? 0
            : currentSubPageIndex! + 1;

        // 檢查下個頁面是否與當前頁面為同一個
        if (nextIndex != currentSubPageIndex) {
          routeMixinImpl.pushPage(subPages()[nextIndex]);
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
    routeMixinImpl.unregisterSubPageListener(this);

    // 先丟棄 subject 裡的所有數據在進行close
    _historyPageSubject.drain();
    _historyPageSubject.close();

    loadDispose();
    refreshDispose();
  }

  /// 此 bloc 底下有哪些子頁面
  List<String> subPages() {
    if (route.isNotEmpty) {
      return _getSubPages(route);
    } else {
      return [];
    }
  }

  /// 註冊 [page] 的子頁面監聽
  /// [defaultSubPage] - 預設子頁面
  void registerSubPageStream({RouteData? defaultRoute}) {
    if (_isInit) {
      print("已註冊, 禁止再次註冊監聽子頁面: $route, $hashCode");
      return;
    }

    _isInit = true;
    _historyPageSubject = BehaviorSubject();

    print('註冊頁面: $route, $hashCode');
    routeMixinImpl.registerSubPageListener(
      page: this,
      isHandleRoute: _isHandleRoute,
      dispatchSubPage: _dispatchSubPage,
      popSubPage: _popSubPage,
      forceModifyPageDetail: _forceModifyPageDetail,
      notifyUpdate: _notifyUpdate,
    );

    print("檢查是否需要自動跳轉子頁面: ${option.route}, ${option.targetSubRoute}");
    if (option.nextRoute != null && option is RouteData) {
      // 需要再往下進行跳轉頁面
      var data = option as RouteData;

      routeMixinImpl.pushPage(
        data.targetSubRoute!,
        pageQuery: data.widgetQuery,
        blocQuery: data.blocQuery,
      );
    } else if (defaultRoute != null) {
      print('跳轉預設子頁面: ${defaultRoute.route}');
      // 需要跳轉預設子頁面
      routeMixinImpl.pushPage(
        defaultRoute.route,
        pageQuery: defaultRoute.widgetQuery,
        blocQuery: defaultRoute.blocQuery,
      );
    }
  }

  bool _isHandleRoute(RouteData data) {
    return subPages().contains(data.route) && isSubPageHandle(data);
  }

  /// 子頁面跳轉分發
  bool _dispatchSubPage(
    RouteData data, {
    bool Function(String route)? popUntil,
  }) {
    if (_isHandleRoute(data)) {
      // 在此確認是否處理此子頁面的跳轉
//      print('接收跳轉請求: ${data.route}');
      switch (historyShow) {
        case HistoryShow.stack:
          _stackDispatchPage(data, popUntil: popUntil);
          break;
        case HistoryShow.tab:
          _tabDispatchPage(data, popUntil: popUntil);
          break;
      }

      return true;
    }
    return false;
  }

  /// 貯列式分發頁面
  /// 若分發了頁面, 但由於
  void _stackDispatchPage(
    RouteData data, {
    bool Function(String route)? popUntil,
  }) {
    var currentHistory = subPageHistory;

    // 判斷當前頁面是否為同個頁面
    // 若為同個頁面則不在疊一層
    // 除非為 forceNew
    if (currentHistory.isNotEmpty) {
      var lastPage = currentHistory.last;
      if (lastPage.route == data.route && !data.forceNew) {
        currentHistory.removeLast();
      }
    }

    currentHistory.add(data);

    if (currentHistory.length > 1 && popUntil != null) {
      bool isKeep = false;
      while (!isKeep && currentHistory.length > 1) {
        isKeep = popUntil(currentHistory[currentHistory.length - 2].route);
        if (!isKeep) {
          currentHistory.removeAt(currentHistory.length - 2);
        }
      }
    }

    _historyPageSubject.add(currentHistory);
  }

  /// tab式分發頁面
  void _tabDispatchPage(
    RouteData data, {
    bool Function(String route)? popUntil,
  }) {
    var currentHistory = subPageHistory;

    // 判斷頁面是否已經存在歷史裡面
    var findHistoryIndex =
        currentHistory.indexWhere((element) => element.route == data.route);

    if (findHistoryIndex != -1) {
      // 曾經在歷史裡面, 調換位置
      currentHistory.removeAt(findHistoryIndex);
    }

    currentHistory.add(data);

    // 檢測歷史長度是否超過快取
    if (currentHistory.length > cachePageCount) {
      currentHistory =
          currentHistory.sublist(currentHistory.length - cachePageCount);
    }

    // 檢測是否可以刪除以前的頁面
    if (currentHistory.length > 1 && popUntil != null) {
      bool isKeep = false;
      while (!isKeep && currentHistory.length > 1) {
        isKeep = popUntil(currentHistory[currentHistory.length - 2].route);
        if (!isKeep) {
          currentHistory.removeAt(currentHistory.length - 2);
        }
      }
    }

    _historyPageSubject.add(currentHistory);
  }

  /// 通知頁面刷新
  void _notifyUpdate() {
    providerState?.notifyUpdate();
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

  String? _popSubPage({bool Function(String route)? popUntil}) {
    if (subPageHistory.length >= 2) {
      var currentHistory = List<RouteData>.from(subPageHistory);
      if (popUntil != null) {
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
        currentHistory.removeLast();
//      print('剩餘子頁面: ${_historyPageSubject.value.map((e) => e.route)}');
        currentHistory.last.isPop = true;
        _historyPageSubject.add(currentHistory);
        return currentHistory.last.route;
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

/// 此頁面的歷史記錄類型
enum HistoryShow {
  /// 與 navigator 相同, 一層疊著一層
  stack,

  /// 用於 tab 上, 每個子頁面都是唯一的
  tab,
}
