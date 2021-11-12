import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/page_route/introduction_route.dart';
import 'package:mx_core_example/ui/page/introduction/view/introduction_page.dart';

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
    final option = data.copyWith();
    switch (data.route) {
      case Pages.introduction:
        return RouterMiddler(
          childBuilder: (context) => IntroductionPage(option),
          routeBuilder: () => IntroductionRoute(option),
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
