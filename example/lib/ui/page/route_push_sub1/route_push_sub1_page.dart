import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

import 'route_push_sub1_route.dart';

class RoutePushSub1Page extends StatefulWidget {
  final RouteOption option;

  RoutePushSub1Page(this.option) : super();

  @override
  _RoutePushSub1PageState createState() => _RoutePushSub1PageState();
}

class _RoutePushSub1PageState extends State<RoutePushSub1Page>
    with AutomaticKeepAliveClientMixin {
  late RoutePushSub1Route route;

  var index = 0;

  @override
  void initState() {
    route = context.pageRoute()!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.indigoAccent,
      alignment: Alignment.center,
      child: InkWell(
        onTap: () {
          index++;
          setState(() {});
        },
        child: Text(
          "子頁面1 - $index",
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
