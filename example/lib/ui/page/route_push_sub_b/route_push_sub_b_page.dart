import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/ui/page/route_push_sub2/route_push_sub2_page.dart';

import 'route_push_sub_b_route.dart';

class RoutePushSubBPage extends StatefulWidget {
  final RouteOption option;

  RoutePushSubBPage(this.option) : super();

  @override
  _RoutePushSubBPageState createState() => _RoutePushSubBPageState();
}

class _RoutePushSubBPageState extends State<RoutePushSubBPage> with AutomaticKeepAliveClientMixin {
  late RoutePushSubBRoute route;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    route = context.pageRoute()!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    endB = DateTime.now();
    print('跳轉B延遲時間: ${endB!.difference(startB!)}');
    return Container(
      decoration: BoxDecoration(color: Colors.teal),
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            "子頁面B",
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),
          Expanded(
            child: RouteStackSwitcher(
              initRoute: route.initSubPage,
              stream: route.subPageHistoryStream,
              animateEnabled: false,
              duration: Duration.zero,
            ),
          ),
        ],
      ),
    );
  }
}
