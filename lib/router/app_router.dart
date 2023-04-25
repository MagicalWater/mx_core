import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/router/router.dart';
import 'package:mx_core/ui/widget/navigator_provider.dart';
import 'package:rxdart/rxdart.dart';

MixinRouteBuilder? _defaultRouteBuilder;

abstract class PageInterface {
  /// 由此宣告頁面的 route
  String get route;

  /// 子頁面跳轉歷史
  List<RouteData> get subPageHistory;

  /// 當前的子頁面
  RouteData? get currentSubPage;
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
  PageInterface page;

  late void Function(String route) _forceModifyPageDetail;

  late bool Function(RouteData data) _isHandleRoute;
  late void Function(RouteData data, {bool Function(String route)? popUntil})
      _dispatchSubPage;
  late String? Function({bool Function(String route)? popUntil}) _popSubPage;

  List<RouteData> get history => page.subPageHistory;

  String get route => page.route;

  @override
  int get hashCode => page.hashCode;

  _SubPageHandler(this.page);

  bool isHandleRoute(RouteData data) => _isHandleRoute(data);

  void dispatchSubPage(RouteData data,
          {required bool Function(String route)? popUntil}) =>
      _dispatchSubPage(data, popUntil: popUntil);

  String? popSubPage({bool Function(String route)? popUntil}) =>
      _popSubPage(popUntil: popUntil);

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

AppRouter appRouter = AppRouter._();

/// route mixin 類
class AppRouter implements AppRouterBase, RoutePageBase {
  AppRouter._();

  /// 存放所有監聽子頁面跳轉的 callback
  final List<_SubPageHandler> _subPageListener = [];

  /// app 入口頁面的別名
  String? _entryPointRouteAlias;

  /// 大頁面跳轉歷史紀錄
  List<RouteData> get pageHistory => _pageSubject.valueOrNull ?? [];

  /// 大頁面跳轉紀錄串流
  final BehaviorSubject<List<RouteData>> _pageSubject = BehaviorSubject();

  /// 所有頁面跳轉通知串流
  Stream<RouteData> get pageStream =>
      _pageSubject.stream.map((event) => event.last);

  /// 當前顯示的頁面
  String? get currentPage {
    if (pageHistory.isEmpty) {
      return null;
    }
    return pageHistory.last.route;
  }

  /// 路由監聽, 請將此參數加入MaterialApp.navigatorObservers
  final observable = _MxCoreRouteObservable._();

  /// 頁面詳細跳轉
  final BehaviorSubject<String> _pageDetailSubject = BehaviorSubject();

  Stream<String> get pageDetailStream => _pageDetailSubject.stream;

  /// 當前顯示的詳細頁面(涵蓋子頁面)
  String? get currentDetailPage => _pageDetailSubject.valueOrNull;

  /// 是否需要阻擋一下監測系統返回頁面通過 _onDetectPop 打回來的請求
  /// 此需求用在當 popPage 時, [_pageDetailSubject] 已經進行頁面回退
  /// 因此 _onDetectPop 不需要再次進行回退
  bool isNeedBlockOnceSystemPopDetect = false;

  /// 從當前大頁面重新尋找最終子頁面
  /// 並且讓其頁面進行刷新
  String? _researchCurrentDetailPage() {
    var searchPage = currentPage;

    if (searchPage == null) {
      return null;
    }

//    print('搜索: $searchPage');
    _SubPageHandler? findStep;

    do {
      findStep = _subPageListener
          .firstWhereOrNull((element) => element.route == searchPage);

      if (findStep != null) {
        if (findStep.history.isNotEmpty) {
          searchPage = findStep.history.last.route;
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
    _pageDetailSubject.add(searchPage!);

    return searchPage;
  }

  /// 強制修改當前的子頁面訊息
  void forceModifyPageDetail(String route) {
    _pageDetailSubject.add(route);

    // 尋找此頁面的父親
    String? findParent = route;
    _SubPageHandler? findListener;
    var currentRangeListener = _getCurrentRangeListener();

    while (findParent != null && findListener == null) {
      findParent = RouteCompute.getParentRoute(findParent);
      findListener = currentRangeListener
          .lastWhereOrNull((element) => element.route == findParent);
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
    } else if (currentDetailPage == null) {
      print("當前並無正在顯示的詳細子頁面");
      return false;
    } else {
      return page.matchAsPrefix(currentDetailPage!) != null;
    }
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
        if (isPageShowing(route)) {
          var findListener = _subPageListener.reversed
              .firstWhereOrNull((element) => element.route == route);
          if (findListener == null) {
            return false;
          }
          // print(
          //     '檢查: ${findListener.route} 底下含有歷史子頁面數量: ${findListener.history.map((e) => e.route)}');
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
    bool Function(String route)? popUntil,
  }) {
    if (!canPopSubPage(route, level: level)) {
      print('appRouter: 當前不可回退頁面, 返回pop子頁面請求');
      return false;
    }
    switch (level) {
      case PopLevel.greaterOrEqual:
        // TODO: 尚待實現
        break;
      case PopLevel.exact:
        // 先檢查欲回退的目標是否正在顯示中
        var findListener = _subPageListener.reversed
            .firstWhereOrNull((element) => element.route == route);
        if (findListener == null) {
          print('appRouter: 找不到監聽器, 返回pop子頁面請求');
          return false;
        }
        var result = findListener.popSubPage(popUntil: popUntil);
        if (result != null) {
          var lastShowPage = result;

          var currentRangeListener = _getCurrentRangeListener();
          var findInnerListener = currentRangeListener
              .lastWhereOrNull((element) => element.route == currentDetailPage);
          while (findInnerListener != null) {
            if (findInnerListener.history.isNotEmpty) {
              lastShowPage = findInnerListener.history.last.route;
              findInnerListener = currentRangeListener
                  .lastWhereOrNull((element) => element.route == lastShowPage);
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
    required PageInterface page,
    required bool Function(RouteData data) isHandleRoute,
    required void Function(RouteData data,
            {bool Function(String route)? popUntil})
        dispatchSubPage,
    required void Function(String route) forceModifyPageDetail,
    required String? Function({bool Function(String route)? popUntil})
        popSubPage,
  }) {
    _SubPageHandler subPageHandler = _SubPageHandler(page);
    subPageHandler._isHandleRoute = isHandleRoute;
    subPageHandler._dispatchSubPage = dispatchSubPage;
    subPageHandler._popSubPage = popSubPage;
    subPageHandler._forceModifyPageDetail = forceModifyPageDetail;
    // print('～～～: 註冊監聽(前) - ${_subPageListener.map((e) => e.page.route)}');
    _subPageListener.add(subPageHandler);
    // print('～～～: 註冊監聽(後) - ${_subPageListener.map((e) => e.page.route)}');
  }

  /// 取消註冊子頁面監聽
  @override
  void unregisterSubPageListener(PageInterface page) {
    // print('～～～: 刪除監聽(前) - ${_subPageListener.map((e) => e.page.route)}');
    _subPageListener.removeWhere((e) => e.page == page);
    // print('～～～: 刪除監聽(後) - ${_subPageListener.map((e) => e.page.route)}');
  }

  /// 取得當前頁面的監聽器
  List<_SubPageHandler> _getCurrentRangeListener() {
    var index = _subPageListener.lastIndexWhere((e) {
      if (RouteCompute.isAncestorRoute(e.route)) {
        return true;
      }
      return false;
    });
    if (index == -1) {
      return _subPageListener;
    }
    return _subPageListener.sublist(index);
  }

  /// 發出顯示子頁面命令
  bool _setSubPage(
    String route, {
    Map<String, dynamic>? query,
    bool forceNew = false,
    bool Function(String? route)? popUntil,
  }) {
    print(
        '跳轉頁面請求 $route, 當前大頁面歷史: ${pageHistory.map((e) => e.route)}, 子頁面詳情: $currentDetailPage');
    // 先檢查要跳轉的子頁面, 是否於當前的大頁面之下
    if (!RouteCompute.isSubPage(currentPage ?? '', route, depth: null)) {
      // 不在當前大頁面, 因此先呼叫 pushPage, 並且把子頁面請求帶入 RouteOption 放在 bloc 底下

      // 發起跳轉大頁面, 在進行子頁面的跳轉
      var ancestorRoute = RouteCompute.getAncestorRoute(route);

//      print大頁面不同(", 先跳轉大頁面: $ancestorRoute");

      _pushPage(
        ancestorRoute,
        subRoute: route,
        query: query,
        removeUntil: popUntil,
      );

      return true;
    } else {
      String? findParent = route;
      _SubPageHandler? findListener;
      var currentRangeListener = _getCurrentRangeListener();

      // print(
      //     '當前擁有的頁面監聽: ${_subPageListener.map((e) => e.route)}, 當前大頁面: $currentPage');

      // 尋找可以處理分發的監聽
      while (findParent != null && findListener == null) {
        findParent = RouteCompute.getParentRoute(findParent);
        findListener = currentRangeListener
            .lastWhereOrNull((element) => element.route == findParent);
      }

      if (findListener != null) {
        print('尋找子頁面路由監聽: ${findListener.page.hashCode}');

        // 取得確認需要分發的子路由
        var nextRoute = RouteCompute.getNextRoute(
          parent: findParent!,
          sub: route,
        )!;

        var routeData = RouteData(
          nextRoute,
          targetSubRoute: route,
          query: query,
        );

        routeData.forceNew = forceNew;

        // 檢查此路由是否可以進行分發
        var isHandle = findListener.isHandleRoute(routeData);
        if (!isHandle) {
          print('$findParent 拒絕此次跳轉page請求: $route');
        } else {
          // 可以進行分發, 加入subject
          _pageDetailSubject.add(nextRoute);

          // 開始分發
          findListener.dispatchSubPage(routeData, popUntil: popUntil);

          // var lastShowPage = nextRoute;
          //
          // var findInnerListener = currentRangeListener
          //     .lastWhereOrNull((element) => element.route == currentDetailPage);
          // while (findInnerListener != null) {
          //   if (findInnerListener.history.isNotEmpty) {
          //     lastShowPage = findInnerListener.history.last.route;
          //     findInnerListener = currentRangeListener
          //         .lastWhereOrNull((element) => element.route == lastShowPage);
          //   } else {
          //     break;
          //   }
          // }
        }
        return isHandle;
      } else {
        print("找不到可以處理此次跳轉的page: $route");
        return false;
      }
    }
  }

  // 快速設置子頁面資訊(由PageRouter自行分發, 不需要再轉送)
  void syncSubRouteInfo(RouteData data) {
    _pageDetailSubject.add(data.route);
  }

  static void setDefaultRoute<T>(MixinRouteBuilder<T> builder) {
    _defaultRouteBuilder = builder;
  }

  /// 返回的同時再 push
  /// [route] - 將要 push 的頁面
  /// [subRoute] - 跳轉到此大頁面底下的這個子頁面
  /// [popUtil] - pop 直到返回true
  /// [result] - 要返回給前頁面的結果, 當 [popUtil] 為空時有效
  /// [builder] - router構建
  @override
  Future<dynamic> popAndPushPage<T>(
    String route, {
    Map<String, dynamic>? query,
    bool Function(String? route)? popUntil,
    Object? result,
    MixinRouteBuilder<T>? builder,
  }) {
    print("頁面返回並跳頁, 首先頁面返回");
    popPage(popUntil: popUntil, result: result);
    return pushPage(
      route,
      query: query,
      builder: builder,
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
    bool Function(String? route)? popUntil,
    Object? result,
  }) {
    print("頁面返回");
    var navigator = navigatorIns;

    bool isPop = false;
    final popImpl = popUntil ??
        (route) {
          if (isPop) {
            return true;
          } else {
            isPop = true;
            return false;
          }
        };

    // 需要返回多個頁面
    navigator.popUntil((rt) {
      // 匿名路由將會直接跳過
      var name = rt.settings.name;
      if (name == null) {
        // 無名彈窗一率移除
        return false;
      } else if (name == '/') {
        name = _entryPointRouteAlias;
      }
      var isKeep = popImpl(name);
      if (!isKeep) {
        _removeLastPage();
      }
      return isKeep;
    });
    _pageSubject.add(_pageSubject.value);
    _researchCurrentDetailPage();
    return true;

    // if (popUntil != null) {
    //   // 需要返回多個頁面
    //   navigator.popUntil((rt) {
    //     // 匿名路由將會直接跳過
    //     var name = rt.settings.name;
    //     if (name == null) {
    //       // 無名彈窗一率移除
    //       return false;
    //     } else if (name == '/') {
    //       name = _entryPointRouteAlias;
    //     }
    //     var isKeep = popUntil(name);
    //     if (!isKeep) {
    //       _removeLastPage();
    //     }
    //     return isKeep;
    //   });
    //   _pageSubject.add(_pageSubject.value);
    //   _researchCurrentDetailPage();
    //   return true;
    // } else {
    //   // 返回單個頁面, 將
    //   _removeLastPage();
    //   _pageSubject.add(_pageSubject.value);
    //   _researchCurrentDetailPage();
    //   isNeedBlockOnceSystemPopDetect = true;
    //   navigator.pop(result);
    //   return true;
    // }
  }

  @override
  Future<dynamic> pushPage<T>(
    String route, {
    Map<String, dynamic>? query,
    bool? replaceCurrent,
    bool Function(String? route)? removeUntil,
    MixinRouteBuilder<T>? builder,
    Key? key,
  }) async {
    // 分發決定跳轉大頁面還是子頁面
    if (RouteCompute.isAncestorRoute(route)) {
      // 跳轉大頁面默認不替掉當前頁面
      replaceCurrent ??= false;
      // 是跳轉大頁面
      return _pushPage(
        route,
        key: key,
        query: query,
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
        query: query,
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
  Future<T?> _pushPage<T>(
    String route, {
    String? subRoute,
    Map<String, dynamic>? query,
    bool replaceCurrent = false,
    bool Function(String? route)? removeUntil,
    MixinRouteBuilder<T>? builder,
    Key? key,
  }) async {
//    print("頁面跳轉: $route");

    if (!RouteCompute.isAncestorRoute(route)) {
      throw '只有根路由才可以進行 pushPage, 若要跳轉子頁面請改用 setSubPage';
    }

    var navigatorState = navigatorIns;

    final bool Function(String? route)? popImpl;
    if (removeUntil == null) {
      if (replaceCurrent) {
        bool isPop = false;
        popImpl = (route) {
          if (isPop) {
            return true;
          } else {
            isPop = true;
            return false;
          }
        };
      } else {
        popImpl = null;
      }
    } else {
      popImpl = removeUntil;
    }

    // 檢查回退檢測是否已加入
    observable._onDetectPop ??= (name) {
      if (isNeedBlockOnceSystemPopDetect) {
        // 阻擋一次頁面返回請求
        isNeedBlockOnceSystemPopDetect = false;
        return;
      }
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
        query: query,
        builder: builder,
        key: key,
      );
    }

    var routeData = RouteData(
      route,
      targetSubRoute: subRoute,
      query: query,
    );

    if (popImpl != null) {
      _pageSubject.value.add(routeData);
      _pageSubject.add(_pageSubject.value);
      _pageDetailSubject.add(pageHistory.last.route);

      var result = await navigatorState.pushAndRemoveUntil(pageRoute(), (rt) {
        var name = rt.settings.name;
        if (name == null) {
          return false;
        } else if (name == '/') {
          name = _entryPointRouteAlias;
        }
        final isKeep = popImpl!(name);
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
    } else {
      //      print("添加到歷史: ${routeData.route}");
      _pageSubject.value.add(routeData);
      _pageSubject.add(_pageSubject.value);
      _pageDetailSubject.add(pageHistory.last.route);
      return navigatorState.push(pageRoute());
    }

//     if (removeUntil != null) {
//       _pageSubject.value.add(routeData);
//       _pageSubject.add(_pageSubject.value);
//       _pageDetailSubject.add(pageHistory.last.route);
//
//       var result = await navigatorState.pushAndRemoveUntil(pageRoute(), (rt) {
//         var name = rt.settings.name;
//         if (name == null) {
//           return false;
//         } else if (name == '/') {
//           name = _entryPointRouteAlias;
//         }
//         final isKeep = removeUntil(name);
//         print(
//             '$name 是否保留 - $isKeep, 歷史: $pageHistory, ${pageHistory.map((e) => e.route)}');
//
//         // 倒數第二個大頁面routeData
// //        var lastSecondRoute = _pageHistory[_pageHistory.length - 2];
//         if (!isKeep) {
//           // 刪除最後一個大頁面
//           _removeLastSecondPage();
//         }
//         return isKeep;
//       });
//
//       return result;
//     } else if (replaceCurrent) {
//       _removeLastPage();
//       _pageSubject.value.add(routeData);
//       _pageSubject.add(_pageSubject.value);
//       _pageDetailSubject.add(pageHistory.last.route);
//       return await navigatorState.pushReplacement(pageRoute());
//     } else {
// //      print("添加到歷史: ${routeData.route}");
//       _pageSubject.value.add(routeData);
//       _pageSubject.add(_pageSubject.value);
//       _pageDetailSubject.add(pageHistory.last.route);
//       return navigatorState.push(pageRoute());
//     }
  }

  /// 自歷史紀錄刪除大頁面
  void _removeLastPage() {
    if (pageHistory.isEmpty) {
      return;
    }
    var pageData = _pageSubject.value.removeLast();
    var index = _subPageListener
        .lastIndexWhere((element) => element.page.route == pageData.route);
    if (index != -1) {
      _subPageListener.removeRange(index, _subPageListener.length);
    }
    // _subPageListener.removeWhere((e) => e.page.route == pageData.route);
  }

  void _removeLastSecondPage() {
    if (pageHistory.length < 2) {
      return;
    }

    var pageData = _pageSubject.value.removeAt(pageHistory.length - 2);

    // 尋找上上一個大頁面
    var endIndex = _subPageListener.lastIndexWhere(
        (element) => RouteCompute.isAncestorRoute(element.route));

    if (endIndex != -1) {
      var _sub = _subPageListener.sublist(0, endIndex);
      var startIndex = _sub.lastIndexWhere(
          (element) => RouteCompute.isAncestorRoute(element.route));

      if (startIndex != -1 &&
          _subPageListener[startIndex].route == pageData.route) {
        _subPageListener.removeRange(startIndex, endIndex);
      }
    }

    _subPageListener.removeWhere((e) => e.page.route == pageData.route);
  }

  /// 單純取得頁面
  /// [subRoute] - 取得的頁面會自動加子頁面設為此
  /// [entryPoint] 表示此頁面是否為入口頁, 即是 MaterialApp 的 home
  @override
  Widget getPage(
    dynamic route, {
    Map<String, dynamic>? pageQuery,
    Map<String, dynamic>? blocQuery,
    bool entryPoint = false,
    Key? key,
  }) {
    RouteData data;
    if (route is RouteData) {
      data = route;
    } else if (route is String) {
      data = RouteData(route);
    } else {
      print('警告: route 只可帶入 RouteData 或 String');
      throw '警告: route 只可帶入 RouteData 或 String';
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
    String? subRoute,
    Map<String, dynamic>? query,
    MixinRouteBuilder<T>? builder,
    Key? key,
  }) {
    var page = routeWidgetImpl.getPage(
      RouteData(
        route,
        targetSubRoute: subRoute,
        query: query,
      ),
      key: key,
    );

    var routeBuilder = builder ?? _defaultRouteBuilder;
    PageRoute<T>? pageRoute;
    if (routeBuilder == null) {
      pageRoute = MaterialPageRoute(
        builder: (_) => page,
        settings: RouteSettings(name: route),
      );
    } else {
      pageRoute = routeBuilder(page, route) as PageRoute<T>?;
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

class _MxCoreRouteObservable extends NavigatorObserver {
  /// 回退檢測觸發
  void Function(String? route)? _onDetectPop;
  void Function(String? route)? _onDetectPush;

  _MxCoreRouteObservable._();

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('檢測到刪除: ${route.settings.name}, ${previousRoute?.settings.name}');
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    print('檢測到取代: ${newRoute?.settings.name}, ${oldRoute?.settings.name}');
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didStartUserGesture(
      Route<dynamic> route, Route<dynamic>? previousRoute) {
    print(
        '檢測到使用者控制開始: ${route.settings.name}, ${previousRoute?.settings.name}');
    super.didStartUserGesture(route, previousRoute);
  }

  @override
  void didStopUserGesture() {
    print('檢測到使用者控制結束');
    super.didStopUserGesture();
  }

  /// 回退
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print("檢測到回退: ${route.settings.name}, ${previousRoute?.settings.name}");
    _onDetectPop?.call(route.settings.name);
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('檢測到頁面推進: ${route.settings.name}, ${previousRoute?.settings.name}');
    _onDetectPush?.call(route.settings.name);
    super.didPush(route, previousRoute);
  }
}
