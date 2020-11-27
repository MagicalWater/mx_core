import 'package:annotation_route/route.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/bloc/page/route_push_second/route_push_sub2_bloc.dart';
import 'package:mx_core_example/router/route.dart';

@ARoute(url: Pages.routePushSub2)
class RoutePushSub2Page extends StatefulWidget {
  final RouteOption option;

  RoutePushSub2Page(this.option) : super();

  @override
  _RoutePushSub2PageState createState() => _RoutePushSub2PageState();
}

class _RoutePushSub2PageState extends State<RoutePushSub2Page> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  RoutePushSub2Bloc bloc;
  int counter = 0;

  @override
  void initState() {
    bloc = BlocProvider.of<RoutePushSub2Bloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LoadProvider(
      loadStream: bloc.loadStream,
      child: Container(
        color: Colors.redAccent,
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Text(
              "子頁面2 = $counter",
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            _buildButton("切換子頁面 A/B", () {
              bloc.toNextSubPage();
//              counter++;
//              setState(() {});
            }),
            Expanded(
              child: PageSwitcher(
                routes: bloc.subPages(),
                stream: bloc.subPageHistoryStream,
              ),
            ),
          ],
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
