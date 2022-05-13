import 'dart:math';

import 'package:flutter/material.dart';

/// 立方體轉場動畫, 用於第二層頁面
/// 第一層入口頁面需要搭配 [CubeRoutePart1] 使用
class CubeRoutePart2<T> extends PageRoute<T> {
  CubeRoutePart2({
    required this.child,
    RouteSettings? settings,
    this.maintainState = true,
    bool fullscreenDialog = false,
    this.transitionDuration = const Duration(milliseconds: 800),
    this.reverseTransitionDuration = const Duration(milliseconds: 800),
  }) : super(
          settings: settings,
          fullscreenDialog: fullscreenDialog,
        );

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  final Widget child;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return child;
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final animValue = animation.value;
    final secondValue = secondaryAnimation.value;
    
    if (animValue <= 1 && secondValue == 0) {
      // 代表第一個起作用

      double width = MediaQuery.of(context).size.width;

      double entryZ, translateZ, rotateY, opacity;

      if (animValue >= 0.8) {
        final entryTween = Tween<double>(
          begin: 0.001 * 5,
          end: 0,
        );
        entryZ = entryTween.transform(animValue);
      } else {
        entryZ = 0.001;
      }

      if (animValue <= 0.2) {
        final opacityTween = Tween<double>(
          begin: -10,
          end: 1,
        );
        opacity = opacityTween.transform(animValue + 0.8);
        opacity = max(0, opacity);
      } else {
        opacity = 1;
      }

      rotateY = Tween<double>(
        begin: -pi / 2,
        end: 0,
      ).transform(animValue);

      if (animValue >= 0.8) {
        final translateTween = Tween<double>(
          begin: (-width / 2) * 5,
          end: 0,
        );
        translateZ = translateTween.transform(animValue);
      } else {
        translateZ = -width / 2;
      }

      return Opacity(
        opacity: opacity,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, entryZ)
            ..rotateY(rotateY)
            ..translate(
              0.0,
              0.0,
              translateZ,
            ),
          child: child,
        ),
      );
    } else {
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
}
