import 'route_mixin.dart';
import 'route_mixin_base.dart';

/// 上層呼叫此方法設置route
/// [routeMixin] - 上層專案 使用 routeMixinBase 的實現類別
/// 通常為 ApplicationBloc.getInstance()
///
/// [routeWidget] - 上層專案 使用  RouteMixin 的實現類別
/// 通常為 RouteWidget.getInstance()
void settingRoute({
  required RouteMixin routeMixin,
  required RouteWidgetBase routeWidget,
}) {
  routeMixinImpl = routeMixin;
  routeWidgetImpl = routeWidget;
}

late RouteMixin routeMixinImpl;
late RouteWidgetBase routeWidgetImpl;
