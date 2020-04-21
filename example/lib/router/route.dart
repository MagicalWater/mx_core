import 'package:annotation_route/route.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

import 'route.internal.dart';

export 'package:annotation_route/route.dart';

export 'route_widget.dart';
export 'routes.dart';

@ARouteRoot()
class AppRoute {
  static final ARouterInternalImpl _internal = ARouterInternalImpl();

  static ARouterResult _get(RouteOption route) {
    ARouterResult routeResult = _internal.findPage(
      ARouteOption(route.route, route.query),
      route,
    );
    return routeResult;
  }

  /// 取得匹配路徑的頁面
  static Widget getPage(
    RouteOption route, {
    Widget notFound,
  }) {
    var result = _get(route);
    if (result.state == ARouterResultState.FOUND) {
      return result.widget;
    }

    /// 返回未匹配路徑的頁面
    return notFound ??
        Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Text('NOT FOUND'),
          ),
        );
  }
}
