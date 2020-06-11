import 'route_compute.dart';

/// 路由
abstract class RouteOption {
  String route;

  String targetSubRoute;

  Map<String, dynamic> get query;

  /// 取得 從 [_route] 需要跳轉到 [_targetRoute], 下個 route
  String get nextRoute {
    if (targetSubRoute != null && route != targetSubRoute) {
      return RouteCompute.getNextRoute(parent: route, sub: targetSubRoute);
    }
    return null;
  }

  /// 取得 query 挾帶的資料
  T getQuery<T>(String key) {
    if (query != null) return query[key];
    return null;
  }

  /// 取得 query 是否存在某個 key 的資料
  bool queryContainsKey(String key) {
    if (query != null) return query.containsKey(key);
    return false;
  }
}

class RouteData extends RouteOption {
  @override
  final String route;

  @override
  final String targetSubRoute;

  final Map<String, dynamic> blocQuery;
  final Map<String, dynamic> widgetQuery;

  RouteDataType type;

  /// 是否為回退 route
  bool isPop;

  /// 是否強制建立新元件
  bool forceNew;

  @override
  Map<String, dynamic> get query =>
      (type ?? RouteDataType.widget) == RouteDataType.widget
          ? widgetQuery
          : blocQuery;

  RouteData(
    this.route, {
    this.targetSubRoute,
    this.widgetQuery,
    this.blocQuery,
  })  : this.isPop = false,
        this.forceNew = false;

  RouteData copyWith(RouteDataType type) {
    var data = RouteData(
      route,
      targetSubRoute: targetSubRoute,
      widgetQuery: widgetQuery,
      blocQuery: blocQuery,
    )
      ..type = type
      ..isPop = isPop
      ..forceNew = forceNew;
    return data;
  }
}

enum RouteDataType {
  bloc,
  widget,
}
