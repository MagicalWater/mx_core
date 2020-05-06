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

  _SubPageHandler(this.route, this.handler);
}

/// route mixin 類
mixin RouteMixin implements RouteMixinBase, RoutePageBase {
  /// 存放所有監聽子頁面跳轉的 callback
  List<_SubPageHandler> _subPageListener = [];

  /// app 入口頁面的別名
  String _entryPointRouteAlias;

  /// 大頁面的 history
  List<RouteData> _pageHistory = [];

  List<RouteData> get pageHistory => _pageHistory;

  /// 大頁面跳轉串流
  BehaviorSubject<RouteData> _pageSubject = BehaviorSubject();

  /// 子頁面跳轉串流
  BehaviorSubject<RouteData> _subPageSubject = BehaviorSubject();

  /// 大頁面跳轉通知串流
  Stream<String> get pageStream =>
      _pageSubject.stream.map((data) => data.route);

  /// 子頁面跳轉通知串流
  Stream<String> get subPageStream =>
      _subPageSubject.stream.map((data) => data.route);

  /// 當前的大頁面
  String get currentPage => _pageHistory.last?.route;

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
      return _subPageListener.any((e) => e.route == page);
    }
    return false;
  }

  /// 取得 [page] 的子頁面跳轉命令串流
  /// </p> 若 [page] 為空, 則監聽所有的子頁面
  /// </p> 此處設計為接到此串流通知的要再進行顯示元件的動作
//  Stream<RouteData> getSubPageStream([String page]) {
//    return _subPageSubject.stream
//        .where((data) => RouteCompute.isSubPage(page, data.route));
//  }

  /// 註冊子頁面監聽
  @override
  void registerSubPageListener(String page, RouteHandler handler) {
    var handlers = _subPageListener.where((e) => e.route == page);
    _SubPageHandler subPageHandler;
    if (handlers.isNotEmpty) {
      // 已經有存在監聽的 callback, 取代
      print("警告 - 當前已存在相同的 page 子頁面 監聽, 將取代已有");
      subPageHandler = handlers.first;
    } else {
      subPageHandler = _SubPageHandler(page, handler);
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
  void unregisterSubPageListener(String page) {
    _subPageListener.removeWhere((e) => e.route == page);
  }

  /// 發出顯示子頁面命令
  @override
  bool setSubPage(
    String route, {
    BuildContext context,
    Map<String, dynamic> pageQuery,
    Map<String, dynamic> blocQuery,
  }) {
    // 先檢查要跳轉的子頁面, 是否於當前的大頁面之下
    if (!RouteCompute.isSubPage(currentPage, route, depth: null)) {
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

          var handle = e.handler(routeData);
          if (handle) {
            _subPageSubject.add(routeData);
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
  Future<T> popAndPushPage<T>(
    String route,
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

  /// 返回 page
  /// [popUtil] - pop 直到返回true
  /// [result] - 要返回給前頁面的結果, 當 [popUtil] 為空時有效
  @override
  bool popPage(
    BuildContext context, {
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
        if (!isKeep && ((_pageHistory.last?.route ?? '') == name)) {
          _pageHistory.removeLast();
        }
        return isKeep;
      });
      return true;
    } else {
      // 返回單個頁面
      _pageHistory.removeLast();
      return navigator.pop(result);
    }
  }

  /// 發起頁面跳轉
  /// [subRoute] - 跳轉到此大頁面底下的這個子頁面
  /// [replaceCurrent] - 替換掉當前頁面, 即無法再返回當前頁面
  /// [removeUtil] - 刪除舊頁面直到返回true
  /// [builder] - 自定義構建 PageRoute
  @override
  Future<T> pushPage<T>(
    String route,
    BuildContext context, {
    String subRoute,
    Map<String, dynamic> pageQuery,
    Map<String, dynamic> blocQuery,
    bool replaceCurrent = false,
    bool Function(String route) removeUntil,
    MixinRouteBuilder<T> builder,
  }) async {
//    print("頁面跳轉: $route");

    var navigator = Navigator.of(context);

    // 檢查回退檢測是否已加入
    var isBackObservableAdded = navigator.widget.observers
        .any((detect) => detect is _DetectPageActionObservable);
    if (!isBackObservableAdded) {
      var detect = _DetectPageActionObservable(
        onDetectPop: (name) {
          if ((_pageHistory.last?.route ?? '') == name) {
//          print("檢測到非 code 返回, 刪除歷史紀錄");
            _pageHistory.removeLast();
            _pageSubject.add(_pageHistory.last);
          }
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
      _pageHistory.add(routeData);
      _pageSubject.add(routeData);
      var result = await navigator.pushAndRemoveUntil(pageRoute(), (rt) {
        var name = rt.settings.name;
        if (name == '/') {
          name = _entryPointRouteAlias;
        }
        var isKeep = removeUntil(name);

        // 倒數第二個routeData
        var lastSecondRoute = _pageHistory[_pageHistory.length - 2];
        if (!isKeep && ((lastSecondRoute.route ?? '') == name)) {
          // 刪除倒數第二個
          _pageHistory.removeAt(_pageHistory.length - 2);
        }
        return isKeep;
      });
      return result;
    } else if (replaceCurrent) {
      _pageHistory.removeLast();
      _pageHistory.add(routeData);
      _pageSubject.add(routeData);
      return await navigator.pushReplacement(pageRoute());
    } else {
//      print("添加到歷史: ${routeData.route}");
      _pageHistory.add(routeData);
      _pageSubject.add(routeData);
      return navigator.push(pageRoute());
    }
  }

  /// 單純取得頁面
  /// [subRoute] - 取得的頁面會自動加子頁面設為此
  /// [entryPoint] 表示此頁面是否為入口頁, 即是 MaterialApp 的 home
  @override
  Widget getPage(
    String route, {
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
      _pageHistory.clear();
      _entryPointRouteAlias = route;
      _pageHistory.add(data);
    }
    return routeWidgetImpl.getPage(data);
  }

  PageRoute<T> _getRoute<T>(
    String route,
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
    _subPageSubject.close();
    _pageSubject.close();
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
