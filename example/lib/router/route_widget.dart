import 'package:flutter/widgets.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/bloc/page/animated_core_bloc.dart';
import 'package:mx_core_example/bloc/page/arrow_container_bloc.dart';
import 'package:mx_core_example/bloc/page/arrow_popup_bloc.dart';
import 'package:mx_core_example/bloc/page/assist_touch_bloc.dart';
import 'package:mx_core_example/bloc/page/coordinate_layout_bloc.dart';
import 'package:mx_core_example/bloc/page/introduction_bloc.dart';
import 'package:mx_core_example/bloc/page/lib_ease_refresh_bloc.dart';
import 'package:mx_core_example/bloc/page/load_provider_bloc.dart';
import 'package:mx_core_example/bloc/page/loading_bloc.dart';
import 'package:mx_core_example/bloc/page/marquee_bloc.dart';
import 'package:mx_core_example/bloc/page/normal_popup_bloc.dart';
import 'package:mx_core_example/bloc/page/particle_animation_bloc.dart';
import 'package:mx_core_example/bloc/page/refresh_view_bloc.dart';
import 'package:mx_core_example/bloc/page/route_push_entry_bloc.dart';
import 'package:mx_core_example/bloc/page/route_push_second/route_push_sub1_bloc.dart';
import 'package:mx_core_example/bloc/page/route_push_second/route_push_sub2/route_push_sub_a_bloc.dart';
import 'package:mx_core_example/bloc/page/route_push_second/route_push_sub2/route_push_sub_b_bloc.dart';
import 'package:mx_core_example/bloc/page/route_push_second/route_push_sub2_bloc.dart';
import 'package:mx_core_example/bloc/page/route_push_second/route_push_sub3_bloc.dart';
import 'package:mx_core_example/bloc/page/route_push_second_bloc.dart';
import 'package:mx_core_example/bloc/page/route_push_third_bloc.dart';
import 'package:mx_core_example/bloc/page/span_grid_bloc.dart';
import 'package:mx_core_example/bloc/page/stateful_button_bloc.dart';
import 'package:mx_core_example/bloc/page/test_bloc.dart';
import 'package:mx_core_example/bloc/page/timer_bloc.dart';
import 'package:mx_core_example/bloc/page/wave_progress_bloc.dart';

import 'route.dart';

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
    Pages.arrowPopup,
    Pages.routePushEntry,
    Pages.routePushSecond,
    Pages.routePushSub1,
    Pages.routePushSub2,
    Pages.routePushSub3,
    Pages.routePushSubA,
    Pages.routePushSubB,
    Pages.test,
    Pages.statefulButton,
    Pages.waveProgress,
    Pages.libEaseRefresh,
    Pages.refreshView,
    Pages.spanGrid,
    Pages.routePushThird,
    Pages.normalPopup,
  ];

  @override
  Widget getPage(RouteData data) {
    final widgetOption = data.copyWith(RouteDataType.widget);
    final blocOption = data.copyWith(RouteDataType.bloc);
    final child = AppRoute.getPage(widgetOption);
    switch (data.route) {
      case Pages.introduction:
        return BlocProvider(
          child: child,
          bloc: IntroductionBloc(blocOption),
        );
      case Pages.assistTouch:
        return BlocProvider(
          child: child,
          bloc: AssistTouchBloc(blocOption),
        );
      case Pages.coordinateLayout:
        return BlocProvider(
          child: child,
          bloc: CoordinateLayoutBloc(blocOption),
        );
      case Pages.loading:
        return BlocProvider(
          child: child,
          bloc: LoadingBloc(blocOption),
        );
      case Pages.loadProvider:
        return BlocProvider(
          child: child,
          bloc: LoadProviderBloc(blocOption),
        );
      case Pages.marquee:
        return BlocProvider(
          child: child,
          bloc: MarqueeBloc(blocOption),
        );
      case Pages.particleAnimation:
        return BlocProvider(
          child: child,
          bloc: ParticleAnimationBloc(blocOption),
        );
      case Pages.timer:
        return BlocProvider(
          child: child,
          bloc: TimerBloc(blocOption),
        );
      case Pages.animatedCore:
        return BlocProvider(
          child: child,
          bloc: AnimatedCoreBloc(blocOption),
        );
      case Pages.arrowContainer:
        return BlocProvider(
          child: child,
          bloc: ArrowContainerBloc(blocOption),
        );
      case Pages.arrowPopup:
        return BlocProvider(
          child: child,
          bloc: ArrowPopupBloc(blocOption),
        );
      case Pages.routePushEntry:
        return BlocProvider(
          child: child,
          bloc: RoutePushEntryBloc(blocOption),
        );
      case Pages.routePushSecond:
        return BlocProvider(
          child: child,
          bloc: RoutePushSecondBloc(blocOption),
        );
      case Pages.routePushSub1:
        return BlocProvider(
          child: child,
          bloc: RoutePushSub1Bloc(blocOption),
        );
      case Pages.routePushSub2:
        return BlocProvider(
          child: child,
          bloc: RoutePushSub2Bloc(blocOption),
        );
      case Pages.routePushSub3:
        return BlocProvider(
          child: child,
          bloc: RoutePushSub3Bloc(blocOption),
        );
      case Pages.routePushSubA:
        return BlocProvider(
          child: child,
          bloc: RoutePushSubABloc(blocOption),
        );
      case Pages.routePushSubB:
        return BlocProvider(
          child: child,
          bloc: RoutePushSubBBloc(blocOption),
        );
      case Pages.test:
        return BlocProvider(
          child: child,
          bloc: TestBloc(blocOption),
        );
      case Pages.statefulButton:
        return BlocProvider(
          child: child,
          bloc: StatefulButtonBloc(blocOption),
        );
      case Pages.waveProgress:
        return BlocProvider(
          child: child,
          bloc: WaveProgressBloc(blocOption),
        );
      case Pages.libEaseRefresh:
        return BlocProvider(
          child: child,
          bloc: LibEaseRefreshBloc(blocOption),
        );
      case Pages.refreshView:
        return BlocProvider(
          child: child,
          bloc: RefreshViewBloc(blocOption),
        );
      case Pages.spanGrid:
        return BlocProvider(
          child: child,
          bloc: SpanGridBloc(blocOption),
        );
      case Pages.routePushThird:
        return BlocProvider(
          child: child,
          bloc: RoutePushThirdBloc(blocOption),
        );
      case Pages.normalPopup:
        return BlocProvider(
          child: child,
          bloc: NormalPopupBloc(blocOption),
        );
      default:
        print("找無對應的 page, ${data.route}");
        return null;
    }
  }
}
