import 'package:annotation_route/route.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/bloc/app_bloc.dart';
import 'package:mx_core_example/bloc/page/route_push_second_bloc.dart';
import 'package:mx_core_example/router/route.dart';
import 'package:mx_core_example/ui/page/introduction_page.dart';

@ARoute(url: Pages.routePushSecond)
class RoutePushSecondPage extends StatefulWidget {
  final RouteOption option;

  RoutePushSecondPage(this.option) : super();

  @override
  _RoutePushSecondPageState createState() => _RoutePushSecondPageState();
}

class _RoutePushSecondPageState extends State<RoutePushSecondPage> {
  RoutePushSecondBloc bloc;
  AppBloc appBloc = AppBloc.getInstance();

  var title = "頁面跳轉機制第二大頁面";
  var content = """
  此頁面有三個子頁面
  1. 預設子頁面為 子頁面1
  """;

  @override
  void initState() {
    bloc = BlocProvider.of<RoutePushSecondBloc>(context);
    super.initState();
  }

  var count = 0;

  @override
  Widget build(BuildContext context) {
    return LoadProvider(
      loadStream: bloc.loadStream,
      child: PageScaffold(
        haveAppBar: true,
        color: Colors.black,
        title: title,
        child: Container(
          child: FractionallySizedBox(
            widthFactor: 1,
            child: Column(
              children: <Widget>[
                buildIntroduction(content),
                _buildButton("點擊切換子頁面", () {
                  // bloc.setSubPageToNext();
                  // return;
                  count++;
//                  bloc.setSubPageToNext();
//                  return;
                  if (count > 200) {
                    print('回退');
//                    if (!ApplicationBloc.getInstance().canPopSubPage(route: Pages.routePushSecond)) {
//                      print('不可以回退');
//                      return;
//                    }
                    appBloc.popSubPage(Pages.routePushSecond);
//                    ApplicationBloc.getInstance().setSubPage(
//                      bloc.subPages()[0],
//                      popUntil: (route) {
//                        print('刪除歷史: $route');
//                        return false;
//                      },
//                      forceNew: true,
//                    );
                    print(bloc.subPageHistory.map((e) => e.route));
//                    ApplicationBloc.getInstance().popSubPage(route: Pages.routePushSecond, context: context);
                  } else {
                    if (bloc.isPageShowing(Pages.routePushSub1)) {
                      print('子頁面1顯示中');
                      bloc.pushPage(Pages.routePushSub2);
                    } else if (bloc.isPageShowing(Pages.routePushSub2)) {
                      print('子頁面2顯示中');
                      bloc.pushPage(Pages.routePushSub3);
                    } else if (bloc.isPageShowing(Pages.routePushSub3)) {
                      print('子頁面3顯示中');
                      bloc.pushPage(Pages.routePushSub1);
                    } else {
                      print('沒有任何頁面顯示');
                    }
                    // bloc.toNextSubPage();
                  }
                }),
                Divider(
                  height: 16,
                  color: Colors.transparent,
                ),
                Expanded(
                  child: StackSwitcher(
                    routes: bloc.subPages(),
                    stream: bloc.subPageHistoryStream,
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
                      bloc.popSubPage(Pages.routePushSecond);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 構建切換路由按鈕
  Widget _buildButton(String text, VoidCallback onTap) {
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
