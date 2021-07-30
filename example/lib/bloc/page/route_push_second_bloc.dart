import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/router/router.dart';

class RoutePushSecondBloc extends PageBloc {
  RoutePushSecondBloc(RouteOption option)
      : super(
          Pages.routePushSecond,
          option,
          historyShow: HistoryShow.stack,
        );

  @override
  RouteData defaultSubPage() => RouteData(subPages()[0]);
}
