import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/router/router.dart';

class RoutePushSub2Route extends PageRouter {
  RoutePushSub2Route(RouteOption option) : super(Pages.routePushSub2, option);

  @override
  RouteData? defaultSubPage() => RouteData(subPages().first);
}
