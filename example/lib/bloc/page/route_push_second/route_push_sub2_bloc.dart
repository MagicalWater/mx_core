import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/router/route.dart';

class RoutePushSub2Bloc extends PageBloc {
  RoutePushSub2Bloc(RouteOption option) : super(Pages.routePushSub2, option);

  @override
  RouteData defaultSubPage() => RouteData(subPages()[0]);

  @override
  void dispose() {
    super.dispose();
  }
}
