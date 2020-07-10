import 'package:flutter/widgets.dart';
import 'package:mx_core/mx_core.dart';

import 'route.dart';

import 'package:mx_core_example/bloc/page/span_grid_bloc.dart';
import 'package:mx_core_example/bloc/page/assist_touch_bloc.dart';
import 'package:mx_core_example/bloc/page/coordinate_layout_bloc.dart';
import 'package:mx_core_example/bloc/page/loading_bloc.dart';
import 'package:mx_core_example/bloc/page/load_provider_bloc.dart';
import 'package:mx_core_example/bloc/page/marquee_bloc.dart';
import 'package:mx_core_example/bloc/page/particle_animation_bloc.dart';
import 'package:mx_core_example/bloc/page/timer_bloc.dart';
import 'package:mx_core_example/bloc/page/animated_core_bloc.dart';
import 'package:mx_core_example/bloc/page/arrow_container_bloc.dart';
import 'package:mx_core_example/bloc/page/normal_popup_bloc.dart';
import 'package:mx_core_example/bloc/page/arrow_popup_bloc.dart';
import 'package:mx_core_example/bloc/page/route_push_entry_bloc.dart';
import 'package:mx_core_example/bloc/page/route_push_second_bloc.dart';
import 'package:mx_core_example/bloc/page/wave_progress_bloc.dart';
import 'package:mx_core_example/bloc/page/test_bloc.dart';
import 'package:mx_core_example/bloc/page/refresh_view_bloc.dart';
import 'package:mx_core_example/bloc/page/lib_ease_refresh_bloc.dart';
import 'package:mx_core_example/bloc/page/introduction_bloc.dart';
import 'package:mx_core_example/bloc/page/route_push_third_bloc.dart';
import 'package:mx_core_example/bloc/page/stateful_button_bloc.dart';
import 'package:mx_core_example/bloc/page/route_push_second/route_push_sub1_bloc.dart';
import 'package:mx_core_example/bloc/page/route_push_second/route_push_sub2_bloc.dart';
import 'package:mx_core_example/bloc/page/route_push_second/route_push_sub3_bloc.dart';
import 'package:mx_core_example/bloc/page/route_push_second/route_push_sub2/route_push_sub_a_bloc.dart';
import 'package:mx_core_example/bloc/page/route_push_second/route_push_sub2/route_push_sub_b_bloc.dart';
/// 儲存所有 route 對應的 page widget
class RouteWidget implements RouteWidgetBase {

  static final _singleton = RouteWidget._internal();

  static RouteWidget getInstance() => _singleton;

  factory RouteWidget() => _singleton;

  RouteWidget._internal();

  @override
  List<String> pageList = [
    Pages.spanGrid,
    Pages.assistTouch,
    Pages.coordinateLayout,
    Pages.loading,
    Pages.loadProvider,
    Pages.marquee,
    Pages.particleAnimation,
    Pages.timer,
    Pages.animatedCore,
    Pages.arrowContainer,
    Pages.normalPopup,
    Pages.arrowPopup,
    Pages.routePushEntry,
    Pages.routePushSecond,
    Pages.waveProgress,
    Pages.test,
    Pages.refreshView,
    Pages.libEaseRefresh,
    Pages.introduction,
    Pages.routePushThird,
    Pages.statefulButton,
    Pages.routePushSub1,
    Pages.routePushSub2,
    Pages.routePushSub3,
    Pages.routePushSubA,
    Pages.routePushSubB,
  ];

  @override
  Widget getPage(RouteData data, {Key key}) {
    final widgetOption = data.copyWith(RouteDataType.widget);
    final blocOption = data.copyWith(RouteDataType.bloc);
    final child = AppRoute.getPage(widgetOption);
    switch (data.route) {
      case Pages.spanGrid:
        return BlocProvider(
          child: child,
          blocBuilder: () => SpanGridBloc(blocOption),
          key: key,
        );
      case Pages.assistTouch:
        return BlocProvider(
          child: child,
          blocBuilder: () => AssistTouchBloc(blocOption),
          key: key,
        );
      case Pages.coordinateLayout:
        return BlocProvider(
          child: child,
          blocBuilder: () => CoordinateLayoutBloc(blocOption),
          key: key,
        );
      case Pages.loading:
        return BlocProvider(
          child: child,
          blocBuilder: () => LoadingBloc(blocOption),
          key: key,
        );
      case Pages.loadProvider:
        return BlocProvider(
          child: child,
          blocBuilder: () => LoadProviderBloc(blocOption),
          key: key,
        );
      case Pages.marquee:
        return BlocProvider(
          child: child,
          blocBuilder: () => MarqueeBloc(blocOption),
          key: key,
        );
      case Pages.particleAnimation:
        return BlocProvider(
          child: child,
          blocBuilder: () => ParticleAnimationBloc(blocOption),
          key: key,
        );
      case Pages.timer:
        return BlocProvider(
          child: child,
          blocBuilder: () => TimerBloc(blocOption),
          key: key,
        );
      case Pages.animatedCore:
        return BlocProvider(
          child: child,
          blocBuilder: () => AnimatedCoreBloc(blocOption),
          key: key,
        );
      case Pages.arrowContainer:
        return BlocProvider(
          child: child,
          blocBuilder: () => ArrowContainerBloc(blocOption),
          key: key,
        );
      case Pages.normalPopup:
        return BlocProvider(
          child: child,
          blocBuilder: () => NormalPopupBloc(blocOption),
          key: key,
        );
      case Pages.arrowPopup:
        return BlocProvider(
          child: child,
          blocBuilder: () => ArrowPopupBloc(blocOption),
          key: key,
        );
      case Pages.routePushEntry:
        return BlocProvider(
          child: child,
          blocBuilder: () => RoutePushEntryBloc(blocOption),
          key: key,
        );
      case Pages.routePushSecond:
        return BlocProvider(
          child: child,
          blocBuilder: () => RoutePushSecondBloc(blocOption),
          key: key,
        );
      case Pages.waveProgress:
        return BlocProvider(
          child: child,
          blocBuilder: () => WaveProgressBloc(blocOption),
          key: key,
        );
      case Pages.test:
        return BlocProvider(
          child: child,
          blocBuilder: () => TestBloc(blocOption),
          key: key,
        );
      case Pages.refreshView:
        return BlocProvider(
          child: child,
          blocBuilder: () => RefreshViewBloc(blocOption),
          key: key,
        );
      case Pages.libEaseRefresh:
        return BlocProvider(
          child: child,
          blocBuilder: () => LibEaseRefreshBloc(blocOption),
          key: key,
        );
      case Pages.introduction:
        return BlocProvider(
          child: child,
          blocBuilder: () => IntroductionBloc(blocOption),
          key: key,
        );
      case Pages.routePushThird:
        return BlocProvider(
          child: child,
          blocBuilder: () => RoutePushThirdBloc(blocOption),
          key: key,
        );
      case Pages.statefulButton:
        return BlocProvider(
          child: child,
          blocBuilder: () => StatefulButtonBloc(blocOption),
          key: key,
        );
      case Pages.routePushSub1:
        return BlocProvider(
          child: child,
          blocBuilder: () => RoutePushSub1Bloc(blocOption),
          key: key,
        );
      case Pages.routePushSub2:
        return BlocProvider(
          child: child,
          blocBuilder: () => RoutePushSub2Bloc(blocOption),
          key: key,
        );
      case Pages.routePushSub3:
        return BlocProvider(
          child: child,
          blocBuilder: () => RoutePushSub3Bloc(blocOption),
          key: key,
        );
      case Pages.routePushSubA:
        return BlocProvider(
          child: child,
          blocBuilder: () => RoutePushSubABloc(blocOption),
          key: key,
        );
      case Pages.routePushSubB:
        return BlocProvider(
          child: child,
          blocBuilder: () => RoutePushSubBBloc(blocOption),
          key: key,
        );
      default:
        print("找無對應的 page, ${data.route}");
        return null;
    }
  }
}