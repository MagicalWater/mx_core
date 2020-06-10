import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

//mixin PageRouteMixin implements RouteMixinBase {
//
//  /// 取得子頁面
//  @override
//  Widget getSubPage(RouteData data) => routeMixinImpl?.getSubPage(data);
//
//  /// 取得路由為 [page] 的頁面是否顯示中
//  @override
//  bool isPageShowing(String page) => routeMixinImpl?.isPageShowing(page);
//
//  /// 返回的同時再 push
//  /// [route] - 將要 push 的頁面
//  /// [subRoute] - 跳轉到此大頁面底下的這個子頁面
//  /// [popUtil] - pop 直到返回true
//  /// [result] - 要返回給前頁面的結果, 當 [popUtil] 為空時有效
//  @override
//  Future<T> popAndPushPage<T>(String route, BuildContext context,
//          {String subRoute,
//          Map<String, dynamic> pageQuery,
//          Map<String, dynamic> blocQuery,
//          popUntil,
//          Object result}) =>
//      routeMixinImpl?.popAndPushPage(route, context,
//          pageQuery: pageQuery,
//          blocQuery: blocQuery,
//          popUntil: popUntil,
//          result: result);
//
//  @override
//  bool popPage(BuildContext context,
//          {bool Function(String route) popUntil, Object result}) =>
//      routeMixinImpl?.popPage(context, popUntil: popUntil, result: result);
//
//  /// 發起大頁面跳轉
//  /// [subRoute] - 跳轉到此大頁面底下的這個子頁面
//  /// [replaceCurrent] - 替換掉當前頁面, 即無法再返回當前頁面
//  /// [removeUtil] - 刪除舊頁面直到返回true
//  /// [builder] - 自定義構建 PageRoute
//  @override
//  Future<T> pushPage<T>(String route, BuildContext context,
//          {String subRoute,
//          Map<String, dynamic> pageQuery,
//          Map<String, dynamic> blocQuery,
//          bool replaceCurrent = false,
//          bool Function(String route) removeUntil,
//          MixinRouteBuilder builder}) =>
//      routeMixinImpl?.pushPage(route, context,
//          subRoute: subRoute,
//          pageQuery: pageQuery,
//          blocQuery: blocQuery,
//          replaceCurrent: replaceCurrent,
//          removeUntil: removeUntil,
//          builder: builder);
//
//  /// 跳轉子頁面
//  @override
//  bool setSubPage(String route,
//          {BuildContext context,
//          Map<String, dynamic> pageQuery,
//          Map<String, dynamic> blocQuery,
//          bool replaceCurrent = false}) =>
//      routeMixinImpl?.setSubPage(route,
//          context: context,
//          pageQuery: pageQuery,
//          blocQuery: blocQuery,
//          replaceCurrent: replaceCurrent);
//}
