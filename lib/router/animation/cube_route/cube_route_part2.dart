import 'dart:math';

import 'package:flutter/material.dart';

import 'cube_route_part1.dart';

/// 立方體轉場動畫, 用於第二層頁面
/// 第一層入口頁面需要搭配 [CubeRoutePart1] 使用
class CubeRoutePart2<T> extends PageRoute<T> {
  /// cube旋轉時的動畫差值
  final Curve? curve;

  /// X軸方向的翻轉, 稍微翻轉能夠展現出立體感, 默認為0.001, 完全不旋轉則為0
  final double rotateX;

  /// 縮放數值, 默認為0.8
  final double scale;

  CubeRoutePart2({
    required this.child,
    RouteSettings? settings,
    this.maintainState = true,
    bool fullscreenDialog = false,
    this.transitionDuration = const Duration(milliseconds: 600),
    this.reverseTransitionDuration = const Duration(milliseconds: 600),
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

    if (activeCubeAnimation) {
      final double animValue;
      if (curve == null || curve == Curves.linear) {
        animValue = animation.value;
      } else {
        final tween = CurveTween(curve: curve!);
        animValue = tween.animate(animation).value;
      }

      final width = MediaQuery.of(context).size.width;

      double rotateXValue,
          translateZValue,
          rotateYValue,
          opacityValue,
          scaleValue;

      if (animValue >= 0.8) {
        final rotateXTween = Tween<double>(
          begin: rotateX * 5,
          end: 0,
        );
        rotateXValue = rotateXTween.transform(animValue);
      } else {
        rotateXValue = rotateX;
      }

      if (animValue >= 0.8) {
        final scaleTween = Tween<double>(
          begin: 1 - ((1 - scale) * 5),
          end: 1,
        );
        scaleValue = scaleTween.transform(animValue);
      } else {
        scaleValue = scale;
      }

      // 透明值主要是為了當元件旋轉到兩邊後, 顯示會有不自然的問題
      // 因此不開放給外部進行自訂設置
      if (animValue <= 0.2) {
        final opacityTween = Tween<double>(
          begin: -10,
          end: 1,
        );
        opacityValue = opacityTween.transform(animValue + 0.8);
        opacityValue = max(0, opacityValue);
      } else {
        opacityValue = 1;
      }

      // 立方體旋轉
      rotateYValue = Tween<double>(
        begin: -pi / 2,
        end: 0,
      ).transform(animValue);

      // 立方體的旋轉中心圓半徑
      if (animValue >= 0.8) {
        final translateTween = Tween<double>(
          begin: (-width / 2) * 5,
          end: 0,
        );
        translateZValue = translateTween.transform(animValue);
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
    } else {
      // 仿照[MaterialPageRoute]的預設轉場動畫
      final PageTransitionsTheme theme = Theme.of(context).pageTransitionsTheme;
      return theme.buildTransitions<T>(
        this,
        context,
        animation,
        secondaryAnimation,
        child,
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
    // print('CubeRoutePart2 canTransitionTo: ${nextRoute.settings.name}');
    return super.canTransitionTo(nextRoute);
  }

  @override
  bool canTransitionFrom(TransitionRoute previousRoute) {
    // print('CubeRoutePart2 canTransitionFrom: ${previousRoute.settings.name}');
    _activeCubeAnimation = previousRoute is CubeRoutePart1;
    return super.canTransitionFrom(previousRoute);
  }

  @override
  void didChangePrevious(Route? previousRoute) {
    // print('CubeRoutePart2 didChangePrevious: ${previousRoute?.settings.name}');
    _activeCubeAnimation = previousRoute != null && previousRoute is CubeRoutePart1;
    super.didChangePrevious(previousRoute);
  }

  @override
  void didChangeNext(Route? nextRoute) {
    // print('CubeRoutePart2 didChangeNext: ${nextRoute?.settings.name}');
    super.didChangeNext(nextRoute);
  }

  @override
  void didPopNext(Route nextRoute) {
    // print('CubeRoutePart2 didPopNext: ${nextRoute.settings.name}');
    super.didPopNext(nextRoute);
  }

  @override
  void didReplace(Route? oldRoute) {
    // print('CubeRoutePart2 didReplace: ${oldRoute?.settings.name}');
    super.didReplace(oldRoute);
  }
}
