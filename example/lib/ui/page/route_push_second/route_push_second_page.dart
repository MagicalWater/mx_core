import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/router/routes.dart';
import 'package:mx_core_example/ui/widget/base_app_bar.dart';
import 'package:mx_core_example/ui/widget/top_desc.dart';

import 'route_push_second_route.dart';

class RoutePushSecondPage extends StatefulWidget {
  final RouteOption option;

  RoutePushSecondPage(this.option) : super();

  @override
  _RoutePushSecondPageState createState() => _RoutePushSecondPageState();
}

class _RoutePushSecondPageState extends State<RoutePushSecondPage> {
  late RoutePushSecondRoute route;
  var title = "頁面跳轉機制第二大頁面";
  var content = """
  此頁面有三個子頁面
  1. 預設子頁面為 子頁面1
  """;

  @override
  void initState() {
    route = context.pageRoute()!;
    super.initState();
  }

  var count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: baseAppBar(title),
      body: Container(
        child: FractionallySizedBox(
          widthFactor: 1,
          child: Column(
            children: <Widget>[
              TopDesc(content: content),
              _button("點擊切換子頁面", () {
                count++;
                if (count > 200) {
                  print('回退');
                  appRouter.popSubPage(Pages.routePushSecond);
                } else {
                  if (appRouter.isPageShowing(Pages.routePushSub1)) {
                    print('子頁面1顯示中');
                    appRouter.pushPage(Pages.routePushSub2);
                  } else if (appRouter.isPageShowing(Pages.routePushSub2)) {
                    print('子頁面2顯示中');
                    appRouter.pushPage(Pages.routePushSub3);
                  } else if (appRouter.isPageShowing(Pages.routePushSub3)) {
                    print('子頁面3顯示中');
                    appRouter.pushPage(Pages.routePushSub1);
                  } else {
                    print('沒有任何頁面顯示');
                  }
                }
              }),
              Divider(
                height: 16,
                color: Colors.transparent,
              ),
              Expanded(
                child: StackSwitcher(
                  routes: route.subPages(),
                  stream: route.subPageHistoryStream,
                  emptyWidget: Container(),

                  // === 右滑回退 ===
                  // translateIn: Offset(-Screen.width, 0),
                  // translateOut: Offset(40, 0),
                  // backDirection: AxisDirection.right,
                  // ===============

                  // === 左滑回退 ===
                  // translateIn: Offset(Screen.width, 0),
                  // translateOut: Offset(-40, 0),
                  // backDirection: AxisDirection.left,
                  // ===============

                  // === 下滑回退 ===
                  // translateIn: Offset(0, Screen.height),
                  // translateOut: Offset(0, -40),
                  // backDirection: AxisDirection.down,
                  // ===============

                  // === 上滑回退 ===
                  translateIn: Offset(0, -Screen.height),
                  translateOut: Offset(0, 40),
                  backDirection: AxisDirection.up,
                  // ===============

                  scaleIn: 1.5,
                  scaleOut: 0.5,

                  animateEnabled: true,
                  duration: Duration(milliseconds: 2000),
                  opacityIn: 0,
                  opacityOut: 0.5,
                  onBackPage: () {
                    appRouter.popSubPage(Pages.routePushSecond);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 構建切換路由按鈕
  Widget _button(String text, VoidCallback onTap) {
    return MaterialLayer.single(
      layer: LayerProperties(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xffcca068),
              Color(0xff8c6018),
            ],
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Align(
        widthFactor: 2,
        heightFactor: 2,
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      onTap: onTap,
    );
  }
}
