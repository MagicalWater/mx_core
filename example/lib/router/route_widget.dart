import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/ui/page/animated_core/animated_core.dart';
import 'package:mx_core_example/ui/page/arrow_container/arrow_container.dart';
import 'package:mx_core_example/ui/page/arrow_popup/arrow_popup.dart';
import 'package:mx_core_example/ui/page/assist_touch/assis_touch.dart';
import 'package:mx_core_example/ui/page/bullet_shape/bullet_touch.dart';
import 'package:mx_core_example/ui/page/coordinate_layout/coordinate_layout.dart';
import 'package:mx_core_example/ui/page/force_center_layout/force_center_layout.dart';
import 'package:mx_core_example/ui/page/introduction/introduction.dart';
import 'package:mx_core_example/ui/page/lib_ease_refresh/lib_ease_refresh.dart';
import 'package:mx_core_example/ui/page/line_indicator/line_indicator.dart';
import 'package:mx_core_example/ui/page/load_provider/load_provider.dart';
import 'package:mx_core_example/ui/page/loading/loading.dart';
import 'package:mx_core_example/ui/page/marquee/marquee.dart';
import 'package:mx_core_example/ui/page/normal_popup/normal_popup.dart';
import 'package:mx_core_example/ui/page/particle_animation/particle_animation.dart';
import 'package:mx_core_example/ui/page/refresh_view/refresh_view.dart';
import 'package:mx_core_example/ui/page/rotation_3d/rotation_3d.dart';
import 'package:mx_core_example/ui/page/route_push_entry/route_push_entry.dart';
import 'package:mx_core_example/ui/page/route_push_second/route_push_second.dart';
import 'package:mx_core_example/ui/page/route_push_sub1/route_push_sub1.dart';
import 'package:mx_core_example/ui/page/route_push_sub2/route_push_sub2.dart';
import 'package:mx_core_example/ui/page/route_push_sub3/route_push_sub3.dart';
import 'package:mx_core_example/ui/page/route_push_sub_a/route_push_sub_a.dart';
import 'package:mx_core_example/ui/page/route_push_sub_b/route_push_sub_b.dart';
import 'package:mx_core_example/ui/page/route_push_third/route_push_third.dart';
import 'package:mx_core_example/ui/page/span_grid/span_grid.dart';
import 'package:mx_core_example/ui/page/stateful_button/stateful_button.dart';
import 'package:mx_core_example/ui/page/tab_bar/tab_bar.dart';
import 'package:mx_core_example/ui/page/timer/timer.dart';
import 'package:mx_core_example/ui/page/wave_progress/wave_progress.dart';
import 'package:mx_core_example/ui/page/widget_switcher/widget_switcher.dart';

import 'routes.dart';

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
    Pages.routePushThird,
    Pages.statefulButton,
    Pages.waveProgress,
    // Pages.refreshView,
    // Pages.libEaseRefresh,
    Pages.routePushSub1,
    Pages.routePushSub2,
    Pages.routePushSub3,
    Pages.routePushSubA,
    Pages.routePushSubB,
    Pages.forceCenterLayout,
    Pages.widgetSwitcher,
    Pages.rotation3D,
  ];

  @override
  Widget getPage(RouteData data, {Key? key}) {
    final option = data.copyWith();
    switch (data.route) {
      case Pages.introduction:
        return RouterMiddler(
          childBuilder: (context) => IntroductionPage(option),
          routeBuilder: () => IntroductionRoute(option),
          key: key,
        );
      case Pages.assistTouch:
        return RouterMiddler(
          childBuilder: (context) => AssistTouchPage(option),
          routeBuilder: () => AssistTouchRoute(option),
          key: key,
        );
      case Pages.coordinateLayout:
        return RouterMiddler(
          childBuilder: (context) => CoordinateLayoutPage(option),
          routeBuilder: () => CoordinateLayoutRoute(option),
          key: key,
        );
      case Pages.loading:
        return RouterMiddler(
          childBuilder: (context) => LoadingPage(option),
          routeBuilder: () => LoadingRoute(option),
          key: key,
        );
      case Pages.loadProvider:
        return RouterMiddler(
          childBuilder: (context) => LoadProviderPage(option),
          routeBuilder: () => LoadProviderRoute(option),
          key: key,
        );
      case Pages.marquee:
        return RouterMiddler(
          childBuilder: (context) => MarqueePage(option),
          routeBuilder: () => MarqueeRoute(option),
          key: key,
        );
      case Pages.particleAnimation:
        return RouterMiddler(
          childBuilder: (context) => ParticleAnimationPage(option),
          routeBuilder: () => ParticleAnimationRoute(option),
          key: key,
        );
      case Pages.timer:
        return RouterMiddler(
          childBuilder: (context) => TimerPage(option),
          routeBuilder: () => TimerRoute(option),
          key: key,
        );
      case Pages.animatedCore:
        return RouterMiddler(
          childBuilder: (context) => AnimatedCorePage(option),
          routeBuilder: () => AnimatedCoreRoute(option),
          key: key,
        );
      case Pages.arrowContainer:
        return RouterMiddler(
          childBuilder: (context) => ArrowContainerPage(option),
          routeBuilder: () => ArrowContainerRoute(option),
          key: key,
        );
      case Pages.normalPopup:
        return RouterMiddler(
          childBuilder: (context) => NormalPopupPage(option),
          routeBuilder: () => NormalPopupRoute(option),
          key: key,
        );
      case Pages.arrowPopup:
        return RouterMiddler(
          childBuilder: (context) => ArrowPopupPage(option),
          routeBuilder: () => ArrowPopupRoute(option),
          key: key,
        );
      case Pages.routePushEntry:
        return RouterMiddler(
          childBuilder: (context) => RoutePushEntryPage(option),
          routeBuilder: () => RoutePushEntryRoute(option),
          key: key,
        );
      case Pages.routePushSecond:
        return RouterMiddler(
          childBuilder: (context) => RoutePushSecondPage(option),
          routeBuilder: () => RoutePushSecondRoute(option),
          key: key,
        );
      case Pages.spanGrid:
        return RouterMiddler(
          childBuilder: (context) => SpanGridPage(option),
          routeBuilder: () => SpanGridRoute(option),
          key: key,
        );
      case Pages.tabBar:
        return RouterMiddler(
          childBuilder: (context) => TabBarPage(option),
          routeBuilder: () => TabBarRoute(option),
          key: key,
        );
      case Pages.lineIndicator:
        return RouterMiddler(
          childBuilder: (context) => LineIndicatorPage(option),
          routeBuilder: () => LineIndicatorRoute(option),
          key: key,
        );
      case Pages.bulletShape:
        return RouterMiddler(
          childBuilder: (context) => BulletShapePage(option),
          routeBuilder: () => BulletShapeRoute(option),
          key: key,
        );
      case Pages.routePushThird:
        return RouterMiddler(
          childBuilder: (context) => RoutePushThirdPage(option),
          routeBuilder: () => RoutePushThirdRoute(option),
          key: key,
        );
      case Pages.statefulButton:
        return RouterMiddler(
          childBuilder: (context) => StatefulButtonPage(option),
          routeBuilder: () => StatefulButtonRoute(option),
          key: key,
        );
      case Pages.waveProgress:
        return RouterMiddler(
          childBuilder: (context) => WaveProgressPage(option),
          routeBuilder: () => WaveProgressRoute(option),
          key: key,
        );
      // case Pages.refreshView:
      //   return RouterMiddler(
      //     childBuilder: (context) => RefreshViewPage(option),
      //     routeBuilder: () => RefreshViewRoute(option),
      //     key: key,
      //   );
      // case Pages.libEaseRefresh:
      //   return RouterMiddler(
      //     childBuilder: (context) => LibEaseRefreshPage(option),
      //     routeBuilder: () => LibEaseRefreshRoute(option),
      //     key: key,
      //   );
      case Pages.routePushSub1:
        return RouterMiddler(
          childBuilder: (context) => RoutePushSub1Page(option),
          routeBuilder: () => RoutePushSub1Route(option),
          key: key,
        );
      case Pages.routePushSub2:
        return RouterMiddler(
          childBuilder: (context) => RoutePushSub2Page(option),
          routeBuilder: () => RoutePushSub2Route(option),
          key: key,
        );
      case Pages.routePushSub3:
        return RouterMiddler(
          childBuilder: (context) => RoutePushSub3Page(option),
          routeBuilder: () => RoutePushSub3Route(option),
          key: key,
        );
      case Pages.routePushSubA:
        return RouterMiddler(
          childBuilder: (context) => RoutePushSubAPage(option),
          routeBuilder: () => RoutePushSubARoute(option),
          key: key,
        );
      case Pages.routePushSubB:
        return RouterMiddler(
          childBuilder: (context) => RoutePushSubBPage(option),
          routeBuilder: () => RoutePushSubBRoute(option),
          key: key,
        );
      case Pages.forceCenterLayout:
        return RouterMiddler(
          childBuilder: (context) => ForceCenterLayoutPage(option),
          routeBuilder: () => ForceCenterLayoutRoute(option),
          key: key,
        );
      case Pages.widgetSwitcher:
        return RouterMiddler(
          childBuilder: (context) => WidgetSwitcherPage(option),
          routeBuilder: () => WidgetSwitcherRoute(option),
          key: key,
        );
      case Pages.rotation3D:
        return RouterMiddler(
          childBuilder: (context) => Rotation3DPage(option),
          routeBuilder: () => Rotation3DRoute(option),
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
