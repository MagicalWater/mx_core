import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/router/route.dart';

class LoadingBloc extends PageBloc {

  LoadingBloc(RouteOption option) : super(Pages.loading, option);

  @override
  void dispose() {
    super.dispose();
  }
}