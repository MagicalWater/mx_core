import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core/router/route_compute.dart';
import 'package:rxdart/rxdart.dart';

import 'route_setting.dart';

MixinRouteBuilder _defaultRouteBuilder;

/// 子頁面監聽處理
class _SubPageHandler {
  String route;
  RouteHandler handler;
  int hashCode;

  _SubPageHandler(this.route, this.handler, this.hashCode);
}

enum PopType {
  // 同層的子頁面
  sameLevel,

  // 所有頁面
  all,
}

/// route mixin 類
mixin RouteMixin implements RouteMixinBase, RoutePageBase {
  /// 存放所有監聽子頁面跳轉的 callback
  List<_SubPageHandler> _subPageListener = [];

  /// app 入口頁面的別名
  String _entryPointRouteAlias;

  /// 頁面跳轉紀錄, 包含子頁面
  List<RouteData> _allPageHistory = [];

  /// 所有頁面跳轉歷史紀錄
  List<RouteData> get allPageHistory => _allPageHistory;

  /// 大頁面跳轉紀錄
  List<String> get _pageHistory {
    var history = <String>[];
    _allPageHistory.forEach((e) {
      if (RouteCompute.isAncestorRoute(e.route)) {
        history.add(e.route);
      }
    });
    return history;
  }

  List<String> get pageHistory => _pageHistory;

  /// 所有頁面跳轉串流
  BehaviorSubject<RouteData> _allPageSubject = BehaviorSubject();

  /// 所有頁面跳轉通知串流
  Stream<RouteData> get allPageStream => _allPageSubject.stream;

  /// 大頁面跳轉通知串流
  Stream<String> get pageStream =>
      _allPageSubject.stream.map((e) => _pageHistory.last).distinct();

  /// 當前的大頁面
  String get currentPage => _pageHistory.last;

  /// 取得路由為 [page] 的頁面是否顯示中
  @override
  bool isPageShowing(String page) {
    if (page == "/") {
      print("根結點並非是一個 page");
      return false;
    }
    // 先檢查祖先是否正在顯示中
    var ancestor = RouteCompute.getAncestorRoute(page);
    var isAncestorShow = currentPage == ancestor;

    if (isAncestorShow) {
      // 祖先顯示中, 那麼就可以檢查監聽子頁面的回調中, 是否包含page
      // 檢查當前最終顯示頁面
      var lastPage = _allPageHistory.last.route;
//      print('當前最後頁面: ${lastPage}, 檢測父子關西: ${RouteCompute.isSubPage(page, lastPage)}');

      if (page == lastPage || RouteCompute.isSubPage(page, lastPage)) {
        return true;
      }
      return false;
    }
    return false;
  }

  /// 是否可以彈出子頁面
  bool canPopAllPage() {
    return _allPageHistory.length >= 2;
  }

  /// 彈出所有層級的頁面
  bool popAllPage({BuildContext context}) {
    if (canPopAllPage()) {
      // 沒有上一頁了
      return false;
    }

    // 直接往上回退一個頁面
    _allPageHistory.removeLast();
    var toPage = _allPageHistory.removeLast();
    return setSubPage(
      toPage.route,
      context: context,
      blocQuery: toPage.blocQuery,
      pageQuery: toPage.widgetQuery,
    );
  }

  bool canPopSubPage(String underRoute) {
    if (_allPageHistory.length < 2) {
      // 沒有上一頁了
      return false;
    }

    // 檢查當前的頁面是否處於 underRoute 底下的子頁面
    var lastRoute1 = _allPageHistory.last;
    if (!RouteCompute.isSubPage(underRoute, lastRoute1.route, depth: null)) {
      print('當前頁面不屬於 $underRoute, 無法回退');
      return false;
    }

    var lastRoute2 = _allPageHistory[_allPageHistory.length - 2];
    if (!RouteCompute.isSubPage(underRoute, lastRoute2.route, depth: null)) {
      return false;
    }
    return true;
  }

  /// 彈出子頁面層級的頁面
  /// [underRoute] - 只彈出在此 route 下得子頁面
  bool popSubPage({String underRoute, BuildContext context}) {
    if (!canPopSubPage(underRoute)) {
      // 沒有上一頁了
      print('不可回退');
      return false;
    }

    // 檢查當前的頁面是否處於 underRoute 底下的子頁面
    _allPageHistory.removeLast();
    var lastRoute2 = _allPageHistory.removeLast();

    print('可回退, 往回退 => ${lastRoute2.route}');
    return setSubPage(
      lastRoute2.route,
      context: context,
      blocQuery: lastRoute2.blocQuery,
      pageQuery: lastRoute2.widgetQuery,
      checkToHistory: false,
    );
  }

  /// 加入子頁面跳轉頁面歷史紀錄
  /// 歷史記錄示例
  /// ==========================
  /// 一開始在 /a
  /// 跳 /a/b => 取代 => /a, /a/b
  /// 跳 /a/c => 取代 => /a, /a/c
  /// 跳 /a/d => 不取代 => /a, /a/c, /a/d
  /// 跳 /a/d/c => 取代 => /a, /a/c, /a/d/c
  /// 跳 /a/d/e => 取代 => /a, /a/c, /a/d/e
  /// 跳 /a/d/f => 不取代 => /a, /a/c, /a/d/e, /a/d/f
  /// 跳 /a/c => 取代 => /a, /a/c, /a/d/e, /a/d/f, /a/c
  /// TODO (層級往上暫時無法使用取代當前的功能, 可能會出問題)
  void _addSubHistory({
    RouteData data,
    bool replaceCurrent,
  }) {
    // 取得當前最後一個歷史頁面 route
    var lastRoute = _allPageHistory.last.route;

    // 下列情況會取代當前最後一個 route
    // 1.
    // 若 replaceCurrent 為 true
    // 並且跳轉的頁面 route 為同級層, 則刪除當前頁面並取代
    //
    // 2.
    // 加入的頁面是當前最後一個頁面的子頁面, 且當前的子頁面並非祖父頁面, 也會取代當前的頁面
    var isParentSame = RouteCompute.getParentRoute(data.route) ==
        RouteCompute.getParentRoute(lastRoute);
    if (replaceCurrent && isParentSame) {
      // 父親相同
      _allPageHistory.removeLast();
    } else if (RouteCompute.isSubPage(lastRoute, data.route) &&
        !RouteCompute.isAncestorRoute(lastRoute)) {
      // 是父子頁面關西, 同樣繼承 route query
      _allPageHistory.removeLast();
    }

    _allPageHistory.add(data);
    _allPageSubject.add(data);
  }

  /// 註冊子頁面監聽
  @override
  void registerSubPageListener(String page, RouteHandler handler,
      int hashCode) {
    var handlers = _subPageListener.where((e) => e.route == page);
    if (handlers.isNotEmpty) {
      // 已經有存在監聽的 callback, 取代
      print("警告 - 當前已存在相同的 page 子頁面 監聽, 將取代已有: $page");
      handlers.first.hashCode = hashCode;
      handlers.first.handler = handler;
    } else {
      _SubPageHandler subPageHandler = _SubPageHandler(page, handler, hashCode);
      _subPageListener.add(subPageHandler);

      // 先依照字母排序
      _subPageListener.sort((e1, e2) => e1.route.compareTo(e2.route));

      // 依照子頁面優先排序
      _subPageListener.sort((e1, e2) {
        if (RouteCompute.isSubPage(e1.route, e2.route, depth: null)) {
          return 1;
        } else if (RouteCompute.isSubPage(e2.route, e1.route, depth: null)) {
          return -1;
        }
        return 0;
      });
    }
  }

  /// 取消註冊子頁面監聽
  @override
  void unregisterSubPageListener(String page, int hashCode) {
    _subPageListener.removeWhere((e) =>
    e.route == page && e.hashCode == hashCode);
  }

  /// 發出顯示子頁面命令
  @override
  bool setSubPage(String route, {
    BuildContext context,
    Map<String, dynamic> pageQuery,
    Map<String, dynamic> blocQuery,
    bool replaceCurrent = false,
    bool checkToHistory = true,
  }) {
    // 先檢查要跳轉的子頁面, 是否於當前的大頁面之下
    if (checkToHistory &&
        !RouteCompute.isSubPage(currentPage, route, depth: null)) {
      // 不在當前大頁面, 因此先呼叫 pushPage, 並且把子頁面請求帶入 RouteOption 放在 bloc 底下
      if (context == null) {
        print(
            "子頁面跳轉失敗, 在不帶入 context 時, 大頁面 route 必須相同, current = $currentPage, sub = $route");
        return false;
      }

      // 有 context, 發起跳轉大頁面, 在進行子頁面的跳轉
      var ancestorRoute = RouteCompute.getAncestorRoute(route);

//      print("大頁面不同, 先跳轉大頁面: $ancestorRoute");

      pushPage(
        ancestorRoute,
        context,
        subRoute: route,
        pageQuery: pageQuery,
        blocQuery: blocQuery,
      );
      return true;
    } else {
      // 大頁面相同, 尋找可以處理此頁面的監聽, 並且直接發起 handler
//      print("開始尋找可以處理的 route: ${_subPageListener.length}");
      var isHandler = _subPageListener.any((e) {
        if (e.route == route) {
          // 如果是當前正在顯示的頁面, 則直接呼叫handler
          var routeData = RouteData(
            route,
            widgetQuery: pageQuery,
            blocQuery: blocQuery,
          );
          var handle = e.handler(routeData);
          return handle;
        } else if (RouteCompute.isSubPage(e.route, route, depth: null)) {
          // 有親子關西, 取得下個路由節點
          var nextRoute =
          RouteCompute.getNextRoute(parent: e.route, sub: route);

          // 取得 [e.route] 到 route 的下一個 route
          var routeData = RouteData(
            nextRoute,
            targetSubRoute: route,
            widgetQuery: pageQuery,
            blocQuery: blocQuery,
          );

          routeData.isPop = !checkToHistory;

          var handle = e.handler(routeData);
          if (handle) {
//            print('誰接住了: ${e.route}, 跳往目標: ${routeData.route}, 加入歷史: $checkToHistory, ${StackTrace.current}');
            if (checkToHistory) {
              _addSubHistory(data: routeData, replaceCurrent: replaceCurrent);
            } else {
              _allPageHistory.add(routeData);
              _allPageSubject.add(routeData);
            }
          }
          return handle;
        }
        return false;
      });

      if (!isHandler) {
        print("找不到可以處理此次跳轉的page: $route");
      }
      return isHandler;
    }
  }

  static void setDefaultRoute<T>(MixinRouteBuilder<T> builder) {
    _defaultRouteBuilder = builder;
  }

  @override
  Widget getSubPage(RouteData data) {
    return getPage(
      data.route,
      subRoute: data.targetSubRoute,
      pageQuery: data.widgetQuery,
      blocQuery: data.blocQuery,
    );
  }

  /// 返回的同時再 push
  /// [route] - 將要 push 的頁面
  /// [subRoute] - 跳轉到此大頁面底下的這個子頁面
  /// [popUtil] - pop 直到返回true
  /// [result] - 要返回給前頁面的結果, 當 [popUtil] 為空時有效
  @override
  Future<T> popAndPushPage<T>(String route,
      BuildContext context, {
        String subRoute,
        Map<String, dynamic> pageQuery,
        Map<String, dynamic> blocQuery,
        bool Function(String route) popUntil,
        Object result,
      }) {
    print("頁面返回並跳頁, 首先頁面返回");
    popPage(context, popUntil: popUntil, result: result);
    return pushPage(
      route,
      context,
      subRoute: subRoute,
      pageQuery: pageQuery,
      blocQuery: blocQuery,
    );
  }

  /// 返回大頁面 page
  /// [popUtil] - pop 直到返回true
  /// [result] - 要返回給前頁面的結果, 當 [popUtil] 為空時有效
  @override
  bool popPage(BuildContext context, {
    bool Function(String route) popUntil,
    Object result,
  }) {
    print("頁面返回");
    var navigator = Navigator.of(context);
    if (popUntil != null) {
      // 需要返回多個頁面
      navigator.popUntil((rt) {
        var name = rt.settings.name;
        if (name == '/') {
          name = _entryPointRouteAlias;
        }
        var isKeep = popUntil(name);
        if (!isKeep) {
          _removeLastPage();
        }
        return isKeep;
      });
      _allPageSubject.add(_allPageHistory.last);
      return true;
    } else {
      // 返回單個頁面
      _removeLastPage();
      _allPageSubject.add(_allPageHistory.last);
      navigator.pop(result);
      return true;
    }
  }

  /// 發起頁面跳轉
  /// [subRoute] - 跳轉到此大頁面底下的這個子頁面
  /// [replaceCurrent] - 替換掉當前頁面, 即無法再返回當前頁面
  /// [removeUtil] - 刪除舊頁面直到返回true
  /// [builder] - 自定義構建 PageRoute
  @override
  Future<T> pushPage<T>(String route,
      BuildContext context, {
        String subRoute,
        Map<String, dynamic> pageQuery,
        Map<String, dynamic> blocQuery,
        bool replaceCurrent = false,
        bool Function(String route) removeUntil,
        MixinRouteBuilder<T> builder,
      }) async {
//    print("頁面跳轉: $route");

    if (!RouteCompute.isAncestorRoute(route)) {
      throw '只有根路由才可以進行 pushPage, 若要跳轉子頁面請改用 setSubPage';
    }
//    else if (currentPage == route) {
//      // 當前大頁面顯示中, 呼叫 update option
//      print('當前大頁面顯示中, 不進行跳轉改由更新');
//      _subPageListener.any((e) {
//        if (e.route == route) {
//          // 如果是當前正在顯示的頁面, 則直接呼叫handler
//          var routeData = RouteData(
//            route,
//            widgetQuery: pageQuery,
//            blocQuery: blocQuery,
//          );
//          var handle = e.handler(routeData);
//          return handle;
//        }
//        return false;
//      });
//      return Future.value();
//    }

    var navigator = Navigator.of(context);

    // 檢查回退檢測是否已加入
    var isBackObservableAdded = navigator.widget.observers
        .any((detect) => detect is _DetectPageActionObservable);
    if (!isBackObservableAdded) {
      var detect = _DetectPageActionObservable(
        onDetectPop: (name) {
          var lastPage = _pageHistory.last;
//          print('最後: ${lastPage}, 歷史: ${allPageHistory.map((e) => e.route).toList()}, 以及: ${_pageHistory}');
          if (lastPage == name) {
//          print("檢測到非 code 返回, 刪除歷史紀錄");
            // allPageHistory 一直刪除直到大頁面被刪除
            _removeLastPage();
            _allPageSubject.add(_allPageHistory.last);
          }
          print('返回後結果: ${lastPage}, $name, 歷史: ${_allPageHistory.map((e) =>
          e
              .route).toList()}');
        },
      );
      navigator.widget.observers.add(detect);
    }

    PageRoute<T> pageRoute() {
      return _getRoute<T>(
        route,
        context,
        subRoute: subRoute,
        pageQuery: pageQuery,
        blocQuery: blocQuery,
        builder: builder,
      );
    }

    var routeData = RouteData(
      route,
      targetSubRoute: subRoute,
      widgetQuery: pageQuery,
      blocQuery: blocQuery,
    );

    if (removeUntil != null) {
      _allPageHistory.add(routeData);
      _allPageSubject.add(routeData);
      var result = await navigator.pushAndRemoveUntil(pageRoute(), (rt) {
        var name = rt.settings.name;
        if (name == '/') {
          name = _entryPointRouteAlias;
        }
        var isKeep = removeUntil(name);
        print('${name} 是否保留 - ${isKeep}, 歷史: ${_pageHistory}, ${_allPageHistory
            .map((e) => e.route)}');

        // 倒數第二個大頁面routeData
//        var lastSecondRoute = _pageHistory[_pageHistory.length - 2];
        if (!isKeep) {
          // 刪除最後一個大頁面
          _removeLastSecondPage();
        }
        return isKeep;
      });
      return result;
    } else if (replaceCurrent) {
      _removeLastPage();
      _allPageHistory.add(routeData);
      _allPageSubject.add(routeData);
      return await navigator.pushReplacement(pageRoute());
    } else {
//      print("添加到歷史: ${routeData.route}");
      _allPageHistory.add(routeData);
      _allPageSubject.add(routeData);
      return navigator.push(pageRoute());
    }
  }

  /// 自歷史紀錄刪除大頁面
  void _removeLastPage() {
    if (_allPageHistory.isEmpty) {
      return;
    }
    var lastData = _allPageHistory.removeLast();
    var isAncestor = RouteCompute.isAncestorRoute(lastData.route);
    while (!isAncestor) {
      lastData = _allPageHistory.removeLast();
      isAncestor = RouteCompute.isAncestorRoute(lastData.route);
    }
  }

  void _removeLastSecondPage() {
    if (_allPageHistory.isEmpty) {
      return;
    }

    var isFirst = true;
    int removeBegin = 0,
        removeEnd;
    for (var i = _allPageHistory.length - 1; i >= 0; i--) {
      var lastRoute = _allPageHistory[i];
      if (isFirst) {
        var isAncestorRoute = RouteCompute.isAncestorRoute(lastRoute.route);
        if (isAncestorRoute) {
          removeEnd = i;
          isFirst = false;
        }
      } else {
        var isAncestorRoute = RouteCompute.isAncestorRoute(lastRoute.route);
        if (isAncestorRoute) {
          removeBegin = i;
          break;
        }
      }
    }
    _allPageHistory.removeRange(removeBegin, removeEnd);
  }

  /// 單純取得頁面
  /// [subRoute] - 取得的頁面會自動加子頁面設為此
  /// [entryPoint] 表示此頁面是否為入口頁, 即是 MaterialApp 的 home
  @override
  Widget getPage(String route, {
    String subRoute,
    Map<String, dynamic> pageQuery,
    Map<String, dynamic> blocQuery,
    bool entryPoint = false,
  }) {
    var data = RouteData(
      route,
      targetSubRoute: subRoute,
      widgetQuery: pageQuery,
      blocQuery: blocQuery,
    );
    if (entryPoint == true && _entryPointRouteAlias == null) {
//      print("加入點起始點");
      _allPageHistory.clear();
      _entryPointRouteAlias = route;
      _allPageHistory.add(data);
    }
    return routeWidgetImpl.getPage(data);
  }

  PageRoute<T> _getRoute<T>(String route,
      BuildContext context, {
        String subRoute,
        Map<String, dynamic> pageQuery,
        Map<String, dynamic> blocQuery,
        MixinRouteBuilder<T> builder,
      }) {
    var page = routeWidgetImpl.getPage(
      RouteData(
        route,
        targetSubRoute: subRoute,
        widgetQuery: pageQuery,
        blocQuery: blocQuery,
      ),
    );

    var routeBuilder = builder ?? _defaultRouteBuilder;
    PageRoute<T> pageRoute;
    if (routeBuilder == null) {
      pageRoute = MaterialPageRoute(
        builder: (_) => page,
        settings: RouteSettings(name: route),
      );
    } else {
      pageRoute = routeBuilder(context, page, route);
      if (pageRoute == null) {
        print("RouteMixin builder 返回為空, 使用默認 MaterialPageRoute");
        pageRoute = MaterialPageRoute(
          builder: (_) => page,
          settings: RouteSettings(name: route),
        );
      }
    }
    return pageRoute;
  }

  @mustCallSuper
  void dispose() {
    _allPageSubject.close();
  }
}

class _DetectPageActionObservable extends NavigatorObserver {
  /// 回退檢測觸發
  final ValueCallback<String> onDetectPop;
  final ValueCallback<String> onDetectPush;

  _DetectPageActionObservable({this.onDetectPush, this.onDetectPop});

  /// 回退
  @override
  void didPop(Route route, Route previousRoute) {
    print("檢測到回退: ${route.settings.name}, ${previousRoute.settings.name}");
    onDetectPop(route.settings.name);
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route route, Route previousRoute) {
    print('檢測到頁面推進: ${route.settings.name}, ${previousRoute.settings.name}');
//    onDetectPop(route.settings.name);
    super.didPush(route, previousRoute);
  }
}
