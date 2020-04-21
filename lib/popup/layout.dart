import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mx_core/util/screen_util.dart';

/// 浮出視窗, 實現原理同樣是 Overlay, 在這邊藉由 route 達成效果
/// 參考: https://www.coderblog.in/2019/04/how-to-create-popup-window-in-flutter/
/// 修改者: Water
/// 外部調用請使用
/// Navigator.push(context, PopupLayout(child: Text('popup layout'),);
class PopupLayout extends ModalRoute {
  EdgeInsetsGeometry margin;
  double width;
  double height;
  Alignment alignment;

  /// 背景顏色
  Color backgroundColor;
  final Widget child;

  VoidCallback onTap;

  Widget Function(BuildContext context, Widget child) rootBuilder;

  PopupLayout({
    @required this.child,
    this.backgroundColor,
    this.margin,
    this.width,
    this.height,
    this.alignment = Alignment.topLeft,
    this.rootBuilder,
    this.onTap,
  }) {
    Screen.init();
  }

  /// 背景顏色
  @override
  Color get barrierColor {
    if (backgroundColor != null) {
      if (backgroundColor == Colors.transparent) {
        return Color(0x00ffffff);
      }
      return backgroundColor;
    } else {
      return Colors.black.withOpacity(0.5);
    }
  }

  /// 尚不明白這個是什麼
  @override
  bool get barrierDismissible => false;

  /// 尚不明白這個是什麼
  @override
  String get barrierLabel => null;

  /// 當此 route(浮出視窗處於非活動狀態時, 是否需要保留在內存中)
  @override
  bool get maintainState => false;

  /// 此 route 是否遮蓋了先前的 route
  /// 若是, 則此之前的路由將不構建來節省資源
  @override
  bool get opaque => false;

  /// 過度動畫時間
  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return rootBuilder(
      context,
      GestureDetector(
        onTap: () {
//        SystemChannels.textInput.invokeMethod('TextInput.hide');
          if (onTap != null) {
            onTap();
          }
        },
        child: Material(
          type: MaterialType.transparency,
          child: _buildOverlayContent(context),
        ),
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return Container(
      margin: margin,
      padding: _getPadding(context),
      child: child,
    );
  }

  /// 藉由 padding 達到控制 width / height / alignment 的方式
  EdgeInsetsGeometry _getPadding(BuildContext context) {
    if (width == null && height == null) return null;

//    print("取得 width/height 應該有的 padding~~~: $width,$height");

    var remainWidth = Screen.width - (margin?.horizontal ?? 0);
    var remainHeight = Screen.height -
        Screen.statusBarHeight -
        Screen.bottomBarHeight -
        (margin?.vertical ?? 0);

    var widgetWidth = width ?? remainWidth;
    var widgetHeight = height ?? remainHeight;

    double paddingLeft = 0;
    double paddingTop = 0;
    double paddingRight = 0;
    double paddingBottom = 0;

    if (alignment == Alignment.topLeft) {
      // 對齊上左
      paddingRight = remainWidth - widgetWidth;
      paddingBottom = remainHeight - widgetHeight;
    } else if (alignment == Alignment.topCenter) {
      // 對齊上中
      paddingLeft = (remainWidth - widgetWidth) / 2;
      paddingRight = paddingLeft;
      paddingBottom = remainHeight - widgetHeight;
    } else if (alignment == Alignment.topRight) {
      // 對齊上右
      paddingLeft = remainWidth - widgetWidth;
      paddingBottom = remainHeight - widgetHeight;
    } else if (alignment == Alignment.centerLeft) {
      // 對齊中左
      paddingRight = remainWidth - widgetWidth;
      paddingTop = (remainHeight - widgetHeight) / 2;
      paddingBottom = paddingTop;
    } else if (alignment == Alignment.center) {
      // 對齊中
      paddingLeft = (remainWidth - widgetWidth) / 2;
      paddingRight = paddingLeft;
      paddingTop = (remainHeight - widgetHeight) / 2;
      paddingBottom = paddingTop;
    } else if (alignment == Alignment.centerRight) {
      // 對齊中右
      paddingLeft = remainWidth - widgetWidth;
      paddingTop = (remainHeight - widgetHeight) / 2;
      paddingBottom = paddingTop;
    } else if (alignment == Alignment.bottomLeft) {
      // 對齊下左
      paddingRight = remainWidth - widgetWidth;
      paddingTop = remainHeight - widgetHeight;
    } else if (alignment == Alignment.bottomCenter) {
      // 對齊下中
      paddingLeft = (remainWidth - widgetWidth) / 2;
      paddingRight = paddingLeft;
      paddingTop = remainHeight - widgetHeight;
    } else if (alignment == Alignment.bottomRight) {
      // 對齊下右
      paddingLeft = remainWidth - widgetWidth;
      paddingTop = remainHeight - widgetHeight;
    }

    paddingLeft = max(paddingLeft, 0.0);
    paddingTop = max(paddingTop, 0.0);
    paddingRight = max(paddingRight, 0.0);
    paddingBottom = max(paddingBottom, 0.0);

    var p = EdgeInsets.only(
      left: paddingLeft,
      top: paddingTop,
      right: paddingRight,
      bottom: paddingBottom,
    );

//    print("取得 width/height 應該有的 padding: $p");
    return p;
  }
}
