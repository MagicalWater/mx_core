import 'dart:math';

import 'package:flutter/material.dart';

import 'cube_route_part2.dart';

/// 立方體轉場動畫, 用於第一層入口頁面
/// 第二層頁面需要搭配 [CubeRoutePart2] 使用
///
/// 路由紀錄(測試路由跳轉時有哪些方法觸發, 以此判斷是否使用Cube轉場動畫)
///
/// 1. other => route1
/// CubeRoutePart1 didChangeNext: null
/// CubeRoutePart1 didChangePrevious: /
///
/// 2. route1 => route2
/// CubeRoutePart2 didChangeNext: null
/// CubeRoutePart2 didChangePrevious: /routePushEntry
/// CubeRoutePart1 didChangeNext: /routePushSecond
/// CubeRoutePart1 canTransitionTo: /routePushSecond
/// CubeRoutePart2 canTransitionFrom: /routePushEntry
///
/// 3. route2 => other
/// CubeRoutePart2 didChangeNext: /kChart
/// CubeRoutePart2 canTransitionTo: /kChart
///
/// 4. route2 <= other
/// CubeRoutePart2 didPopNext: /kChart
/// CubeRoutePart2 canTransitionTo: /kChart
///
/// 5. route1 <= route2
/// CubeRoutePart1 didPopNext: /routePushSecond
/// CubeRoutePart1 canTransitionTo: /routePushSecond
/// CubeRoutePart2 canTransitionFrom: /routePushEntry
///
/// 6. other <= route1
/// 無

class CubeRoutePart1<T> extends PageRoute<T> {
  /// cube旋轉時的動畫差值
  final Curve? curve;

  /// X軸方向的翻轉, 稍微翻轉能夠展現出立體感, 默認為0.001, 完全不旋轉則為0
  final double rotateX;

  /// 縮放數值, 默認為0.8x
  final double scale;

  CubeRoutePart1({
    required this.child,
    RouteSettings? settings,
    this.maintainState = true,
    bool fullscreenDialog = false,
    this.transitionDuration = const Duration(milliseconds: 600),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOutQuad,
    this.rotateX = 0.001,
    this.scale = 0.8,
  }) : super(
          settings: settings,
          fullscreenDialog: fullscreenDialog,
        );

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  final Widget child;

  /// 是否展示cube轉場動畫
  bool _activeCubeAnimation = false;

  /// 上次的動畫狀態
  AnimationStatus? _lastAnimationStatus;

  AnimationStatus? _lastSecondaryAnimationStatus;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return child;
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    bool activeCubeAnimation = _activeCubeAnimation;
    if (_activeCubeAnimation) {
      if (_lastAnimationStatus == AnimationStatus.forward &&
          animation.status == AnimationStatus.completed) {
        _activeCubeAnimation = false;
      } else if (_lastAnimationStatus == AnimationStatus.reverse &&
          animation.status == AnimationStatus.dismissed) {
        _activeCubeAnimation = false;
      }

      if (_lastSecondaryAnimationStatus == AnimationStatus.forward &&
          secondaryAnimation.status == AnimationStatus.completed) {
        _activeCubeAnimation = false;
      } else if (_lastSecondaryAnimationStatus == AnimationStatus.reverse &&
          secondaryAnimation.status == AnimationStatus.dismissed) {
        _activeCubeAnimation = false;
      }

      _lastAnimationStatus = animation.status;
      _lastSecondaryAnimationStatus = secondaryAnimation.status;
    }

    if (!activeCubeAnimation) {
      // 仿照[MaterialPageRoute]的預設轉場動畫
      final PageTransitionsTheme theme = Theme.of(context).pageTransitionsTheme;
      return theme.buildTransitions<T>(
        this,
        context,
        animation,
        secondaryAnimation,
        child,
      );
    } else {
      final double secondValue;
      if (curve == null || curve == Curves.linear) {
        // animValue = animation.value;
        secondValue = secondaryAnimation.value;
      } else {
        final tween = CurveTween(curve: curve!);
        // animValue = tween.animate(animation).value;
        secondValue = tween.animate(secondaryAnimation).value;
      }

      final width = MediaQuery.of(context).size.width;

      double rotateXValue,
          translateZValue,
          rotateYValue,
          opacityValue,
          scaleValue;

      if (secondValue <= 0.2) {
        final rotateXTween = Tween<double>(
          begin: 0,
          end: rotateX * 5,
        );
        rotateXValue = rotateXTween.transform(secondValue);
      } else {
        rotateXValue = rotateX;
      }

      if (secondValue <= 0.2) {
        final scaleTween = Tween<double>(
          begin: 1,
          end: 1 - ((1 - scale) * 5),
        );
        scaleValue = scaleTween.transform(secondValue);
      } else {
        scaleValue = scale;
      }

      // 透明值主要是為了當元件旋轉到兩邊後, 顯示會有不自然的問題
      // 因此不開放給外部進行自訂設置
      if (secondValue >= 0.8) {
        final opacityTween = Tween<double>(
          begin: 1,
          end: -10,
        );
        opacityValue = opacityTween.transform(secondValue - 0.8);
        opacityValue = max(0, opacityValue);
      } else {
        opacityValue = 1;
      }

      // 立方體旋轉
      rotateYValue = Tween<double>(
        begin: 0,
        end: pi / 2,
      ).transform(secondValue);

      // 立方體的旋轉中心圓半徑
      if (secondValue <= 0.2) {
        final translateTween = Tween<double>(
          begin: 0,
          end: (-width / 2) * 5,
        );
        translateZValue = translateTween.transform(secondValue);
      } else {
        translateZValue = -width / 2;
      }

      return Opacity(
        opacity: opacityValue,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, rotateXValue)
            ..rotateY(rotateYValue)
            ..scale(scaleValue, scaleValue)
            ..translate(0.0, 0.0, translateZValue),
          child: child,
        ),
      );
    }
  }

  @override
  final bool maintainState;

  @override
  final Duration transitionDuration;

  @override
  final Duration reverseTransitionDuration;

  @override
  bool canTransitionTo(TransitionRoute nextRoute) {
    // print('CubeRoutePart1 canTransitionTo: ${nextRoute.settings.name}');
    return super.canTransitionTo(nextRoute);
  }

  @override
  bool canTransitionFrom(TransitionRoute previousRoute) {
    // print('CubeRoutePart1 canTransitionFrom: ${previousRoute.settings.name}');
    return super.canTransitionFrom(previousRoute);
  }

  @override
  void didChangePrevious(Route? previousRoute) {
    // print('CubeRoutePart1 didChangePrevious: ${previousRoute?.settings.name}');
    super.didChangePrevious(previousRoute);
  }

  @override
  void didChangeNext(Route? nextRoute) {
    _activeCubeAnimation = nextRoute != null && nextRoute is CubeRoutePart2;
    // print('CubeRoutePart1 didChangeNext: ${nextRoute?.settings.name}');
    super.didChangeNext(nextRoute);
  }

  @override
  void didPopNext(Route nextRoute) {
    _activeCubeAnimation = nextRoute is CubeRoutePart2;
    // print('CubeRoutePart1 didPopNext: ${nextRoute.settings.name}');
    super.didPopNext(nextRoute);
  }

  @override
  void didReplace(Route? oldRoute) {
    // print('CubeRoutePart1 didReplace: ${oldRoute?.settings.name}');
    super.didReplace(oldRoute);
  }
}
