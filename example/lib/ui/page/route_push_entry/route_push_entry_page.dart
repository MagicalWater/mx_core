import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/router/routes.dart';
import 'package:mx_core_example/ui/widget/base_app_bar.dart';
import 'package:mx_core_example/ui/widget/top_desc.dart';

class RoutePushEntryPage extends StatefulWidget {
  final RouteOption option;

  RoutePushEntryPage(this.option) : super();

  @override
  _RoutePushEntryPageState createState() => _RoutePushEntryPageState();
}

class _RoutePushEntryPageState extends State<RoutePushEntryPage> {
  var title = "頁面跳轉機制入口頁";
  var content = """
  頁面跳轉  機制
  1. 跳轉大頁面使用 pushPage
  2. 跳轉子頁面使用 setSubPage
  3. setSubPage 可隔代跳轉
    * 當前子頁面為 /aaa/bbb
    * 但可以直接跳轉 /aaa/bbb/ccc/ddd
  4. setSubPage 可直接跳轉非在當前大頁面的子頁面
    * 當前子頁面為 /aaa/bbb
    * 但可以直接跳轉 /xxx/yyy
  """;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: baseAppBar(title),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TopDesc(content: content),
              _routeButton("跳轉大頁面", () {
                appRouter.pushPage(
                  Pages.routePushSecond,
                  builder: (
                    Widget child,
                    String name,
                  ) {
                    return CubeRoutePart2(
                      child: child,
                      settings: RouteSettings(name: name),
                    );
                  },
                );
              }),
              _routeButton("跨頁面跳轉子頁面", () {
                appRouter.pushPage(Pages.routePushSub3);
              }),
              _routeButton("跨頁跳轉隔代子頁面", () {
                appRouter.pushPage(Pages.routePushSubB);
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// 構建跳轉路由按鈕
  Widget _routeButton(String text, VoidCallback onTap) {
    return MaterialLayer.single(
      layer: LayerProperties(
        margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
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
      child: Container(
        width: double.infinity,
        height: 60,
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      onTap: onTap,
    );
  }
}
