import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

typedef MixinRouteBuilder<T> = PageRoute<T> Function(
  BuildContext context,
  Widget child,
  String name,
);

abstract class RouteWidgetBase {
  List<String> pageList;

  Widget getPage(RouteData data);
}

/// 子頁面監聽 func
/// 返回 [bool] 為代表是否處理此次的子頁面監聽跳轉
typedef bool RouteHandler(RouteData routeData);

///元件(包含頁面元件)跳轉相關, 使用方式參考 route_mixin
abstract class RouteMixinBase {
  /// 取得路由為 [page] 的頁面是否顯示中
  bool isPageShowing(String page);

  /// 取得子頁面
  Widget getSubPage(RouteData data);

  /// 設定子頁面
  bool setSubPage(
    String route, {
    BuildContext context,
    Map<String, dynamic> pageQuery,
    Map<String, dynamic> blocQuery,
    bool replaceCurrent = false,
  });

  /// 發起頁面跳轉
  /// [subRoute] - 跳轉到此大頁面底下的這個子頁面
  /// [replaceCurrent] - 替換掉當前頁面, 即無法再返回當前頁面
  /// [removeUtil] - 刪除舊頁面直到返回true
  /// [builder] - 自定義構建 PageRoute
  Future<T> pushPage<T>(
    String route,
    BuildContext context, {
    String subRoute,
    Map<String, dynamic> pageQuery,
    Map<String, dynamic> blocQuery,
    bool replaceCurrent = false,
    bool Function(String route) removeUntil,
    MixinRouteBuilder<T> builder,
  });

  /// 返回的同時再 push
  /// [route] - 將要 push 的頁面
  /// [subRoute] - 跳轉到此大頁面底下的這個子頁面
  /// [popUtil] - pop 直到返回true
  /// [result] - 要返回給前頁面的結果, 當 [popUtil] 為空時有效
  Future<T> popAndPushPage<T>(
    String route,
    BuildContext context, {
    String subRoute,
    Map<String, dynamic> pageQuery,
    Map<String, dynamic> blocQuery,
    bool Function(String route) popUntil,
    Object result,
  });

  /// 返回 page
  /// [result] - 要返回給前頁面的結果, 當 [popUtil] 為空時有效
  bool popPage(
    BuildContext context, {
    bool Function(String route) popUntil,
    Object result,
  });
}

abstract class RoutePageBase {
  /// 直接取得page實體
  /// [subRoute] - 取得的頁面會自動加子頁面設為此
  Widget getPage(
    String route, {
    String subRoute,
    Map<String, dynamic> pageQuery,
    Map<String, dynamic> blocQuery,
  });

  /// 取得子頁面的串流
//  Stream<RouteData> getSubPageStream([String page]);

  /// 註冊子頁面監聽
  void registerSubPageListener(String page, RouteHandler handler, int hashCode);

  /// 取消註冊子頁面監聽
  void unregisterSubPageListener(String page, int hashCode);
}
