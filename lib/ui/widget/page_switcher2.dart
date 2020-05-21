import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

typedef RouteWidgetBuilder(BuildContext context, RouteData data);

/// 頁面切換元件
/// 直接將 PageBloc 的 subPageStream 傳入即可
class PageSwitcher2 extends StatelessWidget {
  final Stream<RouteData> stream;

  final List<String> pages;

  /// 當尚未有 route 傳入時, 所顯示的空元件
  /// 默認為 Container()
  final Widget emptyWidget;

  final int duration;

  PageSwitcher2({
    this.stream,
    this.pages,
    this.duration = 300,
    this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RouteData>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return emptyWidget ?? Container();
        }
        return PageView.builder(
          itemBuilder: (BuildContext context, int index) {
            if (snapshot.data.route == pages[index]) {
              return routeMixinImpl.getSubPage(snapshot.data);
            }
            return routeMixinImpl.getSubPage(RouteData(pages[index]));
          },
        );
      },
    );
  }
}
