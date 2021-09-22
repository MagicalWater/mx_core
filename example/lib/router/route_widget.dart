import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

import 'routes.dart';

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
import 'package:mx_core_example/bloc/page/span_grid_bloc.dart';
import 'package:mx_core_example/bloc/page/tab_bar_bloc.dart';
import 'package:mx_core_example/bloc/page/line_indicator_bloc.dart';
import 'package:mx_core_example/bloc/page/bullet_shape_bloc.dart';
import 'package:mx_core_example/bloc/page/k_chart_bloc.dart';
import 'package:mx_core_example/bloc/page/route_push_third_bloc.dart';
import 'package:mx_core_example/bloc/page/stateful_button_bloc.dart';
import 'package:mx_core_example/bloc/page/wave_progress_bloc.dart';
import 'package:mx_core_example/bloc/page/test_bloc.dart';
import 'package:mx_core_example/bloc/page/refresh_view_bloc.dart';
import 'package:mx_core_example/bloc/page/lib_ease_refresh_bloc.dart';
import 'package:mx_core_example/bloc/page/route_push_second/route_push_sub1_bloc.dart';
import 'package:mx_core_example/bloc/page/route_push_second/route_push_sub2_bloc.dart';
import 'package:mx_core_example/bloc/page/route_push_second/route_push_sub3_bloc.dart';
import 'package:mx_core_example/bloc/page/route_push_second/route_push_sub2/route_push_sub_a_bloc.dart';
import 'package:mx_core_example/bloc/page/route_push_second/route_push_sub2/route_push_sub_b_bloc.dart';
import 'package:mx_core_example/ui/page/introduction_page.dart';
import 'package:mx_core_example/ui/page/assist_touch_page.dart';
import 'package:mx_core_example/ui/page/coordinate_layout_page.dart';
import 'package:mx_core_example/ui/page/loading_page.dart';
import 'package:mx_core_example/ui/page/load_provider_page.dart';
import 'package:mx_core_example/ui/page/marquee_page.dart';
import 'package:mx_core_example/ui/page/particle_animation_page.dart';
import 'package:mx_core_example/ui/page/timer_page.dart';
import 'package:mx_core_example/ui/page/animated_core_page.dart';
import 'package:mx_core_example/ui/page/arrow_container_page.dart';
import 'package:mx_core_example/ui/page/normal_popup_page.dart';
import 'package:mx_core_example/ui/page/arrow_popup_page.dart';
import 'package:mx_core_example/ui/page/route_push_entry_page.dart';
import 'package:mx_core_example/ui/page/route_push_second_page.dart';
import 'package:mx_core_example/ui/page/span_grid_page.dart';
import 'package:mx_core_example/ui/page/tab_bar_page.dart';
import 'package:mx_core_example/ui/page/line_indicator_page.dart';
import 'package:mx_core_example/ui/page/bullet_shape_page.dart';
import 'package:mx_core_example/ui/page/k_chart_page.dart';
import 'package:mx_core_example/ui/page/route_push_third_page.dart';
import 'package:mx_core_example/ui/page/stateful_button_page.dart';
import 'package:mx_core_example/ui/page/wave_progress_page.dart';
import 'package:mx_core_example/ui/page/test_page.dart';
import 'package:mx_core_example/ui/page/refresh_view_page.dart';
import 'package:mx_core_example/ui/page/lib_ease_refresh_page.dart';
import 'package:mx_core_example/ui/page/route_push_second/route_push_sub1_page.dart';
import 'package:mx_core_example/ui/page/route_push_second/route_push_sub2_page.dart';
import 'package:mx_core_example/ui/page/route_push_second/route_push_sub3_page.dart';
import 'package:mx_core_example/ui/page/route_push_second/route_push_sub2/route_push_sub_a_page.dart';
import 'package:mx_core_example/ui/page/route_push_second/route_push_sub2/route_push_sub_b_page.dart';
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
    Pages.spanGrid,
    Pages.tabBar,
    Pages.lineIndicator,
    Pages.bulletShape,
    Pages.kChart,
    Pages.routePushThird,
    Pages.statefulButton,
    Pages.waveProgress,
    Pages.test,
    Pages.refreshView,
    Pages.libEaseRefresh,
    Pages.routePushSub1,
    Pages.routePushSub2,
    Pages.routePushSub3,
    Pages.routePushSubA,
    Pages.routePushSubB,
  ];

  @override
  Widget getPage(RouteData data, {Key? key}) {
    final widgetOption = data.copyWith(RouteDataType.widget);
    final blocOption = data.copyWith(RouteDataType.bloc);
    switch (data.route) {
      case Pages.introduction:
        return BlocProvider(
          childBuilder: (context) => IntroductionPage(widgetOption),
          blocBuilder: () => IntroductionBloc(blocOption),
          key: key,
        );
      case Pages.assistTouch:
        return BlocProvider(
          childBuilder: (context) => AssistTouchPage(widgetOption),
          blocBuilder: () => AssistTouchBloc(blocOption),
          key: key,
        );
      case Pages.coordinateLayout:
        return BlocProvider(
          childBuilder: (context) => CoordinateLayoutPage(widgetOption),
          blocBuilder: () => CoordinateLayoutBloc(blocOption),
          key: key,
        );
      case Pages.loading:
        return BlocProvider(
          childBuilder: (context) => LoadingPage(widgetOption),
          blocBuilder: () => LoadingBloc(blocOption),
          key: key,
        );
      case Pages.loadProvider:
        return BlocProvider(
          childBuilder: (context) => LoadProviderPage(widgetOption),
          blocBuilder: () => LoadProviderBloc(blocOption),
          key: key,
        );
      case Pages.marquee:
        return BlocProvider(
          childBuilder: (context) => MarqueePage(widgetOption),
          blocBuilder: () => MarqueeBloc(blocOption),
          key: key,
        );
      case Pages.particleAnimation:
        return BlocProvider(
          childBuilder: (context) => ParticleAnimationPage(widgetOption),
          blocBuilder: () => ParticleAnimationBloc(blocOption),
          key: key,
        );
      case Pages.timer:
        return BlocProvider(
          childBuilder: (context) => TimerPage(widgetOption),
          blocBuilder: () => TimerBloc(blocOption),
          key: key,
        );
      case Pages.animatedCore:
        return BlocProvider(
          childBuilder: (context) => AnimatedCorePage(widgetOption),
          blocBuilder: () => AnimatedCoreBloc(blocOption),
          key: key,
        );
      case Pages.arrowContainer:
        return BlocProvider(
          childBuilder: (context) => ArrowContainerPage(widgetOption),
          blocBuilder: () => ArrowContainerBloc(blocOption),
          key: key,
        );
      case Pages.normalPopup:
        return BlocProvider(
          childBuilder: (context) => NormalPopupPage(widgetOption),
          blocBuilder: () => NormalPopupBloc(blocOption),
          key: key,
        );
      case Pages.arrowPopup:
        return BlocProvider(
          childBuilder: (context) => ArrowPopupPage(widgetOption),
          blocBuilder: () => ArrowPopupBloc(blocOption),
          key: key,
        );
      case Pages.routePushEntry:
        return BlocProvider(
          childBuilder: (context) => RoutePushEntryPage(widgetOption),
          blocBuilder: () => RoutePushEntryBloc(blocOption),
          key: key,
        );
      case Pages.routePushSecond:
        return BlocProvider(
          childBuilder: (context) => RoutePushSecondPage(widgetOption),
          blocBuilder: () => RoutePushSecondBloc(blocOption),
          key: key,
        );
      case Pages.spanGrid:
        return BlocProvider(
          childBuilder: (context) => SpanGridPage(widgetOption),
          blocBuilder: () => SpanGridBloc(blocOption),
          key: key,
        );
      case Pages.tabBar:
        return BlocProvider(
          childBuilder: (context) => TabBarPage(widgetOption),
          blocBuilder: () => TabBarBloc(blocOption),
          key: key,
        );
      case Pages.lineIndicator:
        return BlocProvider(
          childBuilder: (context) => LineIndicatorPage(widgetOption),
          blocBuilder: () => LineIndicatorBloc(blocOption),
          key: key,
        );
      case Pages.bulletShape:
        return BlocProvider(
          childBuilder: (context) => BulletShapePage(widgetOption),
          blocBuilder: () => BulletShapeBloc(blocOption),
          key: key,
        );
      case Pages.kChart:
        return BlocProvider(
          childBuilder: (context) => KChartPage(widgetOption),
          blocBuilder: () => KChartBloc(blocOption),
          key: key,
        );
      case Pages.routePushThird:
        return BlocProvider(
          childBuilder: (context) => RoutePushThirdPage(widgetOption),
          blocBuilder: () => RoutePushThirdBloc(blocOption),
          key: key,
        );
      case Pages.statefulButton:
        return BlocProvider(
          childBuilder: (context) => StatefulButtonPage(widgetOption),
          blocBuilder: () => StatefulButtonBloc(blocOption),
          key: key,
        );
      case Pages.waveProgress:
        return BlocProvider(
          childBuilder: (context) => WaveProgressPage(widgetOption),
          blocBuilder: () => WaveProgressBloc(blocOption),
          key: key,
        );
      case Pages.test:
        return BlocProvider(
          childBuilder: (context) => TestPage(widgetOption),
          blocBuilder: () => TestBloc(blocOption),
          key: key,
        );
      case Pages.refreshView:
        return BlocProvider(
          childBuilder: (context) => RefreshViewPage(widgetOption),
          blocBuilder: () => RefreshViewBloc(blocOption),
          key: key,
        );
      case Pages.libEaseRefresh:
        return BlocProvider(
          childBuilder: (context) => LibEaseRefreshPage(widgetOption),
          blocBuilder: () => LibEaseRefreshBloc(blocOption),
          key: key,
        );
      case Pages.routePushSub1:
        return BlocProvider(
          childBuilder: (context) => RoutePushSub1Page(widgetOption),
          blocBuilder: () => RoutePushSub1Bloc(blocOption),
          key: key,
        );
      case Pages.routePushSub2:
        return BlocProvider(
          childBuilder: (context) => RoutePushSub2Page(widgetOption),
          blocBuilder: () => RoutePushSub2Bloc(blocOption),
          key: key,
        );
      case Pages.routePushSub3:
        return BlocProvider(
          childBuilder: (context) => RoutePushSub3Page(widgetOption),
          blocBuilder: () => RoutePushSub3Bloc(blocOption),
          key: key,
        );
      case Pages.routePushSubA:
        return BlocProvider(
          childBuilder: (context) => RoutePushSubAPage(widgetOption),
          blocBuilder: () => RoutePushSubABloc(blocOption),
          key: key,
        );
      case Pages.routePushSubB:
        return BlocProvider(
          childBuilder: (context) => RoutePushSubBPage(widgetOption),
          blocBuilder: () => RoutePushSubBBloc(blocOption),
          key: key,
        );
      default:
        print("找無對應的 page, ${data.route}");
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Text('NOT FOUND'),
          ),
        );
    }
  }
}