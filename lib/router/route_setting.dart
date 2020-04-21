import 'route_mixin.dart';
import 'route_mixin_base.dart';

/// 上層呼叫此方法設置route
/// [routeMixin] - 上層專案 使用 routeMixinBase 的實現類別
/// 通常為 ApplicationBloc.getInstance()
///
/// [routeWidget] - 上層專案 使用  RouteMixin 的實現類別
/// 通常為 RouteWidget.getInstance()
void settingRoute({
  RouteMixin routeMixin,
  RouteWidgetBase routeWidget,
}) {
  routeMixinImpl = routeMixin;
  routeWidgetImpl = routeWidget;
}

RouteMixin routeMixinImpl;
RouteWidgetBase routeWidgetImpl;