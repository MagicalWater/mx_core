import 'dart:math';

import 'package:flutter/material.dart';

/// 立方體轉場動畫, 用於第一層入口頁面
/// 第二層頁面需要搭配 [CubeRoutePart2] 使用
class CubeRoutePart1<T> extends PageRoute<T> {
  CubeRoutePart1({
    required this.child,
    RouteSettings? settings,
    this.maintainState = true,
    bool fullscreenDialog = false,
    this.transitionDuration = const Duration(milliseconds: 800),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
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
      final PageTransitionsTheme theme = Theme.of(context).pageTransitionsTheme;
      return theme.buildTransitions<T>(
        this,
        context,
        animation,
        secondaryAnimation,
        child,
      );
    } else {
      double width = MediaQuery.of(context).size.width;

      double entryZ, translateZ, rotateY, opacity;

      if (secondValue <= 0.2) {
        final entryTween = Tween<double>(
          begin: 0,
          end: 0.001 * 5,
        );
        entryZ = entryTween.transform(secondValue);
      } else {
        entryZ = 0.001;
      }

      if (secondValue >= 0.8) {
        final opacityTween = Tween<double>(
          begin: 1,
          end: -10,
        );
        opacity = opacityTween.transform(secondValue - 0.8);
        opacity = max(0, opacity);
      } else {
        opacity = 1;
      }

      rotateY = Tween<double>(
        begin: 0,
        end: pi / 2,
      ).transform(secondValue);

      if (secondValue <= 0.2) {
        final translateTween = Tween<double>(
          begin: 0,
          end: (-width / 2) * 5,
        );
        translateZ = translateTween.transform(secondValue);
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
    }
  }

  @override
  final bool maintainState;

  @override
  final Duration transitionDuration;

  @override
  final Duration reverseTransitionDuration;
}
