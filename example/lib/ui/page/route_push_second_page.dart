import 'package:annotation_route/route.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/bloc/application_bloc.dart';
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
  ApplicationBloc appBloc = ApplicationBloc.getInstance();

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
                  count++;
                  if (count > 4) {
                    print('回退');
                    ApplicationBloc.getInstance().popSubPage(underRoute: Pages.routePushSecond, context: context);
                  } else {
                    bloc.setSubPageToNext();
                  }
                }),
                Divider(
                  height: 16,
                  color: Colors.transparent,
                ),
                Expanded(
                  child: PageSwitcher(
                    stream: bloc.subPageStream,
                    emptyWidget: Container(),
                    opacity: false,
                    slide: true,
                    slideIn: TransDirection.left,
                    slideOut: TransDirection.right,
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
