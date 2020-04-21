import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/router/route.dart';

class RoutePushSecondBloc extends PageBloc {
  RoutePushSecondBloc(RouteOption option)
      : super(Pages.routePushSecond, option);

  @override
  RouteData defaultSubPage() => RouteData(subPages()[0]);

  @override
  void dispose() {
    super.dispose();
  }
}
