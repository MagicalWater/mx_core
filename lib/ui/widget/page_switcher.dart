import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

typedef RouteWidgetBuilder(BuildContext context, RouteData data);

/// 頁面切換元件
/// 直接將 PageBloc 的 subPageStream 傳入即可
class PageSwitcher extends StatelessWidget {
  final Stream<RouteData> stream;

  /// 當尚未有 route 傳入時, 所顯示的空元件
  /// 默認為 Container()
  final Widget emptyWidget;

  /// 需要自訂 route 對應到的頁面元件
  final RouteWidgetBuilder customBuilder;
  final int duration;

  /// 頁面跳轉時是否有透明動畫
  final bool opacity;

  /// 頁面跳轉時是否有縮放動畫
  final bool scale;

  /// 頁面跳轉時是否有頁面位移動畫
  final bool slide;

  /// 位移動畫入場方向
  final TransDirection slideIn;

  /// 位移動畫出場方向, 默認與入場方向相反
  final TransDirection slideOut;

  PageSwitcher({
    this.stream,
    this.duration = 300,
    this.emptyWidget,
    this.customBuilder,
    this.opacity = true,
    this.scale = false,
    this.slide = false,
    this.slideIn = TransDirection.down,
    this.slideOut,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RouteData>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return emptyWidget ?? Container();
        }
        if (!opacity && !scale && !slide) {
          return customBuilder == null
              ? routeMixinImpl.getSubPage(snapshot.data)
              : customBuilder(context, snapshot.data);
        }
        return AnimatedSwitcher(
          duration: Duration(milliseconds: duration),
          child: customBuilder == null
              ? routeMixinImpl.getSubPage(snapshot.data)
              : customBuilder(context, snapshot.data),
          transitionBuilder: (Widget child, Animation<double> animation) {
            var widgetChain = child;
            if (opacity) {
              widgetChain = FadeTransition(
                opacity: animation,
                child: widgetChain,
              );
            }
            if (scale) {
              widgetChain = ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                    CurvedAnimation(
                        parent: animation, curve: Curves.easeInOutSine)),
                child: widgetChain,
              );
            }
            if (slide) {
              widgetChain = AxisTransition(
                position: CurvedAnimation(
                    parent: animation, curve: Curves.easeOutSine),
                child: widgetChain,
                slideIn: slideIn,
                slideOut: slideOut,
              );
            }
            return widgetChain;
          },
        );
      },
    );
  }
}
