import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

typedef MixinRouteBuilder<T> = PageRoute<T> Function(
  Widget child,
  String name,
);

abstract class RouteWidgetBase {
  List<String> get pageList;

  Widget getPage(RouteData data, {Key? key});
}

/// 子頁面監聽 func
/// 返回 [bool] 為代表是否處理此次的子頁面監聽跳轉
typedef bool RouteHandler(RouteData routeData);

///元件(包含頁面元件)跳轉相關, 使用方式參考 route_mixin
abstract class AppRouterBase {
  /// 取得路由為 [page] 的頁面是否顯示中
  bool isPageShowing(String page);

  /// 發起頁面跳轉
  /// [subRoute] - 跳轉到此大頁面底下的這個子頁面
  /// [replaceCurrent] - 替換掉當前頁面, 即無法再返回當前頁面
  /// [removeUtil] - 刪除舊頁面直到返回true
  /// [builder] - 自定義構建 PageRoute
  Future<dynamic> pushPage<T>(
    String route, {
    Map<String, dynamic>? query,
    bool? replaceCurrent,
    bool Function(String? route)? removeUntil,
    MixinRouteBuilder<T>? builder,
    Key? key,
  });

  /// 返回的同時再 push
  /// [route] - 將要 push 的頁面
  /// [subRoute] - 跳轉到此大頁面底下的這個子頁面
  /// [popUtil] - pop 直到返回true
  /// [result] - 要返回給前頁面的結果, 當 [popUtil] 為空時有效
  Future<dynamic> popAndPushPage<T>(
    String route, {
    Map<String, dynamic>? query,
    bool Function(String? route)? popUntil,
    Object? result,
  });

  /// 返回 page
  /// [result] - 要返回給前頁面的結果, 當 [popUtil] 為空時有效
  bool popPage({
    bool Function(String? route)? popUntil,
    Object? result,
  });

  /// 可以彈出子頁面嗎
  bool canPopSubPage(
    String route, {
    PopLevel level = PopLevel.exact,
  });

  /// 彈出子頁面
  bool popSubPage(
    String route, {
    PopLevel level = PopLevel.exact,
    bool Function(String route)? popUntil,
  });
}

abstract class RoutePageBase {
  /// 直接取得page實體
  /// [route] - 可帶入 [String] 或 [RouteData]
  ///   若帶入字串, 將會自動組成 [RouteData]
  ///   若帶入 [RouteData], 則 [pageQuery] 以及 [blocQuery] 失效
  Widget getPage(
    dynamic route, {
    Key? key,
    Map<String, dynamic>? pageQuery,
    Map<String, dynamic>? blocQuery,
    bool entryPoint = false,
  });

  /// 註冊子頁面監聽
  void registerSubPageListener({
    required PageInterface page,
    required bool Function(RouteData data) isHandleRoute,
    required bool Function(RouteData data,
            {bool Function(String route)? popUntil})
        dispatchSubPage,
    required void Function(String route) forceModifyPageDetail,
    required String? Function({
      bool Function(String route)? popUntil,
    })
        popSubPage,
  });

  /// 取消註冊子頁面監聽
  void unregisterSubPageListener(PageInterface page);
}
