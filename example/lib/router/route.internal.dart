// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// RouteWriterGenerator
// **************************************************************************

import 'dart:convert';
import 'package:annotation_route/route.dart';
import 'package:mx_core_example/ui/page/lib_ease_refresh_page.dart';
import 'package:mx_core_example/ui/page/stateful_button_page.dart';
import 'package:mx_core_example/ui/page/normal_popup_page.dart';
import 'package:mx_core_example/ui/page/load_provider_page.dart';
import 'package:mx_core_example/ui/page/route_push_entry_page.dart';
import 'package:mx_core_example/ui/page/animated_core_page.dart';
import 'package:mx_core_example/ui/page/assist_touch_page.dart';
import 'package:mx_core_example/ui/page/span_grid_page.dart';
import 'package:mx_core_example/ui/page/loading_page.dart';
import 'package:mx_core_example/ui/page/timer_page.dart';
import 'package:mx_core_example/ui/page/arrow_container_page.dart';
import 'package:mx_core_example/ui/page/particle_animation_page.dart';
import 'package:mx_core_example/ui/page/test_page.dart';
import 'package:mx_core_example/ui/page/route_push_second_page.dart';
import 'package:mx_core_example/ui/page/wave_progress_page.dart';
import 'package:mx_core_example/ui/page/route_push_third_page.dart';
import 'package:mx_core_example/ui/page/refresh_view_page.dart';
import 'package:mx_core_example/ui/page/arrow_popup_page.dart';
import 'package:mx_core_example/ui/page/route_push_second/route_push_sub2/route_push_sub_a_page.dart';
import 'package:mx_core_example/ui/page/route_push_second/route_push_sub2/route_push_sub_b_page.dart';
import 'package:mx_core_example/ui/page/route_push_second/route_push_sub2_page.dart';
import 'package:mx_core_example/ui/page/route_push_second/route_push_sub3_page.dart';
import 'package:mx_core_example/ui/page/route_push_second/route_push_sub1_page.dart';
import 'package:mx_core_example/ui/page/introduction_page.dart';
import 'package:mx_core_example/ui/page/coordinate_layout_page.dart';
import 'package:mx_core_example/ui/page/marquee_page.dart';

class ARouterInternalImpl extends ARouterInternal {
  ARouterInternalImpl();
  final Map<String, List<Map<String, dynamic>>> innerRouterMap =
      <String, List<Map<String, dynamic>>>{
    '/libEaseRefresh': [
      {'clazz': LibEaseRefreshPage}
    ],
    '/statefulButton': [
      {'clazz': StatefulButtonPage}
    ],
    '/normalPopup': [
      {'clazz': NormalPopupPage}
    ],
    '/loadProvider': [
      {'clazz': LoadProviderPage}
    ],
    '/routePushEntry': [
      {'clazz': RoutePushEntryPage}
    ],
    '/animatedCore': [
      {'clazz': AnimatedCorePage}
    ],
    '/assistTouch': [
      {'clazz': AssistTouchPage}
    ],
    '/spanGrid': [
      {'clazz': SpanGridPage}
    ],
    '/loading': [
      {'clazz': LoadingPage}
    ],
    '/timer': [
      {'clazz': TimerPage}
    ],
    '/arrowContainer': [
      {'clazz': ArrowContainerPage}
    ],
    '/particleAnimation': [
      {'clazz': ParticleAnimationPage}
    ],
    '/test': [
      {'clazz': TestPage}
    ],
    '/routePushSecond': [
      {'clazz': RoutePushSecondPage}
    ],
    '/waveProgress': [
      {'clazz': WaveProgressPage}
    ],
    '/routePushThird': [
      {'clazz': RoutePushThirdPage}
    ],
    '/refreshView': [
      {'clazz': RefreshViewPage}
    ],
    '/arrowPopup': [
      {'clazz': ArrowPopupPage}
    ],
    '/routePushSecond/routePushSub2/routePushSubA': [
      {'clazz': RoutePushSubAPage}
    ],
    '/routePushSecond/routePushSub2/routePushSubB': [
      {'clazz': RoutePushSubBPage}
    ],
    '/routePushSecond/routePushSub2': [
      {'clazz': RoutePushSub2Page}
    ],
    '/routePushSecond/routePushSub3': [
      {'clazz': RoutePushSub3Page}
    ],
    '/routePushSecond/routePushSub1': [
      {'clazz': RoutePushSub1Page}
    ],
    '/introduction': [
      {'clazz': IntroductionPage}
    ],
    '/coordinateLayout': [
      {'clazz': CoordinateLayoutPage}
    ],
    '/marquee': [
      {'clazz': MarqueePage}
    ]
  };

  @override
  bool hasPageConfig(ARouteOption option) {
    final dynamic pageConfig = findPageConfig(option);
    return pageConfig != null;
  }

  @override
  ARouterResult findPage(ARouteOption option, dynamic initOption) {
    final dynamic pageConfig = findPageConfig(option);
    if (pageConfig != null) {
      return implFromPageConfig(pageConfig, initOption);
    } else {
      return ARouterResult(state: ARouterResultState.NOT_FOUND);
    }
  }

  void instanceCreated(
      dynamic clazzInstance, Map<String, dynamic> pageConfig) {}

  dynamic instanceFromClazz(Type clazz, dynamic option) {
    switch (clazz) {
      case LibEaseRefreshPage:
        return new LibEaseRefreshPage(option);
      case StatefulButtonPage:
        return new StatefulButtonPage(option);
      case NormalPopupPage:
        return new NormalPopupPage(option);
      case LoadProviderPage:
        return new LoadProviderPage(option);
      case RoutePushEntryPage:
        return new RoutePushEntryPage(option);
      case AnimatedCorePage:
        return new AnimatedCorePage(option);
      case AssistTouchPage:
        return new AssistTouchPage(option);
      case SpanGridPage:
        return new SpanGridPage(option);
      case LoadingPage:
        return new LoadingPage(option);
      case TimerPage:
        return new TimerPage(option);
      case ArrowContainerPage:
        return new ArrowContainerPage(option);
      case ParticleAnimationPage:
        return new ParticleAnimationPage(option);
      case TestPage:
        return new TestPage(option);
      case RoutePushSecondPage:
        return new RoutePushSecondPage(option);
      case WaveProgressPage:
        return new WaveProgressPage(option);
      case RoutePushThirdPage:
        return new RoutePushThirdPage(option);
      case RefreshViewPage:
        return new RefreshViewPage(option);
      case ArrowPopupPage:
        return new ArrowPopupPage(option);
      case RoutePushSubAPage:
        return new RoutePushSubAPage(option);
      case RoutePushSubBPage:
        return new RoutePushSubBPage(option);
      case RoutePushSub2Page:
        return new RoutePushSub2Page(option);
      case RoutePushSub3Page:
        return new RoutePushSub3Page(option);
      case RoutePushSub1Page:
        return new RoutePushSub1Page(option);
      case IntroductionPage:
        return new IntroductionPage(option);
      case CoordinateLayoutPage:
        return new CoordinateLayoutPage(option);
      case MarqueePage:
        return new MarqueePage(option);
      default:
        return null;
    }
  }

  ARouterResult implFromPageConfig(
      Map<String, dynamic> pageConfig, dynamic option) {
    final String interceptor = pageConfig['interceptor'];
    if (interceptor != null) {
      return ARouterResult(
          state: ARouterResultState.REDIRECT, interceptor: interceptor);
    }
    final Type clazz = pageConfig['clazz'];
    if (clazz == null) {
      return ARouterResult(state: ARouterResultState.NOT_FOUND);
    }
    try {
      final dynamic clazzInstance = instanceFromClazz(clazz, option);
      instanceCreated(clazzInstance, pageConfig);
      return ARouterResult(
          widget: clazzInstance, state: ARouterResultState.FOUND);
    } catch (e) {
      return ARouterResult(state: ARouterResultState.NOT_FOUND);
    }
  }

  dynamic findPageConfig(ARouteOption option) {
    final List<Map<String, dynamic>> pageConfigList =
        innerRouterMap[option.urlpattern];
    if (null != pageConfigList) {
      for (int i = 0; i < pageConfigList.length; i++) {
        final Map<String, dynamic> pageConfig = pageConfigList[i];
        final String paramsString = pageConfig['params'];
        if (null != paramsString) {
          Map<String, dynamic> params;
          try {
            params = json.decode(paramsString);
          } catch (e) {
            print('not found A{pageConfig};');
          }
          if (null != params) {
            bool match = true;
            final Function matchParams = (String k, dynamic v) {
              if (params[k] != option?.params[k]) {
                match = false;
                print('not match:A{params[k]}:A{option?.params[k]}');
              }
            };
            params.forEach(matchParams);
            if (match) {
              return pageConfig;
            }
          } else {
            print('ERROR: in parsing paramsA{pageConfig}');
          }
        } else {
          return pageConfig;
        }
      }
    }
    return null;
  }
}
