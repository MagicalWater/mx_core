import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/router/router.dart';

class RoutePushSecondRoute extends PageRouter {
  RoutePushSecondRoute(RouteOption option)
      : super(Pages.routePushSecond, option) {
    print('sub page check = ${subPages()}');
  }
}
