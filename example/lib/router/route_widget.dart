import 'package:flutter/widgets.dart';
import 'package:mx_core/mx_core.dart';

import 'route.dart';

import 'package:mx_core_example/bloc/page/introduction_bloc.dart';
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
import 'package:mx_core_example/bloc/page/refresh_view_bloc.dart';
import 'package:mx_core_example/bloc/page/lib_ease_refresh_bloc.dart';
import 'package:mx_core_example/bloc/page/span_grid_bloc.dart';
import 'package:mx_core_example/bloc/page/tab_bar_bloc.dart';
import 'package:mx_core_example/bloc/page/line_indicator_bloc.dart';
import 'package:mx_core_example/bloc/page/route_push_third_bloc.dart';
import 'package:mx_core_example/bloc/page/stateful_button_bloc.dart';
import 'package:mx_core_example/bloc/page/wave_progress_bloc.dart';
import 'package:mx_core_example/bloc/page/test_bloc.dart';
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
    Pages.introduction,
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
    Pages.refreshView,
    Pages.libEaseRefresh,
    Pages.spanGrid,
    Pages.tabBar,
    Pages.lineIndicator,
    Pages.routePushThird,
    Pages.statefulButton,
    Pages.waveProgress,
    Pages.test,
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
    Widget getChild(BuildContext context) => AppRoute.getPage(widgetOption);
    switch (data.route) {
      case Pages.introduction:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => IntroductionBloc(blocOption),
          key: key,
        );
      case Pages.assistTouch:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => AssistTouchBloc(blocOption),
          key: key,
        );
      case Pages.coordinateLayout:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => CoordinateLayoutBloc(blocOption),
          key: key,
        );
      case Pages.loading:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => LoadingBloc(blocOption),
          key: key,
        );
      case Pages.loadProvider:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => LoadProviderBloc(blocOption),
          key: key,
        );
      case Pages.marquee:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => MarqueeBloc(blocOption),
          key: key,
        );
      case Pages.particleAnimation:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => ParticleAnimationBloc(blocOption),
          key: key,
        );
      case Pages.timer:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => TimerBloc(blocOption),
          key: key,
        );
      case Pages.animatedCore:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => AnimatedCoreBloc(blocOption),
          key: key,
        );
      case Pages.arrowContainer:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => ArrowContainerBloc(blocOption),
          key: key,
        );
      case Pages.normalPopup:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => NormalPopupBloc(blocOption),
          key: key,
        );
      case Pages.arrowPopup:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => ArrowPopupBloc(blocOption),
          key: key,
        );
      case Pages.routePushEntry:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => RoutePushEntryBloc(blocOption),
          key: key,
        );
      case Pages.routePushSecond:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => RoutePushSecondBloc(blocOption),
          key: key,
        );
      case Pages.refreshView:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => RefreshViewBloc(blocOption),
          key: key,
        );
      case Pages.libEaseRefresh:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => LibEaseRefreshBloc(blocOption),
          key: key,
        );
      case Pages.spanGrid:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => SpanGridBloc(blocOption),
          key: key,
        );
      case Pages.tabBar:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => TabBarBloc(blocOption),
          key: key,
        );
      case Pages.lineIndicator:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => LineIndicatorBloc(blocOption),
          key: key,
        );
      case Pages.routePushThird:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => RoutePushThirdBloc(blocOption),
          key: key,
        );
      case Pages.statefulButton:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => StatefulButtonBloc(blocOption),
          key: key,
        );
      case Pages.waveProgress:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => WaveProgressBloc(blocOption),
          key: key,
        );
      case Pages.test:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => TestBloc(blocOption),
          key: key,
        );
      case Pages.routePushSub1:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => RoutePushSub1Bloc(blocOption),
          key: key,
        );
      case Pages.routePushSub2:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => RoutePushSub2Bloc(blocOption),
          key: key,
        );
      case Pages.routePushSub3:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => RoutePushSub3Bloc(blocOption),
          key: key,
        );
      case Pages.routePushSubA:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => RoutePushSubABloc(blocOption),
          key: key,
        );
      case Pages.routePushSubB:
        return BlocProvider(
          childBuilder: getChild,
          blocBuilder: () => RoutePushSubBBloc(blocOption),
          key: key,
        );
      default:
        print("找無對應的 page, ${data.route}");
        return null;
    }
  }
}