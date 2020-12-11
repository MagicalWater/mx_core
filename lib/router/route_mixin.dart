import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core/router/route_compute.dart';
import 'package:rxdart/rxdart.dart';

import 'route_setting.dart';

MixinRouteBuilder _defaultRouteBuilder;

abstract class PageBlocInterface {
  /// 由此宣告頁面的 route
  String get route;

  /// 子頁面跳轉歷史
  List<RouteData> get subPageHistory;

  /// 當前的子頁面
  RouteData get currentSubPage;
}

/// 彈出等級
enum PopLevel {
  /// 層級以上
  greaterOrEqual,

  /// 精確
  exact,
}

/// 子頁面監聽處理
class _SubPageHandler {
  PageBlocInterface page;

  void Function(String route) _forceModifyPageDetail;

  bool Function(RouteData data) _isHandleRoute;
  bool Function(RouteData data, {bool Function(String route) popUntil})
      _dispatchSubPage;
  String Function({bool Function(String route) popUntil}) _popSubPage;

  void Function() _notifyUpdate;

  List<RouteData> get history => page.subPageHistory;

  String get route => page.route;

  @override
  int get hashCode => page.hashCode;

  _SubPageHandler(this.page);

  bool isHandleRoute(RouteData data) => _isHandleRoute(data);

  bool dispatchSubPage(RouteData data,
          {bool Function(String route) popUntil}) =>
      _dispatchSubPage(data, popUntil: popUntil);

  String popSubPage({bool Function(String route) popUntil}) =>
      _popSubPage(popUntil: popUntil);

  void notifyUpdate() => _notifyUpdate();

  void forceModifyPageDetail(String route) => _forceModifyPageDetail(route);

  @override
  bool operator ==(other) {
    if (other is _SubPageHandler) {
      return hashCode == other.hashCode;
    }
    return false;
  }
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

  /// 大頁面跳轉歷史紀錄
  List<RouteData> get pageHistory => _pageSubject.value ?? [];

  /// 大頁面跳轉紀錄串流
  BehaviorSubject<List<RouteData>> _pageSubject = BehaviorSubject();

  /// 所有頁面跳轉通知串流
  Stream<RouteData> get pageStream =>
      _pageSubject.stream.map((event) => event.last);

  /// 當前顯示的頁面
  String get currentPage => pageHistory.last.route;

  /// 頁面詳細跳轉
  BehaviorSubject<String> _pageDetailSubject = BehaviorSubject();

  Stream<String> get pageDetailStream => _pageDetailSubject.stream;

  /// 當前顯示的詳細頁面(涵蓋子頁面)
  String get currentDetailPage => _pageDetailSubject.value;

  /// 從當前大頁面重新尋找最終子頁面
  /// 並且讓其頁面進行刷新
  String _researchCurrentDetailPage() {
    String searchPage = currentPage;
//    print('搜索: $searchPage');
    _SubPageHandler findStep, searchListener;

    do {
      findStep = _subPageListener.firstWhere(
          (element) => element.route == searchPage,
          orElse: () => null);

      if (findStep != null) {
        if (findStep.history.isNotEmpty) {
          searchPage = findStep.history.last.route;
          searchListener = findStep;
//          print('往下搜索: $searchPage');
        } else {
//          print('沒有子頁面歷史, 停止搜索: $searchPage');
          findStep = null;
        }
      } else {
//        print('找不到子頁面監聽, 停止搜索: $searchPage');
        findStep = null;
      }
    } while (findStep != null);

    print('找到應該顯示的頁面: $searchPage');
    _pageDetailSubject.add(searchPage);

    // 通知子頁面進行刷新
    searchListener?.notifyUpdate();

    return searchPage;
  }

  /// 強制修改當前的子頁面訊息
  void forceModifyPageDetail(String route) {
    _pageDetailSubject.add(route);

    // 尋找此頁面的父親
    var findParent = route;
    _SubPageHandler findListener;
    var currentRangeListener = _getCurrentRangeListener();

    while (findParent != null && findListener == null) {
      findParent = RouteCompute.getParentRoute(findParent);
      findListener = currentRangeListener.lastWhere(
        (element) => element.route == findParent,
        orElse: () => null,
      );
    }

    if (findListener != null) {
      findListener.forceModifyPageDetail(route);
    } else {
      var errorText = '錯誤; 無法強制更改詳細頁面訊息';
      print(errorText);
      throw errorText;
    }
  }

  /// 取得路由為 [page] 的頁面是否顯示中
  @override
  bool isPageShowing(String page) {
    if (page == "/") {
      print("根結點並非是一個 page");
      return false;
    }
    return page.matchAsPrefix(currentDetailPage) != null;
  }

  /// 是否可以彈出子頁面
  @override
  bool canPopSubPage(
    String route, {
    PopLevel level = PopLevel.exact,
  }) {
    switch (level) {
      case PopLevel.greaterOrEqual:
        // TODO: 尚待實現
        break;
      case PopLevel.exact:
        // 先檢查欲回退的目標是否正在顯示中
        if (route.matchAsPrefix(currentDetailPage) != null) {
          var findListener = _subPageListener.reversed
              .firstWhere((element) => element.route == route);
          if (findListener == null) {
            return false;
          }
          return findListener.history.length >= 2;
        }
        return false;
    }
    return false;
  }

  /// 彈出子頁面層級的頁面
  /// [route] - 鎖定目標為 [route] 下得子頁面
  /// [level] - 彈出等級
  /// 若 [PopLevel.exact] 則只談出鎖定目標下的子頁面
  /// 若 [PopLevel.greaterOrEqual] 則鎖定目標下無子頁面時, 會彈出鎖定目標往上層級尋找
  @override
  bool popSubPage(
    String route, {
    PopLevel level = PopLevel.exact,
    bool Function(String route) popUntil,
  }) {
    if (!canPopSubPage(route, level: level)) {
      return false;
    }
    switch (level) {
      case PopLevel.greaterOrEqual:
        // TODO: 尚待實現
        break;
      case PopLevel.exact:
        // 先檢查欲回退的目標是否正在顯示中
        var findListener = _subPageListener.reversed
            .firstWhere((element) => element.route == route);
        if (findListener == null) {
          return false;
        }
        var result = findListener.popSubPage(popUntil: popUntil);
        if (result != null) {
          var lastShowPage = result;

          var currentRangeListener = _getCurrentRangeListener();
          var findInnerListener = currentRangeListener.lastWhere(
            (element) => element.route == currentDetailPage,
            orElse: () => null,
          );
          while (findInnerListener != null) {
            if (findInnerListener.history.isNotEmpty) {
              lastShowPage = findInnerListener.history.last.route;
              findInnerListener = currentRangeListener.lastWhere(
                (element) => element.route == lastShowPage,
                orElse: () => null,
              );
            } else {
              break;
            }
          }
          _pageDetailSubject.add(lastShowPage);
        }
        return result != null;
    }
    return false;
  }

  /// 註冊子頁面監聽
  @override
  void registerSubPageListener({
    PageBlocInterface page,
    bool Function(RouteData data) isHandleRoute,
    bool Function(RouteData data, {bool Function(String route) popUntil})
        dispatchSubPage,
    void Function(String route) forceModifyPageDetail,
    String Function({bool Function(String route) popUntil}) popSubPage,
    void Function() notifyUpdate,
  }) {
    _SubPageHandler subPageHandler = _SubPageHandler(page);
    subPageHandler._isHandleRoute = isHandleRoute;
    subPageHandler._dispatchSubPage = dispatchSubPage;
    subPageHandler._popSubPage = popSubPage;
    subPageHandler._forceModifyPageDetail = forceModifyPageDetail;
    subPageHandler._notifyUpdate = notifyUpdate;
    _subPageListener.add(subPageHandler);
  }

  /// 取消註冊子頁面監聽
  @override
  void unregisterSubPageListener(PageBlocInterface page) {
    _subPageListener.removeWhere((e) => e.page == page);
  }

  /// 取得當前頁面的監聽器
  List<_SubPageHandler> _getCurrentRangeListener() {
    var index = _subPageListener.lastIndexWhere((e) {
      if (RouteCompute.isAncestorRoute(e.route)) {
        return true;
      }
      return false;
    });
    return _subPageListener.sublist(index);
  }

  /// 發出顯示子頁面命令
  bool _setSubPage(
    String route, {
    Map<String, dynamic> pageQuery,
    Map<String, dynamic> blocQuery,
    bool forceNew = false,
    bool Function(String route) popUntil,
  }) {
    print(
        '跳轉頁面請求 $route, 當前大頁面歷史: ${pageHistory.map((e) => e.route)}, 子頁面詳情: $currentDetailPage');
    // 先檢查要跳轉的子頁面, 是否於當前的大頁面之下
    if (!RouteCompute.isSubPage(currentPage, route, depth: null)) {
      // 不在當前大頁面, 因此先呼叫 pushPage, 並且把子頁面請求帶入 RouteOption 放在 bloc 底下

      // 發起跳轉大頁面, 在進行子頁面的跳轉
      var ancestorRoute = RouteCompute.getAncestorRoute(route);

//      print("大頁面不同, 先跳轉大頁面: $ancestorRoute");

      _pushPage(
        ancestorRoute,
        subRoute: route,
        pageQuery: pageQuery,
        blocQuery: blocQuery,
        removeUntil: popUntil,
      );

      return true;
    } else {
      var findParent = route;
      _SubPageHandler findListener;
      var currentRangeListener = _getCurrentRangeListener();

      // print(
      //     '當前擁有的頁面監聽: ${_subPageListener.map((e) => e.route)}, 當前大頁面: $currentPage');

      while (findParent != null && findListener == null) {
        findParent = RouteCompute.getParentRoute(findParent);
        findListener = currentRangeListener.lastWhere(
          (element) => element.route == findParent,
          orElse: () => null,
        );
      }

      if (findListener != null) {
        var nextRoute =
            RouteCompute.getNextRoute(parent: findParent, sub: route);

        // 取得 [e.route] 到 route 的下一個 route
        var routeData = RouteData(
          nextRoute,
          targetSubRoute: route,
          widgetQuery: pageQuery,
          blocQuery: blocQuery,
        );

        routeData.forceNew = forceNew;

        var isHandle = findListener.isHandleRoute(routeData);
        if (!isHandle) {
          print('$findParent 拒絕此次跳轉page請求: $route');
        } else {
          _pageDetailSubject.add(nextRoute);
          findListener.dispatchSubPage(
            routeData,
            popUntil: popUntil,
          );
          var lastShowPage = nextRoute;

          var findInnerListener = currentRangeListener.lastWhere(
            (element) => element.route == currentDetailPage,
            orElse: () => null,
          );
          while (findInnerListener != null) {
            if (findInnerListener.history.isNotEmpty) {
              lastShowPage = findInnerListener.history.last.route;
              findInnerListener = currentRangeListener.lastWhere(
                (element) => element.route == lastShowPage,
                orElse: () => null,
              );
            } else {
              break;
            }
          }
        }
        return isHandle;
      } else {
        print("找不到可以處理此次跳轉的page: $route");
        return false;
      }
    }
  }

  static void setDefaultRoute<T>(MixinRouteBuilder<T> builder) {
    _defaultRouteBuilder = builder;
  }

  /// 返回的同時再 push
  /// [route] - 將要 push 的頁面
  /// [subRoute] - 跳轉到此大頁面底下的這個子頁面
  /// [popUtil] - pop 直到返回true
  /// [result] - 要返回給前頁面的結果, 當 [popUtil] 為空時有效
  @override
  Future<dynamic> popAndPushPage<T>(
    String route, {
    Map<String, dynamic> pageQuery,
    Map<String, dynamic> blocQuery,
    bool Function(String route) popUntil,
    Object result,
  }) {
    print("頁面返回並跳頁, 首先頁面返回");
    popPage(popUntil: popUntil, result: result);
    return pushPage(
      route,
      pageQuery: pageQuery,
      blocQuery: blocQuery,
    );
  }

  /// 是否可以返回大頁面
  bool canPopPage() {
    return navigatorIns.canPop();
  }

  /// 返回大頁面 page
  /// [popUtil] - pop 直到返回true
  /// [result] - 要返回給前頁面的結果, 當 [popUtil] 為空時有效
  @override
  bool popPage({
    bool Function(String route) popUntil,
    Object result,
  }) {
    print("頁面返回");
    var navigator = navigatorIns;
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
      _pageSubject.add(_pageSubject.value);
      _researchCurrentDetailPage();
      return true;
    } else {
      // 返回單個頁面
      _removeLastPage();
      _pageSubject.add(_pageSubject.value);
      _researchCurrentDetailPage();
      navigator.pop(result);
      return true;
    }
  }

  @override
  Future<dynamic> pushPage<T>(
    String route, {
    Map<String, dynamic> pageQuery,
    Map<String, dynamic> blocQuery,
    bool replaceCurrent,
    bool Function(String route) removeUntil,
    MixinRouteBuilder<T> builder,
    Key key,
  }) async {
    // 分發決定跳轉大頁面還是子頁面
    if (RouteCompute.isAncestorRoute(route)) {
      // 跳轉大頁面默認不替掉當前頁面
      replaceCurrent ??= false;
      // 是跳轉大頁面
      return _pushPage(
        route,
        key: key,
        pageQuery: pageQuery,
        blocQuery: blocQuery,
        replaceCurrent: replaceCurrent,
        removeUntil: removeUntil,
        builder: builder,
      );
    } else {
      // 跳轉大頁面默認替掉當前頁面
      var forceNew = !(replaceCurrent ?? true);
      // 跳轉子頁面
      _setSubPage(
        route,
        pageQuery: pageQuery,
        blocQuery: blocQuery,
        forceNew: forceNew,
        popUntil: removeUntil,
      );
    }
  }

  /// 發起頁面跳轉
  /// [subRoute] - 跳轉到此大頁面底下的這個子頁面
  /// [replaceCurrent] - 替換掉當前頁面, 即無法再返回當前頁面
  /// [removeUtil] - 刪除舊頁面直到返回true
  /// [builder] - 自定義構建 PageRoute
  Future<T> _pushPage<T>(
    String route, {
    String subRoute,
    Map<String, dynamic> pageQuery,
    Map<String, dynamic> blocQuery,
    bool replaceCurrent = false,
    bool Function(String route) removeUntil,
    MixinRouteBuilder<T> builder,
    Key key,
  }) async {
//    print("頁面跳轉: $route");

    if (!RouteCompute.isAncestorRoute(route)) {
      throw '只有根路由才可以進行 pushPage, 若要跳轉子頁面請改用 setSubPage';
    }

    var navigatorState = navigatorIns;

    // 檢查回退檢測是否已加入
    var routeNavigatorObservable = navigatorState.widget.observers
        .whereType<MxCoreRouteObservable>()
        .first;

    routeNavigatorObservable._onDetectPop ??= (name) {
      var lastPage = pageHistory.last;
      if (lastPage.route == name) {
        print('刪除最後: ${pageHistory.map((e) => e.route)}');
        _removeLastPage();
        _pageSubject.add(_pageSubject.value);
        print('刪除後: ${pageHistory.map((e) => e.route)}');
        _researchCurrentDetailPage();
      }
    };

    PageRoute<T> pageRoute() {
      return _getRoute<T>(
        route,
        subRoute: subRoute,
        pageQuery: pageQuery,
        blocQuery: blocQuery,
        builder: builder,
        key: key,
      );
    }

    var routeData = RouteData(
      route,
      targetSubRoute: subRoute,
      widgetQuery: pageQuery,
      blocQuery: blocQuery,
    );

    if (removeUntil != null) {
      _pageSubject.value.add(routeData);
      _pageSubject.add(_pageSubject.value);
      _pageDetailSubject.add(pageHistory.last.route);
      var result = await navigatorState.pushAndRemoveUntil(pageRoute(), (rt) {
        var name = rt.settings.name;
        if (name == '/') {
          name = _entryPointRouteAlias;
        }
        var isKeep = removeUntil(name);
        print(
            '$name 是否保留 - $isKeep, 歷史: $pageHistory, ${pageHistory.map((e) => e.route)}');

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
      _pageSubject.value.add(routeData);
      _pageSubject.add(_pageSubject.value);
      _pageDetailSubject.add(pageHistory.last.route);
      return await navigatorState.pushReplacement(pageRoute());
    } else {
//      print("添加到歷史: ${routeData.route}");
      _pageSubject.value.add(routeData);
      _pageSubject.add(_pageSubject.value);
      _pageDetailSubject.add(pageHistory.last.route);
      return navigatorState.push(pageRoute());
    }
  }

  /// 自歷史紀錄刪除大頁面
  void _removeLastPage() {
    if (pageHistory.isEmpty) {
      return;
    }
    var pageData = _pageSubject.value.removeLast();
    _subPageListener.removeWhere((e) => e.page.route == pageData.route);
  }

  void _removeLastSecondPage() {
    if (pageHistory.length > 2) {
      return;
    }

    var pageData = _pageSubject.value.removeAt(pageHistory.length - 2);
    _subPageListener.removeWhere((e) => e.page.route == pageData.route);
  }

  /// 單純取得頁面
  /// [subRoute] - 取得的頁面會自動加子頁面設為此
  /// [entryPoint] 表示此頁面是否為入口頁, 即是 MaterialApp 的 home
  @override
  Widget getPage(
    dynamic route, {
    Map<String, dynamic> pageQuery,
    Map<String, dynamic> blocQuery,
    bool entryPoint = false,
    Key key,
  }) {
    RouteData data;
    if (route is RouteData) {
      data = route;
    } else if (route is String) {
      data = RouteData(route);
    } else {
      print('警告: route 只可帶入 RouteData 或 String');
      return null;
    }

    if (entryPoint == true && _entryPointRouteAlias == null) {
//      print("加入點起始點");
      _pageSubject.add([data]);
      _pageDetailSubject.add(pageHistory.last.route);
      _entryPointRouteAlias = route;
    }
    return routeWidgetImpl.getPage(data, key: key);
  }

  PageRoute<T> _getRoute<T>(
    String route, {
    String subRoute,
    Map<String, dynamic> pageQuery,
    Map<String, dynamic> blocQuery,
    MixinRouteBuilder<T> builder,
    Key key,
  }) {
    var page = routeWidgetImpl.getPage(
      RouteData(
        route,
        targetSubRoute: subRoute,
        widgetQuery: pageQuery,
        blocQuery: blocQuery,
      ),
      key: key,
    );

    var routeBuilder = builder ?? _defaultRouteBuilder;
    PageRoute<T> pageRoute;
    if (routeBuilder == null) {
      pageRoute = MaterialPageRoute(
        builder: (_) => page,
        settings: RouteSettings(name: route),
      );
    } else {
      pageRoute = routeBuilder(page, route);
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
    _pageSubject.close();
    _pageDetailSubject.close();
  }
}

class MxCoreRouteObservable extends NavigatorObserver {
  /// 回退檢測觸發
  ValueCallback<String> _onDetectPop;
  ValueCallback<String> _onDetectPush;

  MxCoreRouteObservable();

  @override
  void didRemove(Route route, Route previousRoute) {
    print('檢測到刪除: ${route?.settings?.name}, ${previousRoute?.settings?.name}');
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route newRoute, Route oldRoute}) {
    print('檢測到取代: ${newRoute?.settings?.name}, ${oldRoute?.settings?.name}');
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didStartUserGesture(Route route, Route previousRoute) {
    print(
        '檢測到使用者控制開始: ${route?.settings?.name}, ${previousRoute?.settings?.name}');
    super.didStartUserGesture(route, previousRoute);
  }

  @override
  void didStopUserGesture() {
    print('檢測到使用者控制結束');
    super.didStopUserGesture();
  }

  /// 回退
  @override
  void didPop(Route route, Route previousRoute) {
    print("檢測到回退: ${route?.settings?.name}, ${previousRoute?.settings?.name}");
    if (_onDetectPop != null) _onDetectPop(route.settings.name);
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route route, Route previousRoute) {
    print(
        '檢測到頁面推進: ${route?.settings?.name}, ${previousRoute?.settings?.name}');
    if (_onDetectPush != null) _onDetectPush(route.settings.name);
    super.didPush(route, previousRoute);
  }
}
