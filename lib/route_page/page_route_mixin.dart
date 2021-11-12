import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

export 'dart:async';

mixin PageRouteMixin implements AppRouterBase {
  /// 取得路由為 [page] 的頁面是否顯示中
  @override
  bool isPageShowing(String page) => appRouter.isPageShowing(page);

  /// 返回的同時再 push
  /// [route] - 將要 push 的頁面
  /// [subRoute] - 跳轉到此大頁面底下的這個子頁面
  /// [popUtil] - pop 直到返回true
  /// [result] - 要返回給前頁面的結果, 當 [popUtil] 為空時有效
  @override
  Future<dynamic> popAndPushPage<T>(
    String route, {
    Map<String, dynamic>? query,
    bool Function(String? route)? popUntil,
    Object? result,
  }) =>
      appRouter.popAndPushPage(
        route,
        query: query,
        popUntil: popUntil,
        result: result,
      );

  @override
  bool popPage({
    bool Function(String? route)? popUntil,
    Object? result,
  }) =>
      appRouter.popPage(
        popUntil: popUntil,
        result: result,
      );

  /// 發起大頁面跳轉
  /// [subRoute] - 跳轉到此大頁面底下的這個子頁面
  /// [replaceCurrent] - 替換掉當前頁面, 即無法再返回當前頁面
  /// [removeUtil] - 刪除舊頁面直到返回true
  /// [builder] - 自定義構建 PageRoute
  @override
  Future<dynamic> pushPage<T>(
    String route, {
    Map<String, dynamic>? query,
    bool? replaceCurrent,
    bool Function(String? route)? removeUntil,
    MixinRouteBuilder<T>? builder,
    Key? key,
  }) =>
      appRouter.pushPage(
        route,
        query: query,
        replaceCurrent: replaceCurrent,
        removeUntil: removeUntil,
        builder: builder,
        key: key,
      );

  /// 可以彈出子頁面嗎
  @override
  bool canPopSubPage(
    String route, {
    PopLevel level = PopLevel.exact,
  }) =>
      appRouter.canPopSubPage(route, level: level);

  /// 彈出子頁面
  @override
  bool popSubPage(
    String route, {
    PopLevel level = PopLevel.exact,
    bool Function(String route)? popUntil,
  }) =>
      appRouter.popSubPage(route, level: level);
}
