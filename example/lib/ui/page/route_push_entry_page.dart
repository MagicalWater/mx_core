import 'package:flutter/material.dart';
import 'package:annotation_route/route.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/router/route.dart';
import 'package:mx_core_example/bloc/page/route_push_entry_bloc.dart';
import 'package:mx_core_example/bloc/application_bloc.dart';
import 'package:mx_core_example/ui/page/introduction_page.dart';

@ARoute(url: Pages.routePushEntry)
class RoutePushEntryPage extends StatefulWidget {
  final RouteOption option;

  RoutePushEntryPage(this.option) : super();

  @override
  _RoutePushEntryPageState createState() => _RoutePushEntryPageState();
}

class _RoutePushEntryPageState extends State<RoutePushEntryPage> {
  RoutePushEntryBloc bloc;
  ApplicationBloc appBloc = ApplicationBloc.getInstance();

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
    bloc = BlocProvider.of<RoutePushEntryBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoadProvider(
      loadStream: bloc.loadStream,
      child: PageScaffold(
        color: Colors.black,
        haveAppBar: true,
        title: title,
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                buildIntroduction(content),
                _buildRouteButton("跳轉大頁面", () {
                  appBloc.pushPage(Pages.routePushSecond, context);
                }),
                _buildRouteButton("跨頁面跳轉子頁面", () {
                  appBloc.setSubPage(Pages.routePushSub3, context: context);
                }),
                _buildRouteButton("跨頁跳轉隔代子頁面", () {
                  appBloc.setSubPage(Pages.routePushSubB, context: context);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 構建跳轉路由按鈕
  Widget _buildRouteButton(String text, VoidCallback onTap) {
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
