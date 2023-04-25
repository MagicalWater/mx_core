import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

import 'route_push_sub2_route.dart';

DateTime? targetB1;
DateTime? endB;
DateTime? centerB;
DateTime? routeB;
DateTime? startB;

class RoutePushSub2Page extends StatefulWidget {
  final RouteOption option;

  RoutePushSub2Page(this.option) : super();

  @override
  _RoutePushSub2PageState createState() => _RoutePushSub2PageState();
}

class _RoutePushSub2PageState extends State<RoutePushSub2Page>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late RoutePushSub2Route route;
  int counter = 0;

  Future<bool>? waitF;

  @override
  void initState() {
    route = context.pageRoute()!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    centerB = DateTime.now();
    print('跳轉B轉中間延遲時間: ${centerB!.difference(startB!)}');
    super.build(context);
    return Container(
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
            route.toNextSubPage();
//              counter++;
//              setState(() {});
//             bool aa = true;
//             Navigator.of(context).popUntil((route) {
//               print('回退 => ${route.settings.name}');
//               if (aa) {
//                 aa = false;
//                 return false;
//               } else {
//                 return true;
//               }
//             });
          }),
          // Expanded(
          //   child: FutureBuilder<bool>(
          //     future: waitF ??= Future.delayed(const Duration(milliseconds: 0))
          //         .then((value) => true),
          //     builder: (context, value) {
          //       print('數值: ${value.data}');
          //       if (value.hasData) {
          //         return Container(
          //           width: double.infinity,
          //           height: double.infinity,
          //           decoration: BoxDecoration(color: Colors.amberAccent),
          //         );
          //       } else {
          //         return Container();
          //       }
          //     },
          //   ),
          // ),
          Expanded(
            child: RouteStackSwitcher(
              initRoute: route.initSubPage,
              stream: route.subPageHistoryStream,
              animateEnabled: false,
              duration: Duration.zero,
              debug: true,
              emptyWidget: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.green,
              ),
              onRouteListen: (routeList) {
                routeB = DateTime.now();
                print('跳轉B轉路由延遲時間: ${routeB!.difference(startB!)}');
              },
            ),
          ),
        ],
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
